import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class PortfolioProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _holdings = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _watchlist = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get holdings => _holdings;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get watchlist => _watchlist;
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalInvested {
    double total = 0;
    for (var h in _holdings) {
      total += (h['quantity'] ?? 0) * (h['avg_price'] ?? h['avgPrice'] ?? 0);
    }
    return total;
  }

  double get totalCurrent {
    double total = 0;
    for (var h in _holdings) {
      total += (h['quantity'] ?? 0) *
          (h['current_price'] ?? h['currentPrice'] ?? h['avg_price'] ?? 0);
    }
    return total;
  }

  double get totalPnl => totalCurrent - totalInvested;
  double get totalPnlPercent =>
      totalInvested > 0 ? (totalPnl / totalInvested * 100) : 0;

  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/trading/portfolio');
      _holdings = List<Map<String, dynamic>>.from(data['holdings'] ?? []);
      _summary = data['summary'] ?? {};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    try {
      final data = await ApiService.get('/trading/orders');
      _orders = List<Map<String, dynamic>>.from(data['orders'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadTransactions() async {
    try {
      final data = await ApiService.get('/trading/transactions');
      _transactions =
          List<Map<String, dynamic>>.from(data['transactions'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String name,
    required String type,
    required int quantity,
    required double price,
    String assetType = 'STOCK',
  }) async {
    try {
      final data = await ApiService.post('/trading/order', {
        'symbol': symbol,
        'name': name,
        'side': type,
        'orderType': 'MARKET',
        'quantity': quantity,
        'price': price,
        'asset_type': assetType,
      });
      await loadPortfolio();

      // Send trade notification
      final isBuy = type.toUpperCase() == 'BUY';
      final total = (quantity * price).toStringAsFixed(2);
      NotificationService.showTradeNotification(
        title: '${isBuy ? "📈" : "📉"} ${type.toUpperCase()} Order Executed',
        body: '$symbol · $quantity shares @ ₹${price.toStringAsFixed(2)} = ₹$total',
        payload: symbol,
      );

      // Send P&L notification if portfolio has been loaded
      if (totalInvested > 0) {
        NotificationService.showPortfolioSummary(
          totalPnl: totalPnl,
          pnlPercent: totalPnlPercent,
        );
      }

      return data;
    } catch (e) {
      throw e;
    }
  }

  // Watchlist methods
  Future<void> loadWatchlist() async {
    try {
      final data = await ApiService.get('/watchlist');
      _watchlist = List<Map<String, dynamic>>.from(data['watchlist'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addToWatchlist(String symbol, String name) async {
    try {
      await ApiService.post('/watchlist', {'symbol': symbol, 'name': name});
      await loadWatchlist();
    } catch (e) {
      throw e;
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    try {
      await ApiService.del('/watchlist/$symbol');
      _watchlist.removeWhere((item) => item['symbol'] == symbol);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  bool isInWatchlist(String symbol) {
    return _watchlist.any((item) => item['symbol'] == symbol);
  }
}
