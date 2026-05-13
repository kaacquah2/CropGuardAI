import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/community_post.dart';

/// Firestore service — replaces Firebase-backed repository implementations
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Community Posts ──────────────────────────────────────────────────
  Stream<List<CommunityPost>> postsStream() {
    return _db
        .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CommunityPost.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addPost(CommunityPost post) async {
    await _db.collection('community_posts').add(post.toMap());
  }

  // ─── Expert Consultation ──────────────────────────────────────────────
  Future<void> requestExpertHelp({
    required String userId,
    required String detectionId,
    required String message,
    required String diseaseName,
  }) async {
    await _db.collection('expert_requests').add({
      'userId': userId,
      'detectionId': detectionId,
      'message': message,
      'diseaseName': diseaseName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // ─── Scan Sync ────────────────────────────────────────────────────────
  Future<void> uploadScan(Map<String, dynamic> scanData) async {
    await _db.collection('scans').add(scanData);
  }

  // ─── User profile ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  // ─── Outbreak Map ─────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getOutbreakReports() async {
    final snap = await _db
        .collection('outbreak_reports')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // ─── Feedback ─────────────────────────────────────────────────────────
  Future<void> submitFeedback({
    required String userId,
    required int detectionId,
    required String originalLabel,
    required String correctedLabel,
  }) async {
    await _db.collection('feedback').add({
      'userId': userId,
      'detectionId': detectionId,
      'originalLabel': originalLabel,
      'correctedLabel': correctedLabel,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
