import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../services/api_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});
  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  Map<String, dynamic>? _challenge;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.get('/challenge/active');
      setState(() {
        _challenge = data['challenge'] ?? data;
        _isLoading = false;
      });
    } catch (e) { setState(() => _isLoading = false); }
    // Load leaderboard separately
    try {
      final lb = await ApiService.get('/challenge/leaderboard');
      setState(() {
        _leaderboard = List<Map<String, dynamic>>.from(lb['leaderboard'] ?? lb is List ? lb : []);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final day = _challenge?['currentDay'] ?? _challenge?['day'] ?? 0;
    final targetPct = (_challenge?['targetPercent'] ?? 10).toDouble();
    final currentPct = (_challenge?['currentPercent'] ?? _challenge?['progress'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(child: Text('100 Days Challenge', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        // Challenge card
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayCard(gradient: AppTheme.pinkGradient, padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.emoji_events, color: Colors.white, size: 24), SizedBox(width: 8), Text('100 Days Trading Challenge', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))]),
            const SizedBox(height: 12),
            const Text('Grow your portfolio by 10% in 100 days!', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            Row(children: [
              _statPill('Day', '$day/100'),
              const SizedBox(width: 12),
              _statPill('Progress', '${currentPct.toStringAsFixed(1)}%'),
              const SizedBox(width: 12),
              _statPill('Target', '${targetPct.toStringAsFixed(0)}%'),
            ]),
            const SizedBox(height: 14),
            ClayProgressBar(value: (day / 100).clamp(0.0, 1.0), gradient: AppTheme.goldGradient, height: 8),
          ])),
        )),

        // Stats
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            Expanded(child: ClayStatCard(label: 'Day Streak', value: '${_challenge?['streak'] ?? day}', icon: Icons.local_fire_department, iconGradient: AppTheme.redGradient)),
            const SizedBox(width: 12),
            Expanded(child: ClayStatCard(label: 'Win Rate', value: '${(_challenge?['winRate'] ?? 0).toStringAsFixed(0)}%', icon: Icons.trending_up, iconGradient: AppTheme.greenGradient)),
          ]),
        )),

        if (!(_challenge?['active'] ?? false)) SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayButton(gradient: AppTheme.accentGradient, onPressed: () async {
            try { await ApiService.post('/challenge', {}); _load(); } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.red));
            }
          }, child: const Text('Start Challenge', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
        )),

        // Leaderboard
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(children: [
            const Icon(Icons.leaderboard, size: 18, color: AppTheme.gold),
            const SizedBox(width: 8),
            const Text('Leaderboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        )),

        if (_leaderboard.isEmpty)
          SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No leaderboard data yet', style: TextStyle(color: AppTheme.textSecondary)))))
        else SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final l = _leaderboard[i];
            final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ClayCard(depth: 0.4, padding: const EdgeInsets.all(14), child: Row(children: [
                Text(medal, style: TextStyle(fontSize: i < 3 ? 20 : 16)),
                const SizedBox(width: 12),
                Expanded(child: Text(l['username'] ?? l['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                Text('${(l['returns'] ?? l['percent'] ?? 0).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.green)),
              ])),
            );
          },
          childCount: _leaderboard.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }

  Widget _statPill(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  );
}
