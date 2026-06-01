import 'package:flutter/material.dart';
import '../../../domain/models/detection_result.dart';
import '../../../domain/usecases/history/get_history_usecase.dart';
import '../../../domain/usecases/history/delete_detection_usecase.dart';
import '../../../domain/usecases/history/restore_detection_usecase.dart';

enum HistoryFilter { all, healthy, diseased }

enum HistorySort { dateNewest, dateOldest, severity, cropType }

/// Refactored HistoryProvider using Clean Architecture
class HistoryProvider extends ChangeNotifier {
  final GetHistoryUseCase _getHistoryUseCase;
  final DeleteDetectionUseCase _deleteDetectionUseCase;
  final RestoreDetectionUseCase _restoreDetectionUseCase;

  HistoryProvider(this._getHistoryUseCase, this._deleteDetectionUseCase, this._restoreDetectionUseCase) {
    load();
  }

  List<DetectionResult> _all = [];
  List<DetectionResult> filtered = [];
  HistoryFilter filter = HistoryFilter.all;
  HistorySort sort = HistorySort.dateNewest;
  String searchQuery = '';
  bool isLoading = true;

  // Comparison mode state
  bool comparisonMode = false;
  List<int> selectedIds = [];

  void toggleComparisonMode() {
    comparisonMode = !comparisonMode;
    selectedIds.clear();
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      if (selectedIds.length < 2) {
        selectedIds.add(id);
      } else {
        selectedIds.removeAt(0);
        selectedIds.add(id);
      }
    }
    notifyListeners();
  }

  List<DetectionResult> get selectedScans =>
      _all.where((r) => selectedIds.contains(r.id)).toList();

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

  void setSort(HistorySort s) {
    sort = s;
    _applyFilter();
    notifyListeners();
  }

  Future<void> exportHistory() async {
    // Export handled in UI via ScanReportPdfExporter per scan.
  }

  Future<void> deleteResult(int id) async {
    final result = await _deleteDetectionUseCase(id);
    if (result.isSuccess) {
      await load();
    }
  }

  Future<void> restoreDetection(DetectionResult detection) async {
    final result = await _restoreDetectionUseCase(detection);
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
    switch (sort) {
      case HistorySort.dateOldest:
        list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case HistorySort.severity:
        list.sort((a, b) => b.confidence.compareTo(a.confidence));
        break;
      case HistorySort.cropType:
        list.sort((a, b) => a.cropType.compareTo(b.cropType));
        break;
      case HistorySort.dateNewest:
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
    }
    filtered = list;
  }
}

