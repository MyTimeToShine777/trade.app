import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/auto_invest_provider.dart';

class AutoInvestScreen extends StatefulWidget {
  const AutoInvestScreen({super.key});
  @override
  State<AutoInvestScreen> createState() => _AutoInvestScreenState();
}

class _AutoInvestScreenState extends State<AutoInvestScreen> with SingleTickerProviderStateMixin {
  bool _loaded = false;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AutoInvestProvider>().loadDashboard()); }
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AutoInvestProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context), child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
                child: Center(child: Text('←', style: TextStyle(fontSize: 20, color: AppTheme.textPrimary))),
              )),
              const SizedBox(width: 14),
              Expanded(child: Text('🤖 Auto Invest', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
            ]),
          )),
          SliverToBoxAdapter(child: _buildDashboard(ai)),
          SliverToBoxAdapter(child: _buildActions(ai)),
          // Research results display
          if (ai.research != null)
            SliverToBoxAdapter(child: _buildResearchResults(ai)),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ClayCard(depth: 0.5, padding: EdgeInsets.zero, child: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppTheme.accent,
              indicatorWeight: 3,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: '🎯 Picks'),
                Tab(text: '📜 History'),
                Tab(text: '📊 Plan'),
              ],
            )),
          )),
        ],
        body: TabBarView(controller: _tabCtrl, children: [
          _buildPicksTab(ai),
          _buildHistoryTab(ai),
          _buildPlanTab(ai),
        ]),
      )),
    );
  }

  Widget _buildDashboard(AutoInvestProvider ai) {
    final budget = ai.monthlyBudget;
    final bgt = (budget?['budget'] ?? 0).toDouble();
    final spent = (budget?['spent'] ?? 0).toDouble();
    final remaining = (budget?['remaining'] ?? bgt - spent).toDouble();
    final progress = bgt > 0 ? (spent / bgt).clamp(0.0, 1.0) : 0.0;

    if (bgt == 0 && ai.plan == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ClayCard(gradient: AppTheme.accentGradient, padding: const EdgeInsets.all(20), child: Column(children: [
          const Text('🤖', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text('No Plan Yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Create a plan to get started with AI investing', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ])),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ClayCard(gradient: AppTheme.cyanGradient, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('💰 Monthly Budget', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(children: [
          _budgetStat('Budget', '₹${bgt.toStringAsFixed(0)}'),
          _budgetStat('Spent', '₹${spent.toStringAsFixed(0)}'),
          _budgetStat('Remaining', '₹${remaining.toStringAsFixed(0)}'),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white24, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text('${(progress * 100).toStringAsFixed(0)}% utilized', style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ])),
    );
  }

  Widget _budgetStat(String label, String value) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]));
  }

  Widget _buildActions(AutoInvestProvider ai) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: [
        Row(children: [
          Expanded(child: ClayButton(
            gradient: AppTheme.accentGradient,
            onPressed: ai.isResearching ? null : () async {
              final ok = await ai.runResearch();
              if (mounted && ok) _showSnack('🔍 Research complete! Check picks.');
              if (mounted && !ok && ai.error != null) _showSnack('❌ ${ai.error}');
            },
            child: ai.isResearching
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('🔍 Research', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          )),
          const SizedBox(width: 10),
          Expanded(child: ClayButton(
            gradient: AppTheme.greenGradient,
            onPressed: ai.isExecuting ? null : () async {
              final ok = await ai.executePicks();
              if (mounted && ok) _showSnack('✅ Picks executed successfully!');
              if (mounted && !ok && ai.error != null) _showSnack('❌ ${ai.error}');
            },
            child: ai.isExecuting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('🚀 Execute', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          )),
          const SizedBox(width: 10),
          SizedBox(width: 52, child: ClayButton(
            gradient: AppTheme.accentGradient,
            width: 52,
            onPressed: () => _showCreatePlan(),
            child: const Text('➕', style: TextStyle(fontSize: 20)),
          )),
        ]),
        // Pause/Resume plan buttons
        if (ai.plan != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: ClayButton(
              gradient: (ai.plan!['status'] ?? 'active') == 'active' ? AppTheme.goldGradient : AppTheme.greenGradient,
              onPressed: () async {
                final status = (ai.plan!['status'] ?? 'active');
                if (status == 'active') {
                  await ai.pausePlan();
                  if (mounted) _showSnack('⏸️ Plan paused');
                } else {
                  await ai.resumePlan();
                  if (mounted) _showSnack('▶️ Plan resumed');
                }
              },
              child: Text(
                (ai.plan!['status'] ?? 'active') == 'active' ? '⏸️ Pause' : '▶️ Resume',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: ClayButton(
              gradient: AppTheme.redGradient,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.cardColor,
                    title: Text('Cancel Plan?', style: TextStyle(color: AppTheme.textPrimary)),
                    content: Text('This will permanently delete your current plan.', style: TextStyle(color: AppTheme.textSecondary)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel', style: TextStyle(color: AppTheme.red))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ai.cancelPlan();
                  if (mounted) _showSnack('🗑️ Plan cancelled');
                }
              },
              child: const Text('🗑️ Cancel Plan', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            )),
          ]),
        ],
      ]),
    );
  }

  Widget _buildResearchResults(AutoInvestProvider ai) {
    final research = ai.research!;
    final marketOutlook = (research['marketOutlook'] ?? research['market_outlook'] ?? '').toString();
    final news = research['news'] is List ? List.from(research['news']) : [];

    if (marketOutlook.isEmpty && news.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: ClayCard(depth: 0.5, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🔬 Research Results', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        if (marketOutlook.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📊 Market Outlook', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent)),
              const SizedBox(height: 6),
              Text(marketOutlook, style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.4), maxLines: 4, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ],
        if (news.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('📰 Key News', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent)),
          const SizedBox(height: 6),
          ...news.take(3).map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('• ', style: TextStyle(color: AppTheme.textSecondary)),
              Expanded(child: Text(n is Map ? (n['title'] ?? n.toString()) : n.toString(), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          )),
        ],
      ])),
    );
  }

  Widget _buildPicksTab(AutoInvestProvider ai) {
    if (ai.isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.accent));
    if (ai.picks.isEmpty) return Center(child: Text('🎯 No picks yet.\nRun Research to get AI picks!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      itemCount: ai.picks.length,
      itemBuilder: (_, i) {
        final pick = ai.picks[i];
        final score = pick['score'] ?? pick['confidence'] ?? 0;
        final signal = pick['signal'] ?? pick['action'] ?? 'BUY';
        final isBuy = signal.toString().toUpperCase().contains('BUY');
        final price = (pick['price'] ?? pick['currentPrice'] ?? 0).toDouble();
        final qty = (pick['quantity'] ?? pick['qty'] ?? 0);
        final amount = (pick['amount'] ?? (price * qty)).toDouble();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClayCard(depth: 0.5, padding: const EdgeInsets.all(16), child: Column(children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (isBuy ? AppTheme.green : AppTheme.red).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(isBuy ? '📈' : '📉', style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pick['symbol'] ?? pick['name'] ?? 'Pick ${i + 1}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(pick['reason'] ?? pick['rationale'] ?? '', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: (isBuy ? AppTheme.green : AppTheme.red).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(signal.toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isBuy ? AppTheme.green : AppTheme.red)),
                ),
                const SizedBox(height: 6),
                Text('Score: $score', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ]),
            ]),
            // Detailed info row
            if (price > 0 || qty > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  if (price > 0) _pickDetail('Price', '₹${price.toStringAsFixed(2)}'),
                  if (qty > 0) _pickDetail('Qty', '$qty'),
                  if (amount > 0) _pickDetail('Amount', '₹${amount.toStringAsFixed(0)}'),
                  _pickDetail('Confidence', '${score}%'),
                ]),
              ),
            ],
          ])),
        );
      },
    );
  }

  Widget _pickDetail(String label, String value) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      Text(label, style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
    ]);
  }

  Widget _buildHistoryTab(AutoInvestProvider ai) {
    if (ai.history.isEmpty) return Center(child: Text('📜 No history yet.\nExecute some picks first!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      itemCount: ai.history.length,
      itemBuilder: (_, i) {
        final h = ai.history[i];
        final profit = (h['profit'] ?? h['pnl'] ?? 0).toDouble();
        final isProfit = profit >= 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClayCard(depth: 0.5, padding: const EdgeInsets.all(16), child: Row(children: [
            Text(isProfit ? '✅' : '❌', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h['symbol'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${h['type'] ?? 'BUY'} · Qty: ${h['quantity'] ?? 0} · ₹${(h['price'] ?? 0).toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ])),
            Text('${isProfit ? '+' : ''}₹${profit.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isProfit ? AppTheme.green : AppTheme.red)),
          ])),
        );
      },
    );
  }

  Widget _buildPlanTab(AutoInvestProvider ai) {
    final plan = ai.plan;
    if (plan == null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('📋 No plan yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
      const SizedBox(height: 16),
      ClayButton(gradient: AppTheme.accentGradient, onPressed: _showCreatePlan, child: const Text('➕ Create Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
    ]));

    final status = (plan['status'] ?? 'active').toString();
    final statusColor = status == 'active' ? AppTheme.green : status == 'paused' ? AppTheme.orange : AppTheme.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(children: [
        ClayCard(depth: 0.5, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('📋 Active Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
            ),
          ]),
          const SizedBox(height: 16),
          if (plan['name'] != null && plan['name'].toString().isNotEmpty)
            _planRow('📝 Plan Name', plan['name'].toString()),
          _planRow('💰 Monthly Budget', '₹${(plan['monthlyBudget'] ?? plan['monthly_budget'] ?? 0).toStringAsFixed(0)}'),
          _planRow('⚡ Risk Level', (plan['riskLevel'] ?? plan['risk_level'] ?? 'moderate').toString().toUpperCase()),
          _planRow('📊 Strategy', (plan['strategy'] ?? 'balanced').toString().toUpperCase()),
          _planRow('🎯 Asset Types', (plan['assetTypes'] ?? plan['asset_types'] ?? ['STOCK']).join(', ')),
        ])),
        const SizedBox(height: 16),
        if (ai.learningData != null) ClayCard(depth: 0.5, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🧠 AI Learning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _planRow('Win Rate', '${ai.learningData!['winRate'] ?? ai.learningData!['win_rate'] ?? 'N/A'}%'),
          _planRow('Total Trades', '${ai.learningData!['totalTrades'] ?? ai.learningData!['total_trades'] ?? 0}'),
          _planRow('Avg Return', '${ai.learningData!['avgReturn'] ?? ai.learningData!['avg_return'] ?? 'N/A'}%'),
        ])),
      ]),
    );
  }

  Widget _planRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.cardColor, behavior: SnackBarBehavior.floating));
  }

  void _showCreatePlan() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '5000');
    String riskLevel = 'moderate';
    List<String> selectedAssets = ['STOCK'];
    final allAssets = ['STOCK', 'MUTUAL_FUND', 'ETF', 'COMMODITY'];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('🤖 Create Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          ClayInput(controller: nameCtrl, labelText: 'PLAN NAME', hintText: 'My Growth Plan', prefixIcon: Icons.label),
          const SizedBox(height: 16),
          ClayInput(controller: amountCtrl, labelText: 'AMOUNT (₹)', hintText: '5000', prefixIcon: Icons.currency_rupee, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          // Risk level selector
          const Align(alignment: Alignment.centerLeft, child: Text('RISK LEVEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1))),
          const SizedBox(height: 8),
          Row(children: [
            for (final r in ['conservative', 'moderate', 'aggressive']) ...[
              Expanded(child: ClayChip(label: '${r == 'conservative' ? '🛡️' : r == 'moderate' ? '⚖️' : '🔥'} ${r[0].toUpperCase()}${r.substring(1)}', isActive: riskLevel == r, onTap: () => ss(() => riskLevel = r))),
              if (r != 'aggressive') const SizedBox(width: 8),
            ],
          ]),
          const SizedBox(height: 16),
          // Asset type selector
          const Align(alignment: Alignment.centerLeft, child: Text('ASSET TYPES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1))),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: allAssets.map((a) => GestureDetector(
            onTap: () => ss(() {
              if (selectedAssets.contains(a)) {
                if (selectedAssets.length > 1) selectedAssets.remove(a);
              } else {
                selectedAssets.add(a);
              }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selectedAssets.contains(a) ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedAssets.contains(a) ? AppTheme.accent : AppTheme.border),
              ),
              child: Text(a.replaceAll('_', ' '), style: TextStyle(fontSize: 12, fontWeight: selectedAssets.contains(a) ? FontWeight.w700 : FontWeight.w500, color: selectedAssets.contains(a) ? AppTheme.accent : AppTheme.textSecondary)),
            ),
          )).toList()),
          const SizedBox(height: 20),
          ClayButton(gradient: AppTheme.accentGradient, onPressed: () async {
            final ok = await context.read<AutoInvestProvider>().createPlan(
              name: nameCtrl.text.trim(),
              monthlyBudget: double.tryParse(amountCtrl.text) ?? 5000,
              riskLevel: riskLevel,
              assetTypes: selectedAssets,
              strategy: 'balanced',
            );
            if (ctx.mounted) Navigator.pop(ctx);
            if (ok) _showSnack('✅ Plan created!');
          }, child: const Text('🚀 Create Plan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
      )),
    );
  }
}
