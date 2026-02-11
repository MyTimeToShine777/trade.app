import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AutoInvestProvider extends ChangeNotifier {
  Map<String, dynamic>? _plan;
  Map<String, dynamic>? _research;
  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _picks = [];
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _learningData;
  Map<String, dynamic>? _monthlyBudget;
  bool _isLoading = false;
  bool _isResearching = false;
  bool _isExecuting = false;
  String? _error;

  Map<String, dynamic>? get plan => _plan;
  Map<String, dynamic>? get research => _research;
  Map<String, dynamic>? get dashboard => _dashboard;
  List<Map<String, dynamic>> get picks => _picks;
  List<Map<String, dynamic>> get history => _history;
  Map<String, dynamic>? get learningData => _learningData;
  Map<String, dynamic>? get monthlyBudget => _monthlyBudget;
  bool get isLoading => _isLoading;
  bool get isResearching => _isResearching;
  bool get isExecuting => _isExecuting;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/auto-invest/dashboard');
      _dashboard = data;
      _plan = data['plan'];
      _picks = List<Map<String, dynamic>>.from(data['recentPicks'] ?? []);
      _history = List<Map<String, dynamic>>.from(data['history'] ?? []);
      _learningData = data['learningData'] != null
          ? Map<String, dynamic>.from(data['learningData'])
          : null;
      _monthlyBudget = data['monthlyBudget'] != null
          ? Map<String, dynamic>.from(data['monthlyBudget'])
          : null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlan({
    String name = '',
    required double monthlyBudget,
    required String riskLevel,
    required List<String> assetTypes,
    String strategy = 'balanced',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        'monthlyBudget': monthlyBudget,
        'riskLevel': riskLevel,
        'assetTypes': assetTypes,
        'strategy': strategy,
      };
      if (name.isNotEmpty) body['name'] = name;
      final data = await ApiService.post('/auto-invest/plan', body);
      _plan = data['plan'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> pausePlan() async {
    try {
      await ApiService.post('/auto-invest/plan/pause', {});
      if (_plan != null) _plan!['status'] = 'paused';
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resumePlan() async {
    try {
      await ApiService.post('/auto-invest/plan/resume', {});
      if (_plan != null) _plan!['status'] = 'active';
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelPlan() async {
    try {
      await ApiService.delete('/auto-invest/plan');
      _plan = null;
      _picks = [];
      _monthlyBudget = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> runResearch() async {
    _isResearching = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.post('/auto-invest/research', {});
      _research = data;
      _picks = List<Map<String, dynamic>>.from(data['picks'] ?? []);
      _learningData = data['learningData'] != null
          ? Map<String, dynamic>.from(data['learningData'])
          : null;
      _monthlyBudget = {
        'budget': data['monthlyBudget'],
        'spent': data['monthSpent'],
        'remaining': data['monthRemaining'],
        'month': data['month'],
      };
      _isResearching = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isResearching = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> executePicks() async {
    _isExecuting = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.post('/auto-invest/execute', {});
      _monthlyBudget = {
        'budget': data['monthlyBudget'],
        'spent': data['monthSpent'],
        'remaining': data['monthRemaining'],
        'month': data['month'],
      };
      _isExecuting = false;
      notifyListeners();
      await loadDashboard();
      return true;
    } catch (e) {
      _error = e.toString();
      _isExecuting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadHistory() async {
    try {
      final data = await ApiService.get('/auto-invest/history');
      _history = List<Map<String, dynamic>>.from(data['history'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
