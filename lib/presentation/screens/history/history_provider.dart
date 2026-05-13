import 'package:flutter/material.dart';
import '../../../domain/models/detection_result.dart';
import '../../../domain/usecases/history/get_history_usecase.dart';
import '../../../domain/usecases/history/delete_detection_usecase.dart';

enum HistoryFilter { all, healthy, diseased }

/// Refactored HistoryProvider using Clean Architecture
class HistoryProvider extends ChangeNotifier {
  final GetHistoryUseCase _getHistoryUseCase;
  final DeleteDetectionUseCase _deleteDetectionUseCase;

  HistoryProvider(this._getHistoryUseCase, this._deleteDetectionUseCase) {
    load();
  }

  List<DetectionResult> _all = [];
  List<DetectionResult> filtered = [];
  HistoryFilter filter = HistoryFilter.all;
  String searchQuery = '';
  bool isLoading = true;
  bool comparisonMode = false;
  Set<int> selectedIds = {};

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    
    final result = await _getHistoryUseCase();
    if (result.isSuccess) {
      _all = result.data ?? [];
    }
    
    _applyFilter();
    isLoading = false;
    notifyListeners();
  }

  void setFilter(HistoryFilter f) {
    filter = f;
    _applyFilter();
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q;
    _applyFilter();
    notifyListeners();
  }

  void toggleComparison() {
    comparisonMode = !comparisonMode;
    selectedIds.clear();
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else if (selectedIds.length < 2) {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> deleteResult(int id) async {
    final result = await _deleteDetectionUseCase(id);
    if (result.isSuccess) {
      await load();
    }
  }

  void _applyFilter() {
    var list = _all;
    switch (filter) {
      case HistoryFilter.healthy:
        list = list.where((r) => r.isHealthy).toList();
        break;
      case HistoryFilter.diseased:
        list = list.where((r) => !r.isHealthy).toList();
        break;
      case HistoryFilter.all:
        break;
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((r) =>
              r.displayName.toLowerCase().contains(q) ||
              r.cropType.toLowerCase().contains(q))
          .toList();
    }
    filtered = list;
  }
}

