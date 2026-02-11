import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/portfolio_provider.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PortfolioProvider>().loadWatchlist()); }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PortfolioProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(child: Text('Watchlist (${p.watchlist.length})', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        if (p.watchlist.isEmpty)
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(60), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.visibility_off, size: 60, color: AppTheme.textLight),
            const SizedBox(height: 12),
            const Text('Watchlist is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            const Text('Add stocks from Trade or Stock Detail', style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
          ])))
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
                      Expanded(child: Text(w['symbol'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      GestureDetector(
                        onTap: () async { await p.removeFromWatchlist(w['symbol']); },
                        child: const Icon(Icons.close, size: 16, color: AppTheme.textLight),
                      ),
                    ]),
                    Text(w['name'] ?? '', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Text(price > 0 ? _fmt.format(price) : '--', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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
      ])),
    );
  }
}
