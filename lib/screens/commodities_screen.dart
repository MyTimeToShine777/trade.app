import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';

class CommoditiesScreen extends StatelessWidget {
  const CommoditiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final commodities = [
      {'name': 'Gold', 'symbol': 'GOLD', 'icon': Icons.diamond, 'gradient': AppTheme.goldGradient, 'etfs': ['GOLDBEES', 'NIPGOLD']},
      {'name': 'Silver', 'symbol': 'SILVER', 'icon': Icons.circle, 'gradient': AppTheme.blueGradient, 'etfs': ['SILVERBEES']},
      {'name': 'Crude Oil', 'symbol': 'CRUDEOIL', 'icon': Icons.local_gas_station, 'gradient': AppTheme.redGradient, 'etfs': ['OILBEES']},
      {'name': 'Natural Gas', 'symbol': 'NATURALGAS', 'icon': Icons.whatshot, 'gradient': AppTheme.cyanGradient, 'etfs': []},
      {'name': 'Copper', 'symbol': 'COPPER', 'icon': Icons.hexagon, 'gradient': AppTheme.greenGradient, 'etfs': []},
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            const Expanded(child: Text('Commodities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayCard(gradient: AppTheme.goldGradient, padding: const EdgeInsets.all(20), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Commodity Trading', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Track and trade commodity ETFs. Diversify your portfolio with precious metals and energy.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ])),
        )),

        SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final c = commodities[i];
            final etfs = c['etfs'] as List;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ClayCard(depth: 0.6, padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(gradient: c['gradient'] as Gradient, borderRadius: BorderRadius.circular(14)),
                    child: Icon(c['icon'] as IconData, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    Text(c['symbol'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ])),
                ]),
                if (etfs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: etfs.map((e) => GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: e),
                    child: ClayChip(label: e, icon: Icons.trending_up),
                  )).toList()),
                ],
              ])),
            );
          },
          childCount: commodities.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }
}
