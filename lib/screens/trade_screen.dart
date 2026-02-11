import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});
  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  final _searchCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) { context.read<MarketProvider>().loadStocks(); context.read<MarketProvider>().loadGainersLosers(); }); }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    return SafeArea(
      child: CustomScrollView(slivers: [
        // Header
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                child: const Center(child: Text('☰', style: TextStyle(fontSize: 18, color: AppTheme.textPrimary))),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Text('📈 Trade', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        // Search
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: ClayInput(
            controller: _searchCtrl,
            hintText: 'Search stocks...',
            prefixIcon: Icons.search,
            onChanged: (q) => context.read<MarketProvider>().searchStocks(q),
            suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); context.read<MarketProvider>().clearSearch(); }) : null,
          ),
        )),

        // Search results
        if (market.searchResults.isNotEmpty) ...[
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Text('🔍 Search Results', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)))),
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, i) => _stockTile(market.searchResults[i]),
            childCount: market.searchResults.length.clamp(0, 15),
          )),
        ] else ...[
          // Trending / All stocks
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(children: [
              const Text('📈', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text('All Stocks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const Spacer(),
              Text('${market.stocks.length} stocks 📊', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          )),

          if (market.isLoading)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.accent))))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _stockTile(market.stocks[i]),
              childCount: market.stocks.length,
            )),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ]),
    );
  }

  Widget _stockTile(Map<String, dynamic> stock) {
    final price = (stock['price'] ?? stock['currentPrice'] ?? stock['regularMarketPrice'] ?? 0).toDouble();
    final change = (stock['changePercent'] ?? stock['change_percent'] ?? stock['regularMarketChangePercent'] ?? 0).toDouble();
    final isPos = change >= 0;
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ClayCard(
        depth: 0.4, padding: const EdgeInsets.all(14), borderRadius: 16,
        onTap: () => _showTradeSheet(stock),
        child: Row(children: [
          // Icon
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: isPos ? AppTheme.greenGradient : AppTheme.redGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text((stock['symbol'] ?? '?')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stock['symbol'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text(stock['name'] ?? stock['longName'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(fmt.format(price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: (isPos ? AppTheme.green : AppTheme.red).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${isPos ? '+' : ''}${change.toStringAsFixed(2)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPos ? AppTheme.green : AppTheme.red)),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showTradeSheet(Map<String, dynamic> stock) {
    final price = (stock['price'] ?? stock['currentPrice'] ?? stock['regularMarketPrice'] ?? 0).toDouble();
    final qtyCtrl = TextEditingController(text: '1');
    String orderType = 'BUY';
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        final qty = int.tryParse(qtyCtrl.text) ?? 0;
        final total = price * qty;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(stock['symbol'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                Text(stock['name'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ])),
              Text(fmt.format(price), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            ]),
            const SizedBox(height: 20),
            // BUY/SELL toggle
            Row(children: [
              Expanded(child: ClayChip(label: 'BUY', icon: Icons.arrow_upward, isActive: orderType == 'BUY', onTap: () => setSheetState(() => orderType = 'BUY'))),
              const SizedBox(width: 8),
              Expanded(child: ClayChip(label: 'SELL', icon: Icons.arrow_downward, isActive: orderType == 'SELL', onTap: () => setSheetState(() => orderType = 'SELL'))),
            ]),
            const SizedBox(height: 16),
            ClayInput(controller: qtyCtrl, labelText: 'QUANTITY', hintText: '1', prefixIcon: Icons.numbers, keyboardType: TextInputType.number, onChanged: (_) => setSheetState(() {})),
            const SizedBox(height: 16),
            ClayCard(depth: 0.4, padding: const EdgeInsets.all(14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Estimated Total', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text(fmt.format(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ])),
            const SizedBox(height: 20),
            ClayButton(
              gradient: orderType == 'BUY' ? AppTheme.greenGradient : AppTheme.redGradient,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                try {
                  await context.read<PortfolioProvider>().placeOrder(
                    symbol: stock['symbol'] ?? '', name: stock['name'] ?? '', type: orderType,
                    quantity: qty, price: price,
                  );
                  if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${orderType} order placed!'), backgroundColor: orderType == 'BUY' ? AppTheme.green : AppTheme.red)); }
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.red));
                }
              },
              child: Text('$orderType ${stock['symbol'] ?? ''} ✨', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      }),
    );
  }
}
