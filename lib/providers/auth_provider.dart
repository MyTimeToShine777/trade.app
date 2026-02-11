import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  double get balance => (_user?['balance'] ?? 0).toDouble();
  String get displayName =>
      _user?['fullName'] ??
      _user?['full_name'] ??
      _user?['username'] ??
      'Guest';

  // Save user data locally so login persists even if backend is unreachable
  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user', jsonEncode(user));
  }

  Future<Map<String, dynamic>?> _loadCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cached_user');
    if (raw != null) {
      try { return jsonDecode(raw) as Map<String, dynamic>; } catch (_) {}
    }
    return null;
  }

  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user');
  }

  Future<void> init() async {
    final token = await ApiService.getToken();
    if (token != null && token.isNotEmpty) {
      // Immediately restore cached user so we're logged in fast
      final cachedUser = await _loadCachedUser();
      if (cachedUser != null) {
        _user = cachedUser;
        _isLoggedIn = true;
        notifyListeners();
      }
      // Then try to refresh from backend (silently)
      try {
        final data = await ApiService.get('/auth/me');
        _user = data['user'] ?? data;
        _isLoggedIn = true;
        await _saveUser(_user!);
      } catch (e) {
        // If we have cached user, stay logged in — don't force re-login
        if (cachedUser == null) {
          await ApiService.clearToken();
          await _clearCachedUser();
          _isLoggedIn = false;
        }
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      await ApiService.setToken(data['token']);
      _user = data['user'];
      _isLoggedIn = true;
      await _saveUser(_user!);
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

  Future<bool> register(
      String username, String fullName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.post('/auth/register', {
        'username': username,
        'fullName': fullName,
        'email': email,
        'password': password,
      });
      await ApiService.setToken(data['token'] ?? '');
      _user = data['user'];
      _isLoggedIn = data['token'] != null;
      if (_user != null) await _saveUser(_user!);
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

  Future<void> logout() async {
    await ApiService.clearToken();
    await _clearCachedUser();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> refreshBalance() async {
    try {
      final data = await ApiService.get('/auth/me');
      _user = data['user'] ?? data;
      await _saveUser(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] refreshBalance failed: $e');
    }
  }
}
