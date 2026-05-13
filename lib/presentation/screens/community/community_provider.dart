import 'package:flutter/material.dart';
import '../../../data/remote/firebase_auth_service.dart';
import '../../../data/remote/firestore_service.dart';
import '../../../domain/models/community_post.dart';

/// Equivalent of CommunityViewModel.kt
class CommunityProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  CommunityProvider(this._firestore, this._auth) {
    _listenToPosts();
  }

  List<CommunityPost> posts = [];
  String composerText = '';
  String? selectedImageUri;
  bool isPosting = false;
  String? errorMessage;
  bool isOffline = false;

  void _listenToPosts() {
    _firestore.postsStream().listen(
      (p) {
        posts = p;
        isOffline = false;
        notifyListeners();
      },
      onError: (_) {
        isOffline = true;
        notifyListeners();
      },
    );
  }

  void onComposerChanged(String v) {
    composerText = v;
    notifyListeners();
  }

  void onImageSelected(String? uri) {
    selectedImageUri = uri;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> postUpdate() async {
    if (composerText.trim().isEmpty) {
      errorMessage = 'Please write something before posting.';
      notifyListeners();
      return;
    }
    if (_auth.isAnonymous) {
      errorMessage = 'Guest users cannot post. Please sign in.';
      notifyListeners();
      return;
    }
    isPosting = true;
    notifyListeners();
    try {
      final post = CommunityPost(
        id: '',
        title: composerText.trim().split('\n').first.take(80),
        body: composerText.trim(),
        author: _auth.currentUserName,
        imageUri: selectedImageUri,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _firestore.addPost(post);
      composerText = '';
      selectedImageUri = null;
    } catch (e) {
      errorMessage = 'Failed to post. Please try again.';
    }
    isPosting = false;
    notifyListeners();
  }
}

extension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
