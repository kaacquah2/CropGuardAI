import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/models/community_post.dart';
import '../../domain/repositories/i_community_repository.dart';
import '../remote/firestore_service.dart';

class CommunityRepositoryImpl implements ICommunityRepository {
  final FirestoreService _firestoreService;

  CommunityRepositoryImpl(this._firestoreService);

  @override
  Stream<List<CommunityPost>> getPostsStream() {
    return _firestoreService.postsStream();
  }

  @override
  Future<Result<void>> addPost(CommunityPost post) async {
    try {
      await _firestoreService.addPost(post);
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> requestExpertHelp({
    required String userId,
    required String detectionId,
    required String message,
    required String diseaseName,
  }) async {
    try {
      await _firestoreService.requestExpertHelp(
        userId: userId,
        detectionId: detectionId,
        message: message,
        diseaseName: diseaseName,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> uploadScan(Map<String, dynamic> scanData) async {
    try {
      await _firestoreService.uploadScan(scanData);
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getUserProfile(String uid) async {
    try {
      final data = await _firestoreService.getUserProfile(uid);
      return Result.success(data);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateUserProfile(uid, data);
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getOutbreakReports() async {
    try {
      final reports = await _firestoreService.getOutbreakReports();
      return Result.success(reports);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> submitFeedback({
    required String userId,
    required int detectionId,
    required String originalLabel,
    required String correctedLabel,
  }) async {
    try {
      await _firestoreService.submitFeedback(
        userId: userId,
        detectionId: detectionId,
        originalLabel: originalLabel,
        correctedLabel: correctedLabel,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
