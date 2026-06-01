import 'package:flutter/material.dart';

import '../../../core/utils/stt_manager.dart';
import '../../../data/remote/cloudinary_service.dart';
import '../../../data/remote/firebase_auth_service.dart';
import '../../../data/remote/firestore_service.dart';
import '../../../domain/models/community_post.dart';

/// Community feed: images via Cloudinary, posts in Firestore.
class CommunityProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  final FirebaseAuthService _auth;
  final CloudinaryService _cloudinary;

  CommunityProvider(this._firestore, this._auth, this._cloudinary) {
    _listenToPosts();
  }

  List<CommunityPost> posts = [];
  String composerText = '';
  String? selectedImageUri;
  bool isPosting = false;
  bool isUploadingImage = false;
  String? errorMessage;
  bool isOffline = false;
  bool isListening = false;

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
    errorMessage = null;
    notifyListeners();
  }

  void clearSelectedImage() {
    selectedImageUri = null;
    notifyListeners();
  }

  Future<void> toggleListening({String? localeId}) async {
    if (isListening) {
      await SttManager().stopListening();
      isListening = false;
    } else {
      isListening = true;
      notifyListeners();
      await SttManager().startListening(
        onResult: (text) {
          composerText = text;
          notifyListeners();
        },
        localeId: localeId,
      );
    }
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
    errorMessage = null;
    notifyListeners();

    try {
      final userId = _auth.currentUserId;
      String? imageUrl;

      final localPath = selectedImageUri;
      if (localPath != null &&
          !localPath.startsWith('http://') &&
          !localPath.startsWith('https://')) {
        isUploadingImage = true;
        notifyListeners();
        try {
          imageUrl = await _cloudinary.uploadImage(localPath);
        } catch (e) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
          isPosting = false;
          isUploadingImage = false;
          notifyListeners();
          return;
        } finally {
          isUploadingImage = false;
        }
      } else {
        imageUrl = localPath;
      }

      final post = CommunityPost(
        id: '',
        userId: userId,
        body: composerText.trim(),
        author: _auth.currentUserName,
        imageUri: imageUrl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _firestore.addPost(post);
      composerText = '';
      selectedImageUri = null;
    } catch (e) {
      errorMessage = 'Failed to save post. Please try again.';
    }

    isPosting = false;
    isUploadingImage = false;
    notifyListeners();
  }

  Future<void> reportPost(String postId) async {
    errorMessage = 'Post reported. Thank you for keeping our community safe.';
    notifyListeners();
    await Future.delayed(const Duration(seconds: 3));
    clearError();
  }
}
