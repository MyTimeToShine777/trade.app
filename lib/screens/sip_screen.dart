import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/sip_provider.dart';

class SipScreen extends StatefulWidget {
  const SipScreen({super.key});
  @override
  State<SipScreen> createState() => _SipScreenState();
}

class _SipScreenState extends State<SipScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  // Calculator fields
  final _sipAmountCtrl = TextEditingController(text: '5000');
  final _sipYearsCtrl = TextEditingController(text: '10');
  final _sipReturnsCtrl = TextEditingController(text: '12');
  bool _loaded = false;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this); }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SipProvider>().loadPlans()); }
  }
  @override
  void dispose() { _tabCtrl.dispose(); _sipAmountCtrl.dispose(); _sipYearsCtrl.dispose(); _sipReturnsCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(child: Text('SIP Plans', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.clayInset(depth: 0.6)),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(14)),
              indicatorSize: TabBarIndicatorSize.tab, dividerColor: Colors.transparent,
              labelColor: Colors.white, unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [Tab(text: 'My SIPs'), Tab(text: 'Calculator')],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: TabBarView(controller: _tabCtrl, children: [_myPlansTab(), _calculatorTab()])),
      ])),
    );
  }

  Widget _myPlansTab() {
    final sip = context.watch<SipProvider>();
    return sip.plans.isEmpty
      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.repeat, size: 60, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text('No SIP plans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 60), child: ClayButton(gradient: AppTheme.accentGradient, isSmall: true, onPressed: () => _showCreateSipDialog(), child: const Text('Create SIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
        ]))
      : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: sip.plans.length,
          itemBuilder: (_, i) {
            final p = sip.plans[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClayCard(depth: 0.5, padding: const EdgeInsets.all(16), child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['symbol'] ?? p['name'] ?? 'SIP ${i + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('${_fmt.format((p['amount'] ?? 0).toDouble())} / ${p['frequency'] ?? 'month'}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ])),
                Switch(value: p['active'] ?? true, activeTrackColor: AppTheme.accent, onChanged: (v) => context.read<SipProvider>().togglePlan((p['id'] ?? '').toString(), v)),
              ])),
            );
          },
        );
  }

  Widget _calculatorTab() {
    final sip = context.watch<SipProvider>();
    return SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      const SizedBox(height: 8),
      ClayInput(controller: _sipAmountCtrl, labelText: 'MONTHLY AMOUNT (₹)', hintText: '5000', prefixIcon: Icons.currency_rupee, keyboardType: TextInputType.number),
      const SizedBox(height: 14),
      ClayInput(controller: _sipYearsCtrl, labelText: 'DURATION (YEARS)', hintText: '10', prefixIcon: Icons.calendar_today, keyboardType: TextInputType.number),
      const SizedBox(height: 14),
      ClayInput(controller: _sipReturnsCtrl, labelText: 'EXPECTED RETURNS (%)', hintText: '12', prefixIcon: Icons.trending_up, keyboardType: TextInputType.number),
      const SizedBox(height: 20),
      ClayButton(gradient: AppTheme.accentGradient, onPressed: () {
        context.read<SipProvider>().calculate(
          amount: double.tryParse(_sipAmountCtrl.text) ?? 5000,
          years: int.tryParse(_sipYearsCtrl.text) ?? 10,
          returns: double.tryParse(_sipReturnsCtrl.text) ?? 12,
        );
      }, child: const Text('Calculate', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
      const SizedBox(height: 20),
      if (sip.calculator != null) ClayCard(padding: const EdgeInsets.all(20), child: Column(children: [
        _calcRow('Total Invested', _fmt.format(sip.calculator!['totalInvested'] ?? 0)),
        const SizedBox(height: 12),
        _calcRow('Estimated Returns', _fmt.format(sip.calculator!['gains'] ?? 0), color: AppTheme.green),
        const Divider(height: 24),
        _calcRow('Future Value', _fmt.format(sip.calculator!['futureValue'] ?? 0), isBold: true),
      ])),
    ]));
  }

  Widget _calcRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 14, color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
      Text(value, style: TextStyle(fontSize: isBold ? 18 : 15, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: color ?? AppTheme.textPrimary)),
    ]);
  }

  void _showCreateSipDialog() {
    final symbolCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '1000');
    String frequency = 'monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('📊 New SIP Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          ClayInput(controller: symbolCtrl, labelText: 'STOCK / FUND SYMBOL', hintText: 'e.g. RELIANCE, SBIN', prefixIcon: Icons.search),
          const SizedBox(height: 16),
          ClayInput(controller: amountCtrl, labelText: 'SIP AMOUNT (₹)', hintText: '1000', prefixIcon: Icons.currency_rupee, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: Text('FREQUENCY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1))),
          const SizedBox(height: 8),
          Row(children: [
            for (final f in ['weekly', 'monthly', 'quarterly']) ...[
              Expanded(child: ClayChip(label: f[0].toUpperCase() + f.substring(1), isActive: frequency == f, onTap: () => ss(() => frequency = f))),
              if (f != 'quarterly') const SizedBox(width: 8),
            ],
          ]),
          const SizedBox(height: 20),
          ClayButton(gradient: AppTheme.accentGradient, onPressed: () async {
            final symbol = symbolCtrl.text.trim().toUpperCase();
            final amount = double.tryParse(amountCtrl.text) ?? 0;
            if (symbol.isEmpty || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid symbol and amount'), backgroundColor: AppTheme.red));
              return;
            }
            final ok = await context.read<SipProvider>().createPlan({
              'symbol': symbol,
              'amount': amount,
              'frequency': frequency,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ SIP plan created!'), backgroundColor: AppTheme.green));
            }
          }, child: const Text('🚀 Start SIP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
      )),
    );
  }
}
