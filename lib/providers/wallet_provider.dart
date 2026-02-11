import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWallet() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/wallet');
      _balance = (data['balance'] ?? 0).toDouble();
      _transactions = List<Map<String, dynamic>>.from(data['transactions'] ?? []);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deposit(double amount) async {
    try {
      final data = await ApiService.post('/wallet/deposit', {'amount': amount});
      _balance = (data['balance'] ?? _balance + amount).toDouble();
      await loadWallet();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> withdraw(double amount) async {
    try {
      final data = await ApiService.post('/wallet/withdraw', {'amount': amount});
      _balance = (data['balance'] ?? _balance - amount).toDouble();
      await loadWallet();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetBalance() async {
    try {
      await ApiService.post('/wallet/reset', {});
      await loadWallet();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
