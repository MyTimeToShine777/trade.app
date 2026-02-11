import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final _amountCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; WidgetsBinding.instance.addPostFrameCallback((_) { context.read<WalletProvider>().loadWallet(); context.read<AuthProvider>().refreshBalance(); }); }
  }

  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final auth = context.watch<AuthProvider>();

    // Show error snackbar when wallet has error
    if (wallet.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(wallet.error!), backgroundColor: AppTheme.red));
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: Stack(children: [
        CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(child: Text('Wallet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        // Balance card
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayCard(gradient: AppTheme.accentGradient, padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white70, size: 18), SizedBox(width: 8), Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13))]),
            const SizedBox(height: 12),
            Text(_fmt.format(auth.balance), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
          ])),
        )),

        // Quick add
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quick Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Row(children: [
              for (final amt in [10000, 50000, 100000, 500000]) ...[
                Expanded(child: GestureDetector(
                  onTap: () async { await wallet.deposit(amt.toDouble()); if (mounted) auth.refreshBalance(); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border, width: 1)),
                    child: Center(child: Text('₹${amt >= 100000 ? '${amt ~/ 100000}L' : '${amt ~/ 1000}K'}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent))),
                  ),
                )),
                if (amt != 500000) const SizedBox(width: 8),
              ],
            ]),
          ]),
        )),

        // Custom amount
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayCard(padding: const EdgeInsets.all(20), child: Column(children: [
            ClayInput(controller: _amountCtrl, labelText: 'CUSTOM AMOUNT', hintText: '0', prefixIcon: Icons.currency_rupee, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: ClayButton(gradient: AppTheme.greenGradient, isSmall: true, onPressed: () async {
                final a = double.tryParse(_amountCtrl.text) ?? 0;
                if (a > 0) { await wallet.deposit(a); if (mounted) { auth.refreshBalance(); _amountCtrl.clear(); } }
              }, child: const Text('Deposit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
              const SizedBox(width: 12),
              Expanded(child: ClayButton(gradient: AppTheme.redGradient, isSmall: true, onPressed: () async {
                final a = double.tryParse(_amountCtrl.text) ?? 0;
                if (a > 0) { await wallet.withdraw(a); if (mounted) { auth.refreshBalance(); _amountCtrl.clear(); } }
              }, child: const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
            ]),
          ])),
        )),

        // Transaction history
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(children: [
            Icon(Icons.history, size: 18, color: AppTheme.accent),
            const SizedBox(width: 8),
            Text('History (${wallet.transactions.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        )),

        if (wallet.transactions.isEmpty)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No transactions yet', style: TextStyle(color: AppTheme.textSecondary)))))
        else SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final t = wallet.transactions[i];
            final type = (t['type'] ?? '').toString().toUpperCase();
            final isDeposit = type.contains('DEPOSIT') || type.contains('ADD');
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ClayCard(depth: 0.4, padding: const EdgeInsets.all(14), borderRadius: 16, child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(gradient: isDeposit ? AppTheme.greenGradient : AppTheme.redGradient, borderRadius: BorderRadius.circular(12)),
                  child: Icon(isDeposit ? Icons.add : Icons.remove, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(type, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text(t['date'] ?? t['created_at'] ?? '', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ])),
                Text('${isDeposit ? '+' : '-'}${_fmt.format((t['amount'] ?? 0).toDouble().abs())}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDeposit ? AppTheme.green : AppTheme.red)),
              ])),
            );
          },
          childCount: wallet.transactions.length,
        )),

        // Reset button
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: ClayButton(color: AppTheme.surfaceColor, onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Reset Balance?'), content: const Text('This will reset to ₹10,00,000'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset', style: TextStyle(color: AppTheme.red)))]));
            if (ok == true) { await wallet.resetBalance(); if (mounted) auth.refreshBalance(); }
          }, child: const Text('Reset Balance', style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.w700))),
        )),
      ])),
      if (wallet.isLoading)
        Positioned.fill(child: Container(
          color: Colors.black26,
          child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        )),
      ])),
    );
  }
}
