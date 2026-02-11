import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/portfolio_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ai_provider.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});
  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PortfolioProvider>().loadPortfolio()); }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PortfolioProvider>();
    final auth = context.watch<AuthProvider>();
    final ai = context.watch<AiProvider>();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => context.read<PortfolioProvider>().loadPortfolio(),
        color: AppTheme.accent,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              ClayIconButton(icon: Icons.menu, onTap: () => Scaffold.of(context).openDrawer()),
              const SizedBox(width: 14),
              Expanded(child: Text('Portfolio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
            ]),
          )),

          // Summary card
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ClayCard(padding: const EdgeInsets.all(20), child: Column(children: [
              Row(children: [
                Expanded(child: _summaryItem('Invested', _fmt.format(p.totalInvested))),
                Container(width: 1, height: 40, color: AppTheme.surfaceColor),
                Expanded(child: _summaryItem('Current', _fmt.format(p.totalCurrent))),
              ]),
              const SizedBox(height: 14),
              ClayCard(
                depth: 0.4, inset: true, padding: const EdgeInsets.all(14),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(p.totalPnl >= 0 ? Icons.trending_up : Icons.trending_down, color: p.totalPnl >= 0 ? AppTheme.green : AppTheme.red, size: 20),
                  const SizedBox(width: 8),
                  Text('${p.totalPnl >= 0 ? '+' : ''}${_fmt.format(p.totalPnl)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.totalPnl >= 0 ? AppTheme.green : AppTheme.red)),
                  const SizedBox(width: 8),
                  Text('(${p.totalPnlPercent.toStringAsFixed(2)}%)', style: TextStyle(fontSize: 13, color: p.totalPnl >= 0 ? AppTheme.green : AppTheme.red)),
                ]),
              ),
            ])),
          )),

          // Cash balance card
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              Expanded(child: ClayCard(depth: 0.4, padding: const EdgeInsets.all(14), child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(gradient: AppTheme.greenGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('💰', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cash Balance', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  Text(_fmt.format(auth.balance), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                ]),
              ]))),
              const SizedBox(width: 10),
              Expanded(child: ClayCard(depth: 0.4, padding: const EdgeInsets.all(14), child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('💎', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Value', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  Text(_fmt.format(auth.balance + p.totalCurrent), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                ]),
              ]))),
            ]),
          )),

          // AI Portfolio Insight
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: ClayCard(depth: 0.4, padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('🤖 AI Portfolio Insight', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.accentLight)),
                const Spacer(),
                GestureDetector(
                  onTap: ai.isPortfolioAnalyzing ? null : () => context.read<AiProvider>().getPortfolioAnalysis(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: ai.isPortfolioAnalyzing
                      ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                      : Text('Analyze', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                  ),
                ),
              ]),
              if (ai.portfolioAnalysis != null) ...[
                const SizedBox(height: 8),
                Text(
                  ai.portfolioAnalysis!['analysis'] ?? ai.portfolioAnalysis!['suggestions']?.toString() ?? 'Tap Analyze for AI insights',
                  style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.4),
                  maxLines: 4, overflow: TextOverflow.ellipsis,
                ),
                if (ai.portfolioAnalysis!['suggestions'] is List) ...[
                  const SizedBox(height: 6),
                  ...(ai.portfolioAnalysis!['suggestions'] as List).take(2).map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('💡 ', style: TextStyle(fontSize: 10)),
                      Expanded(child: Text(s.toString(), style: TextStyle(fontSize: 11, color: AppTheme.accentLight, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ]),
                  )),
                ],
              ] else
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Tap Analyze for AI-powered portfolio insights', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ),
            ])),
          )),

          // Holdings header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(children: [
              Icon(Icons.inventory_2, size: 18, color: AppTheme.accent),
              const SizedBox(width: 8),
              Text('Holdings (${p.holdings.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ]),
          )),

          if (p.isLoading)
            SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.accent))))
          else if (p.holdings.isEmpty)
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: AppTheme.textLight),
                const SizedBox(height: 12),
                Text('No holdings yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('Start trading to build your portfolio', style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
              ]),
            ))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) {
                final h = p.holdings[i];
                final qty = (h['quantity'] ?? 0);
                final avg = (h['avg_price'] ?? h['avgPrice'] ?? 0).toDouble();
                final cur = (h['current_price'] ?? h['currentPrice'] ?? avg).toDouble();
                final totalInvested = avg * qty;
                final totalCurrent = cur * qty;
                final pnl = totalCurrent - totalInvested;
                final pct = avg > 0 ? ((cur - avg) / avg * 100) : 0.0;
                final isPos = pnl >= 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: ClayCard(
                    depth: 0.5, padding: const EdgeInsets.all(16), borderRadius: 18,
                    onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: h['symbol']),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(gradient: isPos ? AppTheme.greenGradient : AppTheme.redGradient, borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text((h['symbol'] ?? '?')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(h['symbol'] ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                          Text('$qty shares · Avg ${_fmt.format(avg)}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(_fmt.format(totalCurrent), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          Text('${isPos ? '+' : ''}${_fmt.format(pnl)} (${pct.toStringAsFixed(1)}%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isPos ? AppTheme.green : AppTheme.red)),
                        ]),
                      ]),
                      const SizedBox(height: 10),
                      ClayProgressBar(value: ((pct + 100) / 200).clamp(0.0, 1.0), gradient: isPos ? AppTheme.greenGradient : AppTheme.redGradient, height: 5),
                    ]),
                  ),
                );
              },
              childCount: p.holdings.length,
            )),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(children: [
      Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
    ]);
  }
}
