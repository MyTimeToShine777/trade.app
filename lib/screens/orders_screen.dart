import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/portfolio_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  String _filter = 'ALL';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PortfolioProvider>().loadOrders()); }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PortfolioProvider>();
    final filtered = _filter == 'ALL' ? p.orders : p.orders.where((o) => (o['status'] ?? '').toString().toUpperCase() == _filter).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            const Expanded(child: Text('Orders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        // Filters
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            for (final f in ['ALL', 'EXECUTED', 'PENDING', 'CANCELLED'])
              Padding(padding: const EdgeInsets.only(right: 8), child: ClayChip(label: f, isActive: _filter == f, onTap: () => setState(() => _filter = f))),
          ])),
        )),

        if (filtered.isEmpty)
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(60), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.receipt_long_outlined, size: 60, color: AppTheme.textLight),
            const SizedBox(height: 12),
            const Text('No orders found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          ])))
        else SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final o = filtered[i];
            final type = (o['type'] ?? '').toString().toUpperCase();
            final isBuy = type.contains('BUY');
            final status = (o['status'] ?? '').toString().toUpperCase();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ClayCard(depth: 0.5, padding: const EdgeInsets.all(14), borderRadius: 16, child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(gradient: isBuy ? AppTheme.greenGradient : AppTheme.redGradient, borderRadius: BorderRadius.circular(12)),
                  child: Icon(isBuy ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${o['symbol'] ?? ''} · $type', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text('${o['quantity'] ?? 0} × ${_fmt.format((o['price'] ?? 0).toDouble())}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (status == 'EXECUTED' ? AppTheme.green : status == 'PENDING' ? AppTheme.orange : AppTheme.red).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: status == 'EXECUTED' ? AppTheme.green : status == 'PENDING' ? AppTheme.orange : AppTheme.red)),
                ),
              ])),
            );
          },
          childCount: filtered.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }
}
