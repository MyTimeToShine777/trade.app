import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/auth_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/market_provider.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;
  const DashboardScreen({super.key, this.onSwitchTab});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }
  }

  void _loadData() {
    context.read<PortfolioProvider>().loadPortfolio();
    context.read<PortfolioProvider>().loadWatchlist();
    context.read<MarketProvider>().loadGainersLosers();
    context.read<AuthProvider>().refreshBalance();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final market = context.watch<MarketProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppTheme.accent,
        child: CustomScrollView(slivers: [
          // App bar
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
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good ${_greeting()} 👋', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text(auth.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              ])),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                child: const Center(child: Text('🔔', style: TextStyle(fontSize: 18))),
              ),
            ]),
          )),

          // Balance card
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ClayCard(
              gradient: AppTheme.accentGradient,
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Text('💼', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text('Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 12),
                Text(_fmt.format(auth.balance + portfolio.totalCurrent), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 8),
                Row(children: [
                  _pnlBadge(portfolio.totalPnl, portfolio.totalPnlPercent),
                  const Spacer(),
                  Text('Balance: ${_fmt.format(auth.balance)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ]),
            ),
          )),

          // Stats grid
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Expanded(child: _emojiStat('📦', 'Holdings', '${portfolio.holdings.length}', AppTheme.blueGradient)),
              const SizedBox(width: 12),
              Expanded(child: _emojiStat('📈', 'Invested', _fmtShort(portfolio.totalInvested), AppTheme.greenGradient, subtitle: '${portfolio.totalPnlPercent.toStringAsFixed(1)}%')),
            ]),
          )),

          // Quick actions
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              _emojiAction('📈', 'Trade', AppTheme.accentGradient, () => widget.onSwitchTab?.call(1)),
              const SizedBox(width: 12),
              _emojiAction('💰', 'Wallet', AppTheme.greenGradient, () => Navigator.pushNamed(context, '/wallet')),
              const SizedBox(width: 12),
              _emojiAction('🤖', 'AI Chat', AppTheme.pinkGradient, () => widget.onSwitchTab?.call(3)),
              const SizedBox(width: 12),
              _emojiAction('🔄', 'SIP', AppTheme.goldGradient, () => Navigator.pushNamed(context, '/sip')),
            ]),
          )),

          // Top Gainers
          SliverToBoxAdapter(child: _sectionHeader('🚀 Top Gainers', null, AppTheme.green)),
          SliverToBoxAdapter(child: SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: market.gainers.length.clamp(0, 6),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _stockMiniCard(market.gainers[i], true),
            ),
          )),

          // Top Losers
          SliverToBoxAdapter(child: _sectionHeader('📉 Top Losers', null, AppTheme.red)),
          SliverToBoxAdapter(child: SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: market.losers.length.clamp(0, 6),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _stockMiniCard(market.losers[i], false),
            ),
          )),

          // Holdings
          if (portfolio.holdings.isNotEmpty) ...[
            SliverToBoxAdapter(child: _sectionHeader('💼 Your Holdings', null, AppTheme.accent)),
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _holdingTile(portfolio.holdings[i]),
              childCount: portfolio.holdings.length.clamp(0, 5),
            )),
          ],

          // Watchlist
          if (portfolio.watchlist.isNotEmpty) ...[
            SliverToBoxAdapter(child: _sectionHeader('⭐ Watchlist', null, AppTheme.blue)),
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _watchlistTile(portfolio.watchlist[i]),
              childCount: portfolio.watchlist.length.clamp(0, 5),
            )),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _pnlBadge(double pnl, double pct) {
    final isPos = pnl >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(isPos ? '📈' : '📉', style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text('${isPos ? '+' : ''}${_fmt.format(pnl)} (${pct.toStringAsFixed(1)}%)', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  String _fmtShort(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
    return _fmt.format(v);
  }

  Widget _emojiAction(String emoji, String label, Gradient grad, VoidCallback onTap) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.glowShadow(AppTheme.accent, intensity: 0.15)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ]),
    ));
  }

  Widget _emojiStat(String emoji, String label, String value, Gradient grad, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _sectionHeader(String title, IconData? icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
    );
  }

  Widget _stockMiniCard(Map<String, dynamic> stock, bool isGainer) {
    final price = (stock['price'] ?? stock['currentPrice'] ?? 0).toDouble();
    final change = (stock['changePercent'] ?? stock['change_percent'] ?? 0).toDouble();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: stock['symbol']),
      child: Container(
        width: 140, padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor, 
          borderRadius: BorderRadius.circular(18), 
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(stock['symbol'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text(_fmt.format(price), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: (isGainer ? AppTheme.green : AppTheme.red).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isGainer ? AppTheme.green : AppTheme.red)),
          ),
        ]),
      ),
    );
  }

  Widget _holdingTile(Map<String, dynamic> h) {
    final qty = (h['quantity'] ?? 0);
    final avg = (h['avg_price'] ?? h['avgPrice'] ?? 0).toDouble();
    final cur = (h['current_price'] ?? h['currentPrice'] ?? avg).toDouble();
    final pnl = (cur - avg) * qty;
    final pct = avg > 0 ? ((cur - avg) / avg * 100) : 0.0;
    final isPos = pnl >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ClayCard(
        depth: 0.5, padding: const EdgeInsets.all(14), borderRadius: 16,
        onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: h['symbol']),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h['symbol'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text('$qty shares · Avg ${_fmt.format(avg)}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmt.format(cur * qty), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text('${isPos ? '+' : ''}${_fmt.format(pnl)} (${pct.toStringAsFixed(1)}%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isPos ? AppTheme.green : AppTheme.red)),
          ]),
        ]),
      ),
    );
  }

  Widget _watchlistTile(Map<String, dynamic> w) {
    final price = (w['current_price'] ?? w['price'] ?? 0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ClayCard(
        depth: 0.4, padding: const EdgeInsets.all(14), borderRadius: 16,
        onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: w['symbol']),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w['symbol'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text(w['name'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Text(price > 0 ? _fmt.format(price) : '--', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }
}
