import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps FirebaseAuth — equivalent of AuthRepositoryImpl + use cases
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isSignedIn => _auth.currentUser != null;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  // ─── Email / Password ─────────────────────────────────────────────────
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // ─── Anonymous ────────────────────────────────────────────────────────
  Future<UserCredential> signInAnonymously() async {
    return _auth.signInAnonymously();
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Re-authentication ────────────────────────────────────────────────
  bool get hasPasswordProvider =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'password') ??
      false;

  bool get hasGoogleProvider =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'google.com') ??
      false;

  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw Exception('No email account to re-authenticate');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await user.reauthenticateWithCredential(credential);
  }

  // ─── Delete Account ───────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await user.delete();
  }

  // ─── Update Profile ───────────────────────────────────────────────────
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  Future<void> updatePhotoUrl(String url) async {
    await _auth.currentUser?.updatePhotoURL(url);
  }

  String get currentUserId => _auth.currentUser?.uid ?? 'guest';
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  String get currentUserName =>
      _auth.currentUser?.displayName ?? 'Farmer';
  String? get currentUserPhotoUrl => _auth.currentUser?.photoURL;
}
