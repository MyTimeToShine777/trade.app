import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/market_provider.dart';

class ScreenerScreen extends StatefulWidget {
  const ScreenerScreen({super.key});
  @override
  State<ScreenerScreen> createState() => _ScreenerScreenState();
}

class _ScreenerScreenState extends State<ScreenerScreen> {
  String _sector = 'nifty50';
  String _sortBy = 'name';
  bool _loaded = false;
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  final _sectors = [
    {'label': '🏠 All', 'value': 'nifty50'},
    {'label': '🔮 Next50', 'value': 'niftyNext50'},
    {'label': '💻 IT', 'value': 'it'},
    {'label': '🏦 Banking', 'value': 'banking'},
    {'label': '💊 Pharma', 'value': 'pharma'},
    {'label': '🚗 Auto', 'value': 'auto'},
    {'label': '⚡ Energy', 'value': 'energy'},
    {'label': '🛒 FMCG', 'value': 'fmcg'},
    {'label': '⛏️ Metal', 'value': 'metals'},
    {'label': '🏗️ Realty', 'value': 'realty'},
    {'label': '💰 Finance', 'value': 'finance'},
  ];

  final _sortOptions = [
    {'label': '🔤 Name', 'value': 'name'},
    {'label': '💰 Price', 'value': 'price'},
    {'label': '📈 Change', 'value': 'change'},
    {'label': '📊 PE', 'value': 'pe'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) => _loadScreener()); }
  }

  void _loadScreener() {
    context.read<MarketProvider>().loadScreenerStocks(sector: _sector);
  }

  List<Map<String, dynamic>> _sortStocks(List<Map<String, dynamic>> stocks) {
    final sorted = List<Map<String, dynamic>>.from(stocks);
    sorted.sort((a, b) {
      switch (_sortBy) {
        case 'price': return ((b['price'] ?? 0) as num).compareTo((a['price'] ?? 0) as num);
        case 'change': return ((b['changePercent'] ?? b['change_percent'] ?? 0) as num).compareTo((a['changePercent'] ?? a['change_percent'] ?? 0) as num);
        case 'pe': return ((a['pe'] ?? 999) as num).compareTo((b['pe'] ?? 999) as num);
        default: return (a['symbol'] ?? '').toString().compareTo((b['symbol'] ?? '').toString());
      }
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final stocks = _sortStocks(market.screenerStocks);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                child: Center(child: Text('←', style: TextStyle(fontSize: 20, color: AppTheme.textPrimary))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text('🔍 Screener', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        // Sector filters
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📊 SECTOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
              children: _sectors.map((s) => Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
                onTap: () { setState(() => _sector = s['value']!); _loadScreener(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _sector == s['value'] ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _sector == s['value'] ? AppTheme.accent : AppTheme.border),
                  ),
                  child: Text(s['label']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _sector == s['value'] ? AppTheme.accent : AppTheme.textSecondary)),
                ),
              ))).toList(),
            )),
          ]),
        )),

        // Sort options
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [
            Text('⚙️ Sort: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
            ..._sortOptions.map((s) => Padding(padding: const EdgeInsets.only(right: 6), child: GestureDetector(
              onTap: () => setState(() => _sortBy = s['value']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _sortBy == s['value'] ? AppTheme.accent : AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8)),
                child: Text(s['label']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _sortBy == s['value'] ? Colors.white : AppTheme.textSecondary)),
              ),
            ))),
          ]),
        )),

        // Results count
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text('${stocks.length} stocks found 📋', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        )),

        if (market.isLoading)
          const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.accent))))
        else SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) => _enhancedStockTile(stocks[i]),
          childCount: stocks.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }

  Widget _enhancedStockTile(Map<String, dynamic> s) {
    final price = (s['price'] ?? s['currentPrice'] ?? 0).toDouble();
    final change = (s['changePercent'] ?? s['change_percent'] ?? 0).toDouble();
    final isPos = change >= 0;
    final pe = (s['pe'] ?? 0).toDouble();
    final marketCap = (s['marketCap'] ?? 0).toDouble();
    final high52 = (s['fiftyTwoWeekHigh'] ?? s['high52'] ?? 0).toDouble();
    final low52 = (s['fiftyTwoWeekLow'] ?? s['low52'] ?? 0).toDouble();
    final volume = (s['volume'] ?? 0).toDouble();
    final healthScore = (s['healthScore'] ?? 0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ClayCard(
        depth: 0.4, padding: const EdgeInsets.all(14), borderRadius: 16,
        onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: s['symbol']),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: isPos ? AppTheme.greenGradient : AppTheme.redGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text((s['symbol'] ?? '?')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['symbol'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Text(s['name'] ?? '', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_fmt.format(price), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: (isPos ? AppTheme.green : AppTheme.red).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(isPos ? '📈' : '📉', style: const TextStyle(fontSize: 9)),
                  const SizedBox(width: 2),
                  Text('${isPos ? '+' : ''}${change.toStringAsFixed(2)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPos ? AppTheme.green : AppTheme.red)),
                ]),
              ),
            ]),
          ]),
          const SizedBox(height: 8),
          // Extra metrics row
          Row(children: [
            if (pe > 0) _metric('P/E', pe.toStringAsFixed(1), pe < 15 ? AppTheme.green : pe > 30 ? AppTheme.red : null),
            if (marketCap > 0) _metric('MCap', _fmtNum(marketCap), null),
            if (volume > 0) _metric('Vol', _fmtNum(volume), null),
            if (healthScore > 0) _metric('Health', '${healthScore.toInt()}', healthScore > 60 ? AppTheme.green : AppTheme.orange),
            if (high52 > 0 && low52 > 0) _metric('52W', '${low52.toInt()}-${high52.toInt()}', null),
          ]),
        ]),
      ),
    );
  }

  Widget _metric(String label, String value, Color? c) => Expanded(child: Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 9, color: AppTheme.textLight)),
      Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c ?? AppTheme.textSecondary)),
    ]),
  ));

  String _fmtNum(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
