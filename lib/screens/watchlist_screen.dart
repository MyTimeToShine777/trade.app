import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/portfolio_provider.dart';
import '../providers/market_provider.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final _searchCtrl = TextEditingController();
  bool _loaded = false;
  bool _showSearch = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PortfolioProvider>().loadWatchlist());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchStock(String q) async {
    if (q.length < 2) { setState(() => _searchResults = []); return; }
    setState(() => _isSearching = true);
    try {
      final market = context.read<MarketProvider>();
      await market.searchStocks(q);
      if (mounted) setState(() { _searchResults = market.searchResults; _isSearching = false; });
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PortfolioProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () async => context.read<PortfolioProvider>().loadWatchlist(),
          child: CustomScrollView(slivers: [
            // Header
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                const SizedBox(width: 14),
                Expanded(child: Text('Watchlist (${p.watchlist.length})', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
                GestureDetector(
                  onTap: () => setState(() { _showSearch = !_showSearch; _searchResults = []; _searchCtrl.clear(); }),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _showSearch ? AppTheme.accent : AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                    child: Center(child: Text(_showSearch ? '✕' : '➕', style: TextStyle(fontSize: 16, color: _showSearch ? Colors.white : AppTheme.textPrimary))),
                  ),
                ),
              ]),
            )),

            // Search bar
            if (_showSearch) SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search stocks to add…',
                      hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                      border: InputBorder.none,
                      icon: Text('🔍', style: TextStyle(fontSize: 16)),
                    ),
                    onChanged: _searchStock,
                  ),
                ),
                if (_isSearching)
                  const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))),
                if (_searchResults.isNotEmpty) Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _searchResults.length.clamp(0, 8),
                    separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.border.withValues(alpha: 0.5)),
                    itemBuilder: (_, i) {
                      final r = _searchResults[i];
                      final sym = r['symbol'] ?? '';
                      final name = r['name'] ?? r['longName'] ?? '';
                      return ListTile(
                        dense: true,
                        title: Text(sym, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        subtitle: Text(name, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: GestureDetector(
                          onTap: () async {
                            await p.addToWatchlist(sym, name);
                            if (mounted) {
                              setState(() { _searchResults = []; _searchCtrl.clear(); _showSearch = false; });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$sym added to watchlist ⭐')));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            )),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Loading
            if (p.isLoading)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator(color: AppTheme.accent))))
            // Empty
            else if (p.watchlist.isEmpty)
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(60), child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('👀', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Watchlist is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Text('Tap ➕ above to search and add stocks', style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
              ])))
            // Grid
            else SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final w = p.watchlist[i];
                    final price = (w['current_price'] ?? w['price'] ?? 0).toDouble();
                    final change = (w['changePercent'] ?? w['change_percent'] ?? 0).toDouble();
                    final isPos = change >= 0;
                    return ClayCard(
                      depth: 0.6, padding: const EdgeInsets.all(14), borderRadius: 18,
                      onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: w['symbol']),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(w['symbol'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          GestureDetector(
                            onTap: () async { await p.removeFromWatchlist(w['symbol']); },
                            child: Icon(Icons.close, size: 16, color: AppTheme.textLight),
                          ),
                        ]),
                        Text(w['name'] ?? '', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Text(price > 0 ? _fmt.format(price) : '--', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: (isPos ? AppTheme.green : AppTheme.red).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                          child: Text('${isPos ? '+' : ''}${change.toStringAsFixed(2)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isPos ? AppTheme.green : AppTheme.red)),
                        ),
                      ]),
                    );
                  },
                  childCount: p.watchlist.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ]),
        ),
      ),
    );
  }
}
