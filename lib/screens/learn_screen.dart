import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'title': 'Stock Market Basics', 'desc': 'Learn what stocks are and how markets work', 'icon': Icons.school, 'gradient': AppTheme.accentGradient, 'lessons': 8},
      {'title': 'Technical Analysis', 'desc': 'Chart patterns, indicators, and trend analysis', 'icon': Icons.candlestick_chart, 'gradient': AppTheme.blueGradient, 'lessons': 12},
      {'title': 'Fundamental Analysis', 'desc': 'Financial statements, ratios, and valuation', 'icon': Icons.analytics, 'gradient': AppTheme.greenGradient, 'lessons': 10},
      {'title': 'Risk Management', 'desc': 'Position sizing, stop losses, and portfolio risk', 'icon': Icons.shield, 'gradient': AppTheme.redGradient, 'lessons': 6},
      {'title': 'Trading Psychology', 'desc': 'Emotions, discipline, and mental frameworks', 'icon': Icons.psychology, 'gradient': AppTheme.pinkGradient, 'lessons': 8},
      {'title': 'Options Trading', 'desc': 'Calls, puts, strategies, and Greeks', 'icon': Icons.call_split, 'gradient': AppTheme.cyanGradient, 'lessons': 14},
      {'title': 'Mutual Funds & SIP', 'desc': 'Passive investing and systematic plans', 'icon': Icons.account_balance, 'gradient': AppTheme.goldGradient, 'lessons': 6},
      {'title': 'Indian Markets', 'desc': 'NSE, BSE, SEBI regulations, and taxation', 'icon': Icons.flag, 'gradient': AppTheme.darkGradient, 'lessons': 10},
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            const Expanded(child: Text('Learn', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayCard(gradient: AppTheme.accentGradient, padding: const EdgeInsets.all(20), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.school, color: Colors.white, size: 24), SizedBox(width: 8), Text('Trading Academy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))]),
            SizedBox(height: 8),
            Text('Master the art of stock trading with bite-sized lessons and quizzes.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ])),
        )),

        // Quick stats
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            Expanded(child: ClayStatCard(label: 'Modules', value: '${modules.length}', icon: Icons.menu_book, iconGradient: AppTheme.accentGradient)),
            const SizedBox(width: 12),
            Expanded(child: ClayStatCard(label: 'Total Lessons', value: '${modules.fold<int>(0, (sum, m) => sum + (m['lessons'] as int))}', icon: Icons.play_circle, iconGradient: AppTheme.greenGradient)),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: const Text('Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        )),

        SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final m = modules[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ClayCard(depth: 0.6, padding: const EdgeInsets.all(16), borderRadius: 18, onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${m['title']}...'), backgroundColor: AppTheme.accent));
              }, child: Row(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(gradient: m['gradient'] as Gradient, borderRadius: BorderRadius.circular(16)),
                  child: Icon(m['icon'] as IconData, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(m['desc'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('${m['lessons']} lessons', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                ])),
                const Icon(Icons.chevron_right, color: AppTheme.textLight),
              ])),
            );
          },
          childCount: modules.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }
}
