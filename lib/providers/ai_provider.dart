import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AiProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _chatMessages = [];
  Map<String, dynamic>? _analysis;
  Map<String, dynamic>? _comparison;
  Map<String, dynamic>? _sentiment;
  Map<String, dynamic>? _portfolioAnalysis;
  bool _isChatLoading = false;
  bool _isAnalyzing = false;
  bool _isComparing = false;
  bool _isSentimentLoading = false;
  bool _isPortfolioAnalyzing = false;
  String? _error;

  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  Map<String, dynamic>? get analysis => _analysis;
  Map<String, dynamic>? get comparison => _comparison;
  Map<String, dynamic>? get sentiment => _sentiment;
  Map<String, dynamic>? get portfolioAnalysis => _portfolioAnalysis;
  bool get isChatLoading => _isChatLoading;
  bool get isAnalyzing => _isAnalyzing;
  bool get isComparing => _isComparing;
  bool get isSentimentLoading => _isSentimentLoading;
  bool get isPortfolioAnalyzing => _isPortfolioAnalyzing;
  String? get error => _error;

  Future<void> sendChat(String message) async {
    _chatMessages.add({
      'role': 'user',
      'content': message,
      'timestamp': DateTime.now().toIso8601String()
    });
    _isChatLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Send conversation history for context
      final history = _chatMessages
          .where((m) => m['role'] == 'user' || m['role'] == 'assistant')
          .map((m) => {'role': m['role'], 'content': m['content']})
          .toList();
      final data = await ApiService.post('/ai/chat', {
        'message': message,
        'history': history.length > 1 ? history.sublist(0, history.length - 1) : [],
      });
      _chatMessages.add({
        'role': 'assistant',
        'content': data['response'] ?? data['message'] ?? '',
        'timestamp': DateTime.now().toIso8601String()
      });
      _isChatLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _chatMessages.add({
        'role': 'assistant',
        'content': 'Sorry, I encountered an error: ${e.toString()}. Please try again.',
        'timestamp': DateTime.now().toIso8601String()
      });
      _isChatLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeStock(String symbol) async {
    _isAnalyzing = true;
    _analysis = null;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/ai/analyze/$symbol');
      _analysis = data;
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> compareStocks(List<String> symbols) async {
    _isComparing = true;
    _comparison = null;
    _error = null;
    notifyListeners();
    try {
      final s1 = symbols.isNotEmpty ? symbols[0] : '';
      final s2 = symbols.length > 1 ? symbols[1] : '';
      final data =
          await ApiService.post('/ai/compare', {'symbol1': s1, 'symbol2': s2});
      _comparison = data;
      _isComparing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isComparing = false;
      notifyListeners();
    }
  }

  Future<void> getSentiment() async {
    _isSentimentLoading = true;
    _sentiment = null;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/ai/sentiment');
      _sentiment = data;
      _isSentimentLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isSentimentLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPortfolioAnalysis() async {
    _isPortfolioAnalyzing = true;
    _portfolioAnalysis = null;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/ai/portfolio-analysis');
      _portfolioAnalysis = data;
      _isPortfolioAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isPortfolioAnalyzing = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatMessages = [];
    notifyListeners();
  }

  void clearAnalysis() {
    _analysis = null;
    _comparison = null;
    _sentiment = null;
    _portfolioAnalysis = null;
    notifyListeners();
  }
}
