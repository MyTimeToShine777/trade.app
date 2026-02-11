import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SipProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _calculator;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get plans => _plans;
  Map<String, dynamic>? get calculator => _calculator;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/sip');
      _plans = List<Map<String, dynamic>>.from(data['plans'] ?? data['sips'] ?? []);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlan(Map<String, dynamic> plan) async {
    try {
      await ApiService.post('/sip', plan);
      await loadPlans();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePlan(String id, bool active) async {
    try {
      await ApiService.put('/sip/$id', {'active': active});
      await loadPlans();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> cancelPlan(String id) async {
    try {
      await ApiService.del('/sip/$id');
      await loadPlans();
      return true;
    } catch (e) { return false; }
  }

  void calculate({required double amount, required int years, required double returns}) {
    final months = years * 12;
    final r = returns / 12 / 100;
    // SIP Future Value formula: P × [((1+r)^n - 1) / r] × (1+r)
    final compoundFactor = _pow(1 + r, months);
    final futureValue = amount * ((compoundFactor - 1) / r) * (1 + r);
    final totalInvested = amount * months;
    _calculator = {
      'futureValue': futureValue,
      'totalInvested': totalInvested,
      'gains': futureValue - totalInvested,
    };
    notifyListeners();
  }

  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
