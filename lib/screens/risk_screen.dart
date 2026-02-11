import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../services/api_service.dart';

class RiskScreen extends StatefulWidget {
  const RiskScreen({super.key});
  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> {
  Map<String, dynamic>? _riskData;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.get('/risk/dashboard');
      setState(() { _riskData = data; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final riskScore = (_riskData?['riskScore'] ?? _riskData?['score'] ?? 50).toDouble();
    final riskLevel = riskScore > 70 ? 'High' : riskScore > 40 ? 'Moderate' : 'Low';
    final riskColor = riskScore > 70 ? AppTheme.red : riskScore > 40 ? AppTheme.orange : AppTheme.green;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(child: Text('Risk Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        // Risk score card
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayCard(padding: const EdgeInsets.all(24), child: Column(children: [
            Text('Risk Score', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 120, height: 120,
                child: CircularProgressIndicator(value: riskScore / 100, strokeWidth: 10, backgroundColor: AppTheme.surfaceColor, color: riskColor),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${riskScore.toStringAsFixed(0)}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: riskColor)),
                Text(riskLevel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: riskColor)),
              ]),
            ]),
            const SizedBox(height: 16),
            ClayProgressBar(value: riskScore / 100, gradient: riskScore > 70 ? AppTheme.redGradient : riskScore > 40 ? AppTheme.goldGradient : AppTheme.greenGradient),
          ])),
        )),

        // Metrics
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            Expanded(child: ClayStatCard(label: 'Max Drawdown', value: '${(_riskData?['maxDrawdown'] ?? 0).toStringAsFixed(1)}%', icon: Icons.trending_down, iconGradient: AppTheme.redGradient)),
            const SizedBox(width: 12),
            Expanded(child: ClayStatCard(label: 'Sharpe Ratio', value: (_riskData?['sharpeRatio'] ?? 0).toStringAsFixed(2), icon: Icons.analytics, iconGradient: AppTheme.blueGradient)),
          ]),
        )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [
            Expanded(child: ClayStatCard(label: 'Volatility', value: '${(_riskData?['volatility'] ?? 0).toStringAsFixed(1)}%', icon: Icons.waves, iconGradient: AppTheme.cyanGradient)),
            const SizedBox(width: 12),
            Expanded(child: ClayStatCard(label: 'Beta', value: (_riskData?['beta'] ?? 1).toStringAsFixed(2), icon: Icons.speed, iconGradient: AppTheme.pinkGradient)),
          ]),
        )),

        // Recommendations
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(children: [
            const Icon(Icons.lightbulb, size: 18, color: AppTheme.gold),
            const SizedBox(width: 8),
            const Text('Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _tipCard(Icons.pie_chart, 'Diversify Holdings', 'Spread investments across sectors to reduce concentration risk.', AppTheme.accentGradient),
            const SizedBox(height: 8),
            _tipCard(Icons.shield, 'Set Stop Losses', 'Protect your capital with automatic stop-loss orders.', AppTheme.greenGradient),
            const SizedBox(height: 8),
            _tipCard(Icons.balance, 'Rebalance Portfolio', 'Periodically rebalance to maintain your target allocation.', AppTheme.blueGradient),
          ]),
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }

  Widget _tipCard(IconData icon, String title, String desc, Gradient gradient) {
    return ClayCard(depth: 0.4, padding: const EdgeInsets.all(14), borderRadius: 16, child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        Text(desc, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3)),
      ])),
    ]));
  }
}
