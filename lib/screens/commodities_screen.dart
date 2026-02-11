import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../services/api_service.dart';

class CommoditiesScreen extends StatefulWidget {
  const CommoditiesScreen({super.key});
  @override
  State<CommoditiesScreen> createState() => _CommoditiesScreenState();
}

class _CommoditiesScreenState extends State<CommoditiesScreen> {
  List<Map<String, dynamic>> _commodities = [];
  bool _loading = true;
  String? _error;
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  // Fallback static data in case API fails
  final _fallback = [
    {'name': 'Gold', 'symbol': 'GOLD', 'price': 6500.0, 'changePercent': 0.38, 'etfs': ['GOLDBEES', 'NIPGOLD']},
    {'name': 'Silver', 'symbol': 'SILVER', 'price': 78000.0, 'changePercent': 0.84, 'etfs': ['SILVERBEES']},
    {'name': 'Crude Oil', 'symbol': 'CRUDEOIL', 'price': 5650.0, 'changePercent': -0.45, 'etfs': ['OILBEES']},
    {'name': 'Copper', 'symbol': 'COPPER', 'price': 250.0, 'changePercent': 0.48, 'etfs': []},
  ];

  final _icons = {
    'gold': Icons.diamond, 'silver': Icons.circle, 'crude': Icons.local_gas_station,
    'natural': Icons.whatshot, 'copper': Icons.hexagon, 'default': Icons.bar_chart,
  };

  final _gradients = {
    'gold': AppTheme.goldGradient, 'silver': AppTheme.blueGradient, 'crude': AppTheme.redGradient,
    'natural': AppTheme.cyanGradient, 'copper': AppTheme.greenGradient, 'default': AppTheme.accentGradient,
  };

  @override
  void initState() {
    super.initState();
    _loadCommodities();
  }

  Future<void> _loadCommodities() async {
    try {
      final data = await ApiService.get('/commodities');
      final list = data is List ? data : (data['commodities'] ?? []);
      setState(() {
        _commodities = List<Map<String, dynamic>>.from(list);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _commodities = _fallback;
        _loading = false;
        _error = e.toString();
      });
    }
  }

  IconData _getIcon(String name) {
    final lower = name.toLowerCase();
    for (final key in _icons.keys) {
      if (lower.contains(key)) return _icons[key]!;
    }
    return _icons['default']!;
  }

  Gradient _getGradient(String name) {
    final lower = name.toLowerCase();
    for (final key in _gradients.keys) {
      if (lower.contains(key)) return _gradients[key]!;
    }
    return _gradients['default']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(child: Text('Commodities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
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

        if (_loading)
          SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator(color: AppTheme.accent))))
        else
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, i) {
              final c = _commodities[i];
              final name = (c['name'] ?? 'Commodity').toString();
              final symbol = (c['symbol'] ?? '').toString();
              final price = (c['price'] ?? c['ltp'] ?? 0).toDouble();
              final changePct = (c['changePercent'] ?? c['change_percent'] ?? 0).toDouble();
              final isPos = changePct >= 0;
              final etfs = c['etfs'] is List ? List<String>.from(c['etfs']) : <String>[];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: ClayCard(depth: 0.6, padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(gradient: _getGradient(name), borderRadius: BorderRadius.circular(14)),
                      child: Icon(_getIcon(name), color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      Text(symbol, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      if (price > 0) Text(_fmt.format(price), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: (isPos ? AppTheme.green : AppTheme.red).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text('${isPos ? '+' : ''}${changePct.toStringAsFixed(2)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPos ? AppTheme.green : AppTheme.red)),
                      ),
                    ]),
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
            childCount: _commodities.length,
          )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }
}
