import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../services/api_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadEntries(); }

  Future<void> _loadEntries() async {
    try {
      final data = await ApiService.get('/journal');
      setState(() { _entries = List<Map<String, dynamic>>.from(data['entries'] ?? data['journal'] ?? []); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        onPressed: _showAddEntry,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            ClayIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            const Expanded(child: Text('Trade Journal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClayCard(gradient: AppTheme.blueGradient, padding: const EdgeInsets.all(20), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Trading Journal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Track your trades, emotions, and strategies. Analyze patterns to improve.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ])),
        )),

        if (_isLoading)
          const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.accent))))
        else if (_entries.isEmpty)
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.menu_book_outlined, size: 60, color: AppTheme.textLight),
            const SizedBox(height: 12),
            const Text('No journal entries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            const Text('Tap + to add your first entry', style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
          ])))
        else SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) {
            final e = _entries[i];
            final emotion = (e['emotion'] ?? 'neutral').toString();
            final emotionIcon = emotion == 'happy' ? '😊' : emotion == 'sad' ? '😔' : emotion == 'fearful' ? '😨' : emotion == 'greedy' ? '🤑' : '😐';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ClayCard(depth: 0.5, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(emotionIcon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e['title'] ?? e['symbol'] ?? 'Entry', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                  Text(e['date'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
                if (e['notes'] != null) ...[const SizedBox(height: 8), Text(e['notes']!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)],
                if (e['strategy'] != null) ...[const SizedBox(height: 6), ClayChip(label: e['strategy']!, icon: Icons.psychology)],
              ])),
            );
          },
          childCount: _entries.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ])),
    );
  }

  void _showAddEntry() {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String emotion = 'neutral';

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('New Journal Entry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          ClayInput(controller: titleCtrl, labelText: 'TITLE', hintText: 'What did you trade?', prefixIcon: Icons.title),
          const SizedBox(height: 14),
          ClayInput(controller: notesCtrl, labelText: 'NOTES', hintText: 'Describe your thought process...', prefixIcon: Icons.notes, maxLines: 3),
          const SizedBox(height: 14),
          Row(children: [
            for (final e in ['😊', '😐', '😔', '😨', '🤑']) ...[
              GestureDetector(
                onTap: () => ss(() => emotion = e),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: emotion == e ? AppTheme.accent.withValues(alpha: 0.15) : null, borderRadius: BorderRadius.circular(12)),
                  child: Text(e, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ]),
          const SizedBox(height: 20),
          ClayButton(gradient: AppTheme.accentGradient, onPressed: () async {
            try {
              await ApiService.post('/journal', {'title': titleCtrl.text, 'notes': notesCtrl.text, 'emotion': emotion, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now())});
              if (ctx.mounted) Navigator.pop(ctx);
              _loadEntries();
            } catch (_) {}
          }, child: const Text('Save Entry', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
      )),
    );
  }
}
