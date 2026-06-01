import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/utils/background_tasks.dart';
import '../../../data/local/database_helper.dart';
import '../../../data/remote/firebase_auth_service.dart';
import '../../../data/remote/firestore_service.dart';
import '../../../domain/models/treatment_plan.dart';

class TreatmentTrackerProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  final FirebaseAuthService _auth;
  final FirestoreService _firestore;

  TreatmentTrackerProvider(this._db, this._auth, this._firestore) {
    _load();
  }

  List<TreatmentPlan> plans = [];
  bool isLoading = true;
  String? error;

  String get _userId => _auth.currentUserId;
  bool get _isGuest => _userId == 'guest';

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      plans = await _db.getAllTreatments(userId: _userId);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addTreatmentPlan({
    required String crop,
    required String disease,
    required List<String> steps,
    int detectionId = 0,
  }) async {
    final now = DateTime.now();
    final dueDays = <int>[1, 3, 7];
    final normalizedSteps = List<String>.generate(
      dueDays.length,
      (i) => i < steps.length ? steps[i] : 'Follow-up check for $disease',
    );

    for (var i = 0; i < dueDays.length; i++) {
      final dueDate = now.add(Duration(days: dueDays[i]));
      final plan = TreatmentPlan(
        id: '',
        userId: _userId,
        detectionId: detectionId,
        cropType: crop,
        diseaseName: disease,
        step: normalizedSteps[i],
        completed: false,
        dueDate: dueDate,
        createdAt: now,
      );

      final id = await _db.insertTreatment(plan);
      BackgroundTaskHelper.scheduleReminder(
        disease,
        dueDays[i],
        Duration(days: dueDays[i]),
      );

      if (!_isGuest) {
        unawaited(
          _firestore.addTreatment({
            ...plan.copyWith(completed: false).toMap(),
            'id': id,
          }),
        );
      }
    }

    await _load();
  }

  Future<void> addFromDetection({
    required int detectionId,
    required String cropType,
    required String diseaseName,
    required List<String> treatmentSteps,
  }) async {
    await addTreatmentPlan(
      crop: cropType,
      disease: diseaseName,
      steps: treatmentSteps,
      detectionId: detectionId,
    );
  }

  Future<void> toggleComplete(int index) async {
    final plan = plans[index];
    final updated = !plan.completed;
    await _db.updateTreatmentCompleted(plan.id, updated);
    plans[index] = plan.copyWith(completed: updated);
    notifyListeners();

    if (!_isGuest) {
      unawaited(
        _firestore.updateTreatment(plan.id, {'completed': updated ? 1 : 0}),
      );
    }
  }

  Future<void> deletePlan(String id) async {
    await _db.deleteTreatment(id);
    await _load();
  }

  Future<void> refresh() => _load();
}
