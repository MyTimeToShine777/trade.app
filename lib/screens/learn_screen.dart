import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../services/api_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  List<Map<String, dynamic>> _modules = [];
  bool _loading = true;
  Map<String, dynamic>? _selectedModule;
  List<Map<String, dynamic>> _lessons = [];
  bool _loadingLessons = false;

  // Fallback for when API doesn't return data
  final _fallbackModules = [
    {'id': '1', 'title': 'Stock Market Basics', 'description': 'Learn what stocks are and how markets work', 'lessonCount': 8},
    {'id': '2', 'title': 'Technical Analysis', 'description': 'Chart patterns, indicators, and trend analysis', 'lessonCount': 12},
    {'id': '3', 'title': 'Fundamental Analysis', 'description': 'Financial statements, ratios, and valuation', 'lessonCount': 10},
    {'id': '4', 'title': 'Risk Management', 'description': 'Position sizing, stop losses, and portfolio risk', 'lessonCount': 6},
    {'id': '5', 'title': 'Trading Psychology', 'description': 'Emotions, discipline, and mental frameworks', 'lessonCount': 8},
    {'id': '6', 'title': 'Options Trading', 'description': 'Calls, puts, strategies, and Greeks', 'lessonCount': 14},
    {'id': '7', 'title': 'Mutual Funds & SIP', 'description': 'Passive investing and systematic plans', 'lessonCount': 6},
    {'id': '8', 'title': 'Indian Markets', 'description': 'NSE, BSE, SEBI regulations, and taxation', 'lessonCount': 10},
  ];

  final _gradients = [AppTheme.accentGradient, AppTheme.blueGradient, AppTheme.greenGradient, AppTheme.redGradient, AppTheme.pinkGradient, AppTheme.cyanGradient, AppTheme.goldGradient, AppTheme.darkGradient];
  final _icons = [Icons.school, Icons.candlestick_chart, Icons.analytics, Icons.shield, Icons.psychology, Icons.call_split, Icons.account_balance, Icons.flag];

  @override
  void initState() { super.initState(); _loadModules(); }

  Future<void> _loadModules() async {
    try {
      final data = await ApiService.get('/education/modules');
      final list = data is List ? data : (data['modules'] ?? []);
      setState(() { _modules = List<Map<String, dynamic>>.from(list); _loading = false; });
    } catch (_) {
      setState(() { _modules = _fallbackModules; _loading = false; });
    }
  }

  Future<void> _openModule(Map<String, dynamic> module) async {
    final moduleId = module['id']?.toString() ?? module['_id']?.toString() ?? '';
    if (moduleId.isEmpty) return;
    setState(() { _selectedModule = module; _loadingLessons = true; _lessons = []; });
    try {
      final data = await ApiService.get('/education/modules/$moduleId');
      final list = data['lessons'] ?? data['module']?['lessons'] ?? [];
      setState(() { _lessons = List<Map<String, dynamic>>.from(list); _loadingLessons = false; });
    } catch (_) {
      setState(() { _loadingLessons = false; });
    }
  }

  Future<void> _completeLesson(String moduleId, String lessonId) async {
    try {
      await ApiService.post('/education/modules/$moduleId/lessons/$lessonId/complete', {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson completed! ✅'), backgroundColor: Colors.green),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // If viewing a module's lessons
    if (_selectedModule != null) {
      return _buildLessonView();
    }

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: _loading
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(slivers: [
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

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            Expanded(child: ClayStatCard(label: 'Modules', value: '${_modules.length}', icon: Icons.menu_book, iconGradient: AppTheme.accentGradient)),
            const SizedBox(width: 12),
            Expanded(child: ClayStatCard(label: 'Total Lessons', value: '${_modules.fold<int>(0, (sum, m) => sum + ((m['lessonCount'] ?? m['lessons'] ?? 0) as int))}', icon: Icons.play_circle, iconGradient: AppTheme.greenGradient)),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: const Text('Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        )),

        SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final m = _modules[i];
            final grad = _gradients[i % _gradients.length];
            final icon = _icons[i % _icons.length];
            final lessonCount = m['lessonCount'] ?? m['lessons'] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ClayCard(depth: 0.6, padding: const EdgeInsets.all(16), borderRadius: 18, onTap: () => _openModule(m), child: Row(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m['title'] ?? 'Module', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(m['description'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('$lessonCount lessons', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                ])),
                const Icon(Icons.chevron_right, color: AppTheme.textLight),
              ])),
            );
          },
          childCount: _modules.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }

  Widget _buildLessonView() {
    final module = _selectedModule!;
    final moduleId = module['id']?.toString() ?? module['_id']?.toString() ?? '';
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () {
              setState(() { _selectedModule = null; _lessons = []; });
            }),
            const SizedBox(width: 14),
            Expanded(child: Text(module['title'] ?? 'Module', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        if (module['description'] != null)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(module['description'], style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
          )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text('Lessons (${_lessons.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        )),

        if (_loadingLessons)
          const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())))
        else if (_lessons.isEmpty)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.menu_book, size: 48, color: AppTheme.textLight),
              const SizedBox(height: 12),
              const Text('No lessons available yet', style: TextStyle(color: AppTheme.textSecondary)),
            ])),
          ))
        else
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, i) {
              final lesson = _lessons[i];
              final lessonId = lesson['id']?.toString() ?? lesson['_id']?.toString() ?? '';
              final completed = lesson['completed'] == true;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: ClayCard(depth: 0.6, padding: const EdgeInsets.all(16), borderRadius: 18, onTap: () {
                  _showLessonContent(lesson, moduleId, lessonId);
                }, child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: completed ? AppTheme.greenGradient : AppTheme.darkGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: completed
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(lesson['title'] ?? 'Lesson ${i + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    if (lesson['description'] != null) ...[
                      const SizedBox(height: 2),
                      Text(lesson['description'], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ])),
                  const Icon(Icons.chevron_right, color: AppTheme.textLight),
                ])),
              );
            },
            childCount: _lessons.length,
          )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }

  void _showLessonContent(Map<String, dynamic> lesson, String moduleId, String lessonId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textLight, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(lesson['title'] ?? 'Lesson', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            Text(lesson['content'] ?? lesson['description'] ?? 'Content coming soon...', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () {
                _completeLesson(moduleId, lessonId);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
