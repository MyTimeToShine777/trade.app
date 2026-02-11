import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';

class MutualFundsScreen extends StatefulWidget {
  const MutualFundsScreen({super.key});
  @override
  State<MutualFundsScreen> createState() => _MutualFundsScreenState();
}

class _MutualFundsScreenState extends State<MutualFundsScreen> {
  String _category = 'All';

  final _categories = ['All', 'Equity', 'Debt', 'Hybrid', 'Index', 'Tax Saver'];
  final _funds = [
    {'name': 'SBI Bluechip Fund', 'category': 'Equity', 'returns1y': 18.5, 'returns3y': 15.2, 'risk': 'High', 'minSIP': 500},
    {'name': 'HDFC Mid Cap Opportunities', 'category': 'Equity', 'returns1y': 22.3, 'returns3y': 19.8, 'risk': 'Very High', 'minSIP': 500},
    {'name': 'Axis Long Term Equity', 'category': 'Tax Saver', 'returns1y': 16.4, 'returns3y': 14.1, 'risk': 'High', 'minSIP': 500},
    {'name': 'ICICI Pru Balanced Advantage', 'category': 'Hybrid', 'returns1y': 12.8, 'returns3y': 11.6, 'risk': 'Moderate', 'minSIP': 1000},
    {'name': 'UTI Nifty 50 Index', 'category': 'Index', 'returns1y': 14.6, 'returns3y': 13.5, 'risk': 'Moderate', 'minSIP': 500},
    {'name': 'SBI Magnum Gilt', 'category': 'Debt', 'returns1y': 8.2, 'returns3y': 7.5, 'risk': 'Low', 'minSIP': 1000},
    {'name': 'Kotak Small Cap Fund', 'category': 'Equity', 'returns1y': 28.5, 'returns3y': 24.1, 'risk': 'Very High', 'minSIP': 500},
    {'name': 'Nippon India Tax Saver', 'category': 'Tax Saver', 'returns1y': 17.8, 'returns3y': 15.9, 'risk': 'High', 'minSIP': 500},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _category == 'All' ? _funds : _funds.where((f) => f['category'] == _category).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            const Expanded(child: Text('Mutual Funds', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        // Filters
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
            children: _categories.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: ClayChip(label: c, isActive: _category == c, onTap: () => setState(() => _category = c)))).toList(),
          )),
        )),

        SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final f = filtered[i];
            final returns1y = (f['returns1y'] as num).toDouble();
            final risk = f['risk'] as String;
            Color riskColor = risk == 'Low' ? AppTheme.green : risk == 'Moderate' ? AppTheme.orange : risk.contains('Very') ? AppTheme.red : AppTheme.orange;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ClayCard(depth: 0.5, padding: const EdgeInsets.all(16), borderRadius: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Row(children: [
                  _metricBadge('1Y', '+${returns1y.toStringAsFixed(1)}%', AppTheme.green),
                  const SizedBox(width: 8),
                  _metricBadge('3Y', '+${(f['returns3y'] as num).toStringAsFixed(1)}%', AppTheme.blue),
                  const SizedBox(width: 8),
                  _metricBadge(risk, '', riskColor),
                  const Spacer(),
                  Text('Min ₹${f['minSIP']}/mo', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: ClayButton(isSmall: true, gradient: AppTheme.accentGradient, onPressed: () => Navigator.pushNamed(context, '/sip'), child: const Text('Start SIP', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 8),
                  Expanded(child: ClayButton(isSmall: true, color: AppTheme.cardColor, onPressed: () {}, child: const Text('Invest', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700)))),
                ]),
              ])),
            );
          },
          childCount: filtered.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }

  Widget _metricBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(value.isEmpty ? label : '$label $value', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
