import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MarketProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _stocks = [];
  List<Map<String, dynamic>> _indices = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _gainers = [];
  List<Map<String, dynamic>> _losers = [];
  Map<String, dynamic>? _selectedStock;
  Map<String, dynamic>? _stockAnalysis;
  Map<String, dynamic>? _stockFundamentals;
  Map<String, dynamic>? _stockChart;
  Map<String, dynamic>? _fundamentalScore;
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isAnalyzing = false;
  bool _isLoadingFundamentals = false;
  bool _isLoadingChart = false;
  String? _error;

  List<Map<String, dynamic>> get stocks => _stocks;
  List<Map<String, dynamic>> get indices => _indices;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<Map<String, dynamic>> get gainers => _gainers;
  List<Map<String, dynamic>> get losers => _losers;
  Map<String, dynamic>? get selectedStock => _selectedStock;
  Map<String, dynamic>? get stockAnalysis => _stockAnalysis;
  Map<String, dynamic>? get stockFundamentals => _stockFundamentals;
  Map<String, dynamic>? get stockChart => _stockChart;
  Map<String, dynamic>? get fundamentalScore => _fundamentalScore;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isAnalyzing => _isAnalyzing;
  bool get isLoadingFundamentals => _isLoadingFundamentals;
  bool get isLoadingChart => _isLoadingChart;
  String? get error => _error;

  Future<void> loadStocks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/market/trending');
      if (data is List) {
        _stocks = List<Map<String, dynamic>>.from(data);
      } else {
        _stocks = List<Map<String, dynamic>>.from(data['stocks'] ?? data['results'] ?? []);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadIndices() async {
    try {
      final data = await ApiService.get('/market/indices');
      _indices = List<Map<String, dynamic>>.from(data['indices'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadGainersLosers() async {
    try {
      final data = await ApiService.get('/market/gainers-losers');
      _gainers = List<Map<String, dynamic>>.from(data['gainers'] ?? []);
      _losers = List<Map<String, dynamic>>.from(data['losers'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> searchStocks(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/market/search?q=$query');
      if (data is List) {
        _searchResults = List<Map<String, dynamic>>.from(data);
      } else {
        _searchResults = List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> getStockQuote(String symbol) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/market/quote/$symbol');
      _selectedStock = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════ AI ANALYSIS — correct endpoint: /ai/analyze/:symbol ═══════
  Future<void> getStockAnalysis(String symbol) async {
    _isAnalyzing = true;
    _stockAnalysis = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/ai/analyze/$symbol');
      _stockAnalysis = data;
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // ═══════ FUNDAMENTALS — /market/fundamentals/:symbol ═══════
  Future<void> getStockFundamentals(String symbol) async {
    _isLoadingFundamentals = true;
    _stockFundamentals = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/market/fundamentals/$symbol');
      _stockFundamentals = data;
      _isLoadingFundamentals = false;
      notifyListeners();
    } catch (e) {
      _isLoadingFundamentals = false;
      notifyListeners();
    }
  }

  // ═══════ FUNDAMENTAL SCORE — /fundamental/score/:symbol ═══════
  Future<void> getFundamentalScore(String symbol) async {
    _fundamentalScore = null;
    try {
      final data = await ApiService.get('/fundamental/score/$symbol');
      _fundamentalScore = data;
      notifyListeners();
    } catch (_) {}
  }

  // ═══════ CHART DATA — /market/chart/:symbol ═══════
  Future<void> getStockChart(String symbol, {String period = '1y', String interval = '1d'}) async {
    _isLoadingChart = true;
    _stockChart = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/market/chart/$symbol?period=$period&interval=$interval');
      _stockChart = data;
      _isLoadingChart = false;
      notifyListeners();
    } catch (e) {
      _isLoadingChart = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  void clearSelectedStock() {
    _selectedStock = null;
    _stockAnalysis = null;
    _stockFundamentals = null;
    _stockChart = null;
    _fundamentalScore = null;
    notifyListeners();
  }

  // ═══════ SCREENER — POST /market/screener ═══════
  List<Map<String, dynamic>> _screenerStocks = [];
  List<Map<String, dynamic>> get screenerStocks => _screenerStocks;

  Future<void> loadScreenerStocks({String sector = 'nifty50'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.post('/market/screener', {'sector': sector});
      _screenerStocks = List<Map<String, dynamic>>.from(data['stocks'] ?? []);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════ FETCH QUOTE ═══════
  Future<Map<String, dynamic>?> fetchQuote(String symbol) async {
    try {
      final data = await ApiService.get('/market/quote/$symbol');
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }
}
