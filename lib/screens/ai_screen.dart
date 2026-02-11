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
  final _sentimentCtrl = TextEditingController();
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
    _sentimentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: [
      // Header
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
      // Tabs
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.smart_toy,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('TradeGuru AI',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                        'Ask about stocks, market trends, trading strategies, or portfolio advice',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary))),
                const SizedBox(height: 20),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _suggestChip('Best stocks to buy?'),
                      _suggestChip('Analyze RELIANCE'),
                      _suggestChip('Market outlook'),
                      _suggestChip('Trading tips'),
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
      // Input
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(children: [
          Expanded(
              child: ClayInput(
                  controller: _chatCtrl,
                  hintText: 'Ask TradeGuru...',
                  prefixIcon: Icons.chat_bubble_outline,
                  onSubmitted: (_) => _sendChat())),
          const SizedBox(width: 8),
          ClayIconButton(
              icon: Icons.send,
              gradient: AppTheme.accentGradient,
              onTap: _sendChat),
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
      if (_scrollCtrl.hasClients)
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Widget _suggestChip(String text) => GestureDetector(
        onTap: () {
          _chatCtrl.text = text;
          _sendChat();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border, width: 1)),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600)),
        ),
      );

  Widget _chatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
          Flexible(
              child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isUser ? AppTheme.accentGradient : null,
              color: isUser ? null : AppTheme.cardColor,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18)),
              boxShadow: isUser
                  ? AppTheme.glowShadow(AppTheme.accent, intensity: 0.15)
                  : [],
            ),
            child: Text(text,
                style: TextStyle(
                    fontSize: 14,
                    color: isUser ? Colors.white : AppTheme.textPrimary,
                    height: 1.4)),
          )),
        ],
      ),
    );
  }

  Widget _typingBubble() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.smart_toy, color: Colors.white, size: 16)),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border, width: 1)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent)),
              SizedBox(width: 8),
              Text('Thinking...',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))
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
            Expanded(
                child: ClayInput(
                    controller: _analyzeCtrl,
                    hintText: 'Enter stock symbol (e.g., RELIANCE)',
                    prefixIcon: Icons.analytics)),
            const SizedBox(width: 8),
            ClayButton(
                width: 100,
                isSmall: true,
                gradient: AppTheme.accentGradient,
                isLoading: ai.isAnalyzing,
                onPressed: () {
                  if (_analyzeCtrl.text.isNotEmpty)
                    context
                        .read<AiProvider>()
                        .analyzeStock(_analyzeCtrl.text.trim().toUpperCase());
                },
                child: const Text('Analyze',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 20),
          if (ai.analysis != null) _analysisCard(ai.analysis!),
        ]));
  }

  Widget _analysisCard(Map<String, dynamic> a) {
    final rec =
        (a['recommendation'] ?? a['action'] ?? 'HOLD').toString().toUpperCase();
    final risk = (a['riskLevel'] ?? 'MEDIUM').toString().toUpperCase();
    final conf = (a['confidenceLevel'] ?? a['actionConfidence'] ?? 'MEDIUM')
        .toString()
        .toUpperCase();
    final summary =
        (a['beginnerSummary'] ?? a['summary'] ?? a['actionReason'] ?? '')
            .toString();
    final why = (a['whyThisCall'] is List)
        ? List<String>.from(a['whyThisCall'])
        : <String>[];
    final risks =
        (a['keyRisks'] is List) ? List<String>.from(a['keyRisks']) : <String>[];
    final asOf = (a['asOf'] ?? '').toString();

    Color c;
    if (rec.contains('BUY'))
      c = AppTheme.green;
    else if (rec.contains('SELL') || rec.contains('AVOID'))
      c = AppTheme.red;
    else
      c = AppTheme.orange;

    return ClayCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: AppTheme.cyanGradient,
                  borderRadius: BorderRadius.circular(12)),
              child:
                  const Icon(Icons.analytics, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          const Expanded(
              child: Text('AI Research (Beginner)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.withValues(alpha: 0.25))),
            child: Text(rec,
                style: TextStyle(
                    color: c, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 10),
        Text('Risk: $risk  •  Confidence: $conf',
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        if (summary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(summary,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary, height: 1.5)),
        ],
        if (why.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text('Why this call',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          ...why.take(4).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $t',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.35)),
              )),
        ],
        if (risks.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('Key risks',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          ...risks.take(3).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $t',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.35)),
              )),
        ],
        if (asOf.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('As of: $asOf',
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ]
      ]),
    );
  }

  // ═══════════════════ COMPARE TAB ═══════════════════
  Widget _compareTab() {
    final ai = context.watch<AiProvider>();
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: ClayInput(
                    controller: _compare1Ctrl,
                    hintText: 'Stock 1 (e.g., TCS)',
                    prefixIcon: Icons.looks_one)),
            const SizedBox(width: 8),
            Expanded(
                child: ClayInput(
                    controller: _compare2Ctrl,
                    hintText: 'Stock 2 (e.g., INFY)',
                    prefixIcon: Icons.looks_two)),
          ]),
          const SizedBox(height: 12),
          ClayButton(
              gradient: AppTheme.blueGradient,
              isLoading: ai.isComparing,
              onPressed: () {
                if (_compare1Ctrl.text.isNotEmpty &&
                    _compare2Ctrl.text.isNotEmpty)
                  context.read<AiProvider>().compareStocks([
                    _compare1Ctrl.text.trim().toUpperCase(),
                    _compare2Ctrl.text.trim().toUpperCase()
                  ]);
              },
              child: const Text('Compare Stocks',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700))),
          const SizedBox(height: 20),
          if (ai.comparison != null)
            ClayCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                gradient: AppTheme.blueGradient,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.compare_arrows,
                                color: Colors.white, size: 18)),
                        const SizedBox(width: 10),
                        const Text('Comparison',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary))
                      ]),
                      const SizedBox(height: 16),
                      Text(
                          ai.comparison!['comparison'] ??
                              ai.comparison!['response'] ??
                              ai.comparison.toString(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                              height: 1.5)),
                    ])),
        ]));
  }

  // ═══════════════════ SENTIMENT TAB ═══════════════════
  Widget _sentimentTab() {
    final ai = context.watch<AiProvider>();
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: ClayInput(
                    controller: _sentimentCtrl,
                    hintText: 'Enter symbol (e.g., HDFC)',
                    prefixIcon: Icons.mood)),
            const SizedBox(width: 8),
            ClayButton(
                width: 110,
                isSmall: true,
                gradient: AppTheme.pinkGradient,
                isLoading: ai.isSentimentLoading,
                onPressed: () {
                  if (_sentimentCtrl.text.isNotEmpty)
                    context
                        .read<AiProvider>()
                        .getSentiment(_sentimentCtrl.text.trim().toUpperCase());
                },
                child: const Text('Analyze',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 20),
          if (ai.sentiment != null)
            ClayCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                gradient: AppTheme.pinkGradient,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.mood,
                                color: Colors.white, size: 18)),
                        const SizedBox(width: 10),
                        const Text('Sentiment Analysis',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary))
                      ]),
                      const SizedBox(height: 16),
                      Text(
                          ai.sentiment!['sentiment'] ??
                              ai.sentiment!['response'] ??
                              ai.sentiment.toString(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                              height: 1.5)),
                    ])),
        ]));
  }
}
