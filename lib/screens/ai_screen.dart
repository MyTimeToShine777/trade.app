import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/ai_provider.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _chatCtrl = TextEditingController();
  final _analyzeCtrl = TextEditingController();
  final _compare1Ctrl = TextEditingController();
  final _compare2Ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _chatCtrl.dispose();
    _analyzeCtrl.dispose();
    _compare1Ctrl.dispose();
    _compare2Ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          ClayIconButton(
              icon: Icons.menu, onTap: () => Scaffold.of(context).openDrawer()),
          const SizedBox(width: 14),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('AI Hub',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary)),
                Text('Powered by Gemini',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ])),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                gradient: AppTheme.pinkGradient,
                borderRadius: BorderRadius.circular(14)),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.clayInset(depth: 0.6)),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Chat'),
              Tab(text: 'Analyze'),
              Tab(text: 'Compare'),
              Tab(text: 'Sentiment')
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
        _chatTab(),
        _analyzeTab(),
        _compareTab(),
        _sentimentTab()
      ])),
    ]));
  }

  // ═══════════════════ CHAT TAB ═══════════════════
  Widget _chatTab() {
    final ai = context.watch<AiProvider>();
    return Column(children: [
      Expanded(
        child: ai.chatMessages.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('TradeGuru AI',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Ask about stocks, market trends, trading strategies, or portfolio advice',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                const SizedBox(height: 20),
                Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                  _suggestChip('Best stocks to buy?'),
                  _suggestChip('Analyze RELIANCE'),
                  _suggestChip('Market outlook'),
                  _suggestChip('Portfolio advice'),
                ]),
              ]))
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ai.chatMessages.length + (ai.isChatLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= ai.chatMessages.length) return _typingBubble();
                  final msg = ai.chatMessages[i];
                  final isUser = msg['role'] == 'user';
                  return _chatBubble(msg['content'] ?? '', isUser);
                },
              ),
      ),
      if (ai.chatMessages.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.read<AiProvider>().clearChat(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('🗑️ Clear chat', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(children: [
          Expanded(child: ClayInput(controller: _chatCtrl, hintText: 'Ask TradeGuru...', prefixIcon: Icons.chat_bubble_outline, onSubmitted: (_) => _sendChat())),
          const SizedBox(width: 8),
          ClayIconButton(icon: Icons.send, gradient: AppTheme.accentGradient, onTap: _sendChat),
        ]),
      ),
    ]);
  }

  void _sendChat() {
    final q = _chatCtrl.text.trim();
    if (q.isEmpty) return;
    _chatCtrl.clear();
    context.read<AiProvider>().sendChat(q);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Widget _suggestChip(String text) => GestureDetector(
        onTap: () { _chatCtrl.text = text; _sendChat(); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border, width: 1)),
          child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _chatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32, height: 32, margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.accentGradient : null,
                color: isUser ? null : AppTheme.cardColor,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4), bottomRight: Radius.circular(isUser ? 4 : 18)),
                boxShadow: isUser ? AppTheme.glowShadow(AppTheme.accent, intensity: 0.15) : [],
              ),
              child: Text(text, style: TextStyle(fontSize: 14, color: isUser ? Colors.white : AppTheme.textPrimary, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingBubble() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(
              width: 32, height: 32, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16)),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border, width: 1)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
              SizedBox(width: 8),
              Text('Thinking...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))
            ]),
          ),
        ]),
      );

  // ═══════════════════ ANALYZE TAB ═══════════════════
  Widget _analyzeTab() {
    final ai = context.watch<AiProvider>();
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ClayInput(controller: _analyzeCtrl, hintText: 'Enter symbol (e.g., RELIANCE)', prefixIcon: Icons.analytics)),
            const SizedBox(width: 8),
            ClayButton(
                width: 100, isSmall: true, gradient: AppTheme.accentGradient, isLoading: ai.isAnalyzing,
                onPressed: () {
                  if (_analyzeCtrl.text.isNotEmpty) {
                    context.read<AiProvider>().analyzeStock(_analyzeCtrl.text.trim().toUpperCase());
                  }
                },
                child: const Text('Analyze', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
          if (ai.error != null && !ai.isAnalyzing && ai.analysis == null) ...[
            const SizedBox(height: 12),
            _errorCard(ai.error!),
          ],
          const SizedBox(height: 20),
          if (ai.analysis != null) _analysisCard(ai.analysis!),
        ]));
  }

  Widget _analysisCard(Map<String, dynamic> a) {
    final rec = (a['recommendation'] ?? a['action'] ?? 'HOLD').toString().toUpperCase();
    final risk = (a['riskLevel'] ?? 'MEDIUM').toString().toUpperCase();
    final conf = (a['confidenceLevel'] ?? a['actionConfidence'] ?? 'MEDIUM').toString().toUpperCase();
    final summary = (a['beginnerSummary'] ?? a['summary'] ?? a['actionReason'] ?? '').toString();
    final why = (a['whyThisCall'] is List) ? List<String>.from(a['whyThisCall']) : <String>[];
    final risks = (a['keyRisks'] is List) ? List<String>.from(a['keyRisks']) : <String>[];
    final strengths = (a['strengths'] is List) ? List<String>.from(a['strengths']) : <String>[];
    final weaknesses = (a['weaknesses'] is List) ? List<String>.from(a['weaknesses']) : <String>[];
    final targetPrice = a['targetPrice'];
    final targetTimeline = (a['targetTimeline'] ?? '').toString();
    final stopLoss = a['stopLoss'];
    final asOf = (a['asOf'] ?? '').toString();
    final keyInsight = (a['keyInsight'] ?? '').toString();

    Color c;
    if (rec.contains('BUY')) {
      c = AppTheme.green;
    } else if (rec.contains('SELL') || rec.contains('AVOID')) {
      c = AppTheme.red;
    } else {
      c = AppTheme.orange;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClayCard(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(gradient: AppTheme.cyanGradient, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.analytics, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            const Expanded(child: Text('AI Research', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withValues(alpha: 0.25))),
              child: Text(rec, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _miniStat('Risk', risk, risk == 'HIGH' ? AppTheme.red : risk == 'LOW' ? AppTheme.green : AppTheme.orange),
            const SizedBox(width: 8),
            _miniStat('Confidence', conf, conf == 'HIGH' ? AppTheme.green : AppTheme.orange),
            if (targetPrice != null) ...[const SizedBox(width: 8), _miniStat('Target', '₹$targetPrice', AppTheme.blue)],
            if (stopLoss != null) ...[const SizedBox(width: 8), _miniStat('Stop Loss', '₹$stopLoss', AppTheme.red)],
          ]),
          if (targetTimeline.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Timeline: $targetTimeline', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
              child: Text(summary, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5)),
            ),
          ],
          if (keyInsight.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Text('💡 ', style: TextStyle(fontSize: 14)),
              Expanded(child: Text(keyInsight, style: const TextStyle(fontSize: 13, color: AppTheme.accentLight, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic))),
            ]),
          ],
          if (asOf.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('As of: $asOf', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ]
        ]),
      ),
      if (strengths.isNotEmpty || weaknesses.isNotEmpty) ...[
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (strengths.isNotEmpty)
            Expanded(child: ClayCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💪 Strengths', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.green)),
              const SizedBox(height: 8),
              ...strengths.take(4).map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('✅ ', style: TextStyle(fontSize: 11)),
                Expanded(child: Text(s.toString(), style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.3))),
              ]))),
            ]))),
          if (strengths.isNotEmpty && weaknesses.isNotEmpty) const SizedBox(width: 10),
          if (weaknesses.isNotEmpty)
            Expanded(child: ClayCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('⚠️ Weaknesses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.red)),
              const SizedBox(height: 8),
              ...weaknesses.take(4).map((w) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('❌ ', style: TextStyle(fontSize: 11)),
                Expanded(child: Text(w.toString(), style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.3))),
              ]))),
            ]))),
        ]),
      ],
      if (why.isNotEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🎯 Why this call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          ...why.take(5).map((t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('• ', style: TextStyle(fontSize: 14, color: AppTheme.accent, fontWeight: FontWeight.w900)),
            Expanded(child: Text(t.toString(), style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.35))),
          ]))),
        ])),
      ],
      if (risks.isNotEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🛡️ Key Risks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.orange)),
          const SizedBox(height: 8),
          ...risks.take(4).map((t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('⚡ ', style: TextStyle(fontSize: 12)),
            Expanded(child: Text(t.toString(), style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.35))),
          ]))),
        ])),
      ],
      const SizedBox(height: 20),
    ]);
  }

  Widget _miniStat(String label, String value, Color c) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withValues(alpha: 0.2))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
      ]),
    ));
  }

  // ═══════════════════ COMPARE TAB ═══════════════════
  Widget _compareTab() {
    final ai = context.watch<AiProvider>();
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ClayInput(controller: _compare1Ctrl, hintText: 'Stock 1 (e.g., TCS)', prefixIcon: Icons.looks_one)),
            const SizedBox(width: 8),
            Expanded(child: ClayInput(controller: _compare2Ctrl, hintText: 'Stock 2 (e.g., INFY)', prefixIcon: Icons.looks_two)),
          ]),
          const SizedBox(height: 12),
          ClayButton(
              gradient: AppTheme.blueGradient, isLoading: ai.isComparing,
              onPressed: () {
                if (_compare1Ctrl.text.isNotEmpty && _compare2Ctrl.text.isNotEmpty) {
                  context.read<AiProvider>().compareStocks([
                    _compare1Ctrl.text.trim().toUpperCase(),
                    _compare2Ctrl.text.trim().toUpperCase()
                  ]);
                }
              },
              child: const Text('⚔️ Compare Stocks', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
          if (ai.error != null && !ai.isComparing && ai.comparison == null) ...[
            const SizedBox(height: 12),
            _errorCard(ai.error!),
          ],
          const SizedBox(height: 20),
          if (ai.comparison != null) _comparisonCard(ai.comparison!),
        ]));
  }

  Widget _comparisonCard(Map<String, dynamic> data) {
    final winner = (data['winner'] ?? '').toString();
    final comparison = (data['comparison'] ?? data['response'] ?? '').toString();
    final verdict = (data['verdict'] ?? '').toString();
    final metrics = data['metrics'] as Map<String, dynamic>? ?? {};

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (winner.isNotEmpty)
        ClayCard(gradient: AppTheme.greenGradient, padding: const EdgeInsets.all(16), child: Row(children: [
          const Text('🏆', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Winner', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(winner, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ])),
        ])),
      if (metrics.isNotEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: AppTheme.blueGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.compare_arrows, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            const Text('Metrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 12),
          // Column headers
          Row(children: [
            const Expanded(flex: 2, child: Text('Metric', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
            Expanded(child: Text(_compare1Ctrl.text.trim().toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent), textAlign: TextAlign.center)),
            Expanded(child: Text(_compare2Ctrl.text.trim().toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.blue), textAlign: TextAlign.center)),
          ]),
          const Divider(height: 16, color: AppTheme.border),
          ...metrics.entries.map((e) {
            final mData = e.value is Map ? e.value as Map : {};
            final v1 = mData['stock1']?.toString() ?? '-';
            final v2 = mData['stock2']?.toString() ?? '-';
            final mWinner = (mData['winner'] ?? '').toString().toUpperCase();
            final s1 = _compare1Ctrl.text.trim().toUpperCase();
            final s2 = _compare2Ctrl.text.trim().toUpperCase();
            final isS1 = mWinner == s1;
            final isS2 = mWinner == s2;
            return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
              Expanded(flex: 2, child: Text(e.key[0].toUpperCase() + e.key.substring(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
              Expanded(child: Text('${isS1 ? "✅ " : ""}$v1', style: TextStyle(fontSize: 11, fontWeight: isS1 ? FontWeight.w700 : FontWeight.w500, color: isS1 ? AppTheme.green : AppTheme.textSecondary), textAlign: TextAlign.center)),
              Expanded(child: Text('${isS2 ? "✅ " : ""}$v2', style: TextStyle(fontSize: 11, fontWeight: isS2 ? FontWeight.w700 : FontWeight.w500, color: isS2 ? AppTheme.green : AppTheme.textSecondary), textAlign: TextAlign.center)),
            ]));
          }),
        ])),
      ],
      if (verdict.isNotEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('⚖️ Verdict', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(verdict, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.5)),
        ])),
      ],
      if (comparison.isNotEmpty && metrics.isEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: AppTheme.blueGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.compare_arrows, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            const Text('Comparison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))
          ]),
          const SizedBox(height: 14),
          Text(comparison, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5)),
        ])),
      ],
      const SizedBox(height: 20),
    ]);
  }

  // ═══════════════════ SENTIMENT TAB ═══════════════════
  Widget _sentimentTab() {
    final ai = context.watch<AiProvider>();
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 8),
          ClayButton(
              gradient: AppTheme.pinkGradient, isLoading: ai.isSentimentLoading,
              onPressed: () => context.read<AiProvider>().getSentiment(),
              child: const Text('📊 Get Market Sentiment', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
          if (ai.error != null && !ai.isSentimentLoading && ai.sentiment == null) ...[
            const SizedBox(height: 12),
            _errorCard(ai.error!),
          ],
          const SizedBox(height: 20),
          if (ai.sentiment == null && !ai.isSentimentLoading)
            Column(children: [
              const SizedBox(height: 40),
              Container(width: 70, height: 70, decoration: BoxDecoration(gradient: AppTheme.pinkGradient, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.mood, color: Colors.white, size: 32)),
              const SizedBox(height: 16),
              const Text('Market Sentiment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text('Get AI-powered market mood analysis\nwith sector trends and advice', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ]),
          if (ai.sentiment != null) _sentimentCard(ai.sentiment!),
        ]));
  }

  Widget _sentimentCard(Map<String, dynamic> data) {
    final sentiment = (data['sentiment'] ?? 'Neutral').toString();
    final score = data['score'];
    final summary = (data['summary'] ?? data['response'] ?? '').toString();
    final advice = (data['advice'] ?? '').toString();
    final sectors = data['sectorTrends'] is List ? List<Map<String, dynamic>>.from(
      (data['sectorTrends'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{'name': e.toString()})
    ) : <Map<String, dynamic>>[];

    String emoji;
    Color sColor;
    if (sentiment.toLowerCase().contains('bullish') || sentiment.toLowerCase().contains('positive')) {
      emoji = '🟢'; sColor = AppTheme.green;
    } else if (sentiment.toLowerCase().contains('bearish') || sentiment.toLowerCase().contains('negative')) {
      emoji = '🔴'; sColor = AppTheme.red;
    } else {
      emoji = '🟡'; sColor = AppTheme.orange;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClayCard(padding: const EdgeInsets.all(20), child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(sentiment, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: sColor)),
        if (score != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: sColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Text('Score: $score/100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: sColor)),
          ),
        ],
      ])),
      if (summary.isNotEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📋 Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(summary, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.5)),
        ])),
      ],
      if (sectors.isNotEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📈 Sector Trends', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          ...sectors.map((s) {
            final sectorName = (s['sector'] ?? s['name'] ?? '').toString();
            final trend = (s['trend'] ?? s['outlook'] ?? '').toString();
            final isBull = trend.toLowerCase().contains('bull') || trend.toLowerCase().contains('positive') || trend.toLowerCase().contains('up');
            return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: isBull ? AppTheme.green : AppTheme.red, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(sectorName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
              Text(trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isBull ? AppTheme.green : AppTheme.red)),
            ]));
          }),
        ])),
      ],
      if (advice.isNotEmpty) ...[
        const SizedBox(height: 12),
        ClayCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('💡 AI Advice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.accentLight)),
          const SizedBox(height: 8),
          Text(advice, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.5)),
        ])),
      ],
      const SizedBox(height: 20),
    ]);
  }

  Widget _errorCard(String error) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.red.withValues(alpha: 0.3))),
      child: Row(children: [
        const Text('⚠️', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(error, style: const TextStyle(fontSize: 12, color: AppTheme.red), maxLines: 3, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
