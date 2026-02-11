import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key});
  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  final _fmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  String? _symbol;
  bool _loaded = false;
  String _chartPeriod = '1y';
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && !_loaded) {
      _loaded = true;
      _symbol = args;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
    }
  }

  void _loadAll() {
    final m = context.read<MarketProvider>();
    m.getStockQuote(_symbol!);
    m.getStockAnalysis(_symbol!);
    m.getStockFundamentals(_symbol!);
    m.getStockChart(_symbol!, period: _chartPeriod);
    m.getFundamentalScore(_symbol!);
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final stock = market.selectedStock;
    final ai = market.stockAnalysis;
    final price = (stock?['price'] ?? stock?['currentPrice'] ?? 0).toDouble();
    final change = (stock?['change'] ?? 0).toDouble();
    final changePct =
        (stock?['changePercent'] ?? stock?['change_percent'] ?? 0).toDouble();
    final isPos = changePct >= 0;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          // ─── HEADER ───
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () {
                  market.clearSelectedStock();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border)),
                  child: const Center(
                      child: Text('←',
                          style: TextStyle(
                              fontSize: 20, color: AppTheme.textPrimary))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(_symbol ?? '',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary)),
                    Text(stock?['name'] ?? stock?['longName'] ?? '',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ])),
              if (ai != null) _aiBadge(ai),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  try {
                    await context
                        .read<PortfolioProvider>()
                        .addToWatchlist(_symbol!, stock?['name'] ?? _symbol!);
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Added to watchlist ⭐')));
                  } catch (_) {}
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border)),
                  child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 18))),
                ),
              ),
            ]),
          )),

          // ─── PRICE CARD ───
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.cardColor,
                  AppTheme.surfaceColor.withValues(alpha: 0.5)
                ]),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_fmt.format(price),
                          style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -1)),
                      const SizedBox(width: 12),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: (isPos ? AppTheme.green : AppTheme.red)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(isPos ? '📈' : '📉',
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                  '${isPos ? '+' : ''}${change.toStringAsFixed(2)} (${changePct.toStringAsFixed(2)}%)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isPos
                                          ? AppTheme.green
                                          : AppTheme.red)),
                            ]),
                          )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      _miniMetric('📊 Vol',
                          _fmtNum((stock?['volume'] ?? 0).toDouble())),
                      _miniMetric('🏦 MCap',
                          _fmtNum((stock?['marketCap'] ?? 0).toDouble())),
                      _miniMetric(
                          '📈 High',
                          _fmt.format((stock?['fiftyTwoWeekHigh'] ??
                                  stock?['high'] ??
                                  0)
                              .toDouble())),
                      _miniMetric(
                          '📉 Low',
                          _fmt.format(
                              (stock?['fiftyTwoWeekLow'] ?? stock?['low'] ?? 0)
                                  .toDouble())),
                    ]),
                  ]),
            ),
          )),

          // ─── CHART ───
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClayCard(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(children: [
                    const Text('📊', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Text('Price Chart',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    const Spacer(),
                    ..._chartPeriodChips(),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(height: 200, child: _buildChart(market)),
                ])),
          )),

          // ─── TABS ───
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border)),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(14)),
                labelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                unselectedLabelColor: AppTheme.textSecondary,
                labelColor: Colors.white,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (_) => setState(() {}),
                tabs: const [
                  Tab(text: '🤖 AI'),
                  Tab(text: '📊 Data'),
                  Tab(text: '💪 Score'),
                  Tab(text: '⚡ Tech')
                ],
              ),
            ),
          )),

          // ─── TAB CONTENT ───
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildTabContent(market)),
          )),

          // ─── TRADE BUTTONS ───
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(children: [
              Expanded(
                  child: ClayButton(
                      gradient: AppTheme.greenGradient,
                      onPressed: () => _trade('BUY', stock, price),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('💰 ', style: TextStyle(fontSize: 16)),
                            Text('BUY',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800))
                          ]))),
              const SizedBox(width: 12),
              Expanded(
                  child: ClayButton(
                      gradient: AppTheme.redGradient,
                      onPressed: () => _trade('SELL', stock, price),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('💸 ', style: TextStyle(fontSize: 16)),
                            Text('SELL',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800))
                          ]))),
            ]),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ]),
      ),
    );
  }

  Widget _aiBadge(Map<String, dynamic> ai) {
    final action = (ai['action'] ?? ai['recommendation'] ?? 'HOLD')
        .toString()
        .toUpperCase();
    Color c;
    String emoji;
    if (action.contains('BUY')) {
      c = AppTheme.green;
      emoji = '🟢';
    } else if (action.contains('SELL')) {
      c = AppTheme.red;
      emoji = '🔴';
    } else {
      c = AppTheme.orange;
      emoji = '🟡';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(action.split(' ').last,
            style:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c))
      ]),
    );
  }

  Widget _miniMetric(String label, String value) => Expanded(
          child: Column(children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      ]));

  List<Widget> _chartPeriodChips() => ['1m', '3m', '6m', '1y']
      .map((p) => GestureDetector(
            onTap: () {
              setState(() => _chartPeriod = p);
              context.read<MarketProvider>().getStockChart(_symbol!, period: p);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _chartPeriod == p
                      ? AppTheme.accent
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(p.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _chartPeriod == p
                          ? Colors.white
                          : AppTheme.textSecondary)),
            ),
          ))
      .toList();

  Widget _buildChart(MarketProvider market) {
    if (market.isLoadingChart)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    final chart = market.stockChart;
    if (chart == null)
      return const Center(
          child: Text('📈 Loading chart...',
              style: TextStyle(color: AppTheme.textSecondary)));
    final candles = List<Map<String, dynamic>>.from(chart['candles'] ?? []);
    if (candles.isEmpty)
      return const Center(
          child: Text('No chart data',
              style: TextStyle(color: AppTheme.textSecondary)));

    final spots = <FlSpot>[];
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (int i = 0; i < candles.length; i++) {
      final close = (candles[i]['close'] ?? 0).toDouble();
      if (close > 0) {
        spots.add(FlSpot(i.toDouble(), close));
        if (close < minY) minY = close;
        if (close > maxY) maxY = close;
      }
    }
    if (spots.isEmpty)
      return const Center(
          child:
              Text('No data', style: TextStyle(color: AppTheme.textSecondary)));
    final range = maxY - minY;
    final isUp = spots.last.y >= spots.first.y;
    final lineColor = isUp ? AppTheme.green : AppTheme.red;

    return LineChart(LineChartData(
      gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: range / 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppTheme.border, strokeWidth: 0.5)),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minY: minY - range * 0.05,
      maxY: maxY + range * 0.05,
      lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: AppTheme.cardColor,
        getTooltipItems: (spots) => spots
            .map((s) => LineTooltipItem(
                '₹${s.y.toStringAsFixed(2)}',
                TextStyle(
                    color: lineColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)))
            .toList(),
      )),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.15,
          color: lineColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withValues(alpha: 0.2),
                    lineColor.withValues(alpha: 0.0)
                  ])),
        )
      ],
    ));
  }

  Widget _buildTabContent(MarketProvider market) {
    switch (_tabCtrl.index) {
      case 0:
        return _aiTab(market);
      case 1:
        return _fundamentalsTab(market);
      case 2:
        return _scoreTab(market);
      case 3:
        return _technicalTab(market);
      default:
        return _aiTab(market);
    }
  }

  // ─── AI TAB ───
  Widget _aiTab(MarketProvider market) {
    if (market.isAnalyzing) return _loadingWidget('🤖 AI is analyzing...');
    final ai = market.stockAnalysis;
    if (ai == null) return _emptyWidget('No AI analysis available');
    final action = (ai['action'] ?? 'HOLD').toString().toUpperCase();
    final confidence =
        ai['actionConfidence'] ?? ai['confidenceLevel'] ?? 'MEDIUM';
    final reason =
        ai['actionReason'] ?? ai['beginnerSummary'] ?? ai['summary'] ?? '';
    final target = ai['targetPrice'];
    final stopLoss = ai['stopLoss'];
    final riskReward = ai['riskRewardRatio'] ?? '';
    final riskLevel = ai['riskLevel'] ?? '';
    final strengths = List<String>.from(ai['strengths'] ?? []);
    final weaknesses = List<String>.from(ai['weaknesses'] ?? []);
    final traderAdvice = ai['traderAdvice'] as Map<String, dynamic>? ?? {};
    final keyInsight = ai['keyInsight'] ?? '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                action.contains('BUY')
                    ? AppTheme.green.withValues(alpha: 0.15)
                    : action.contains('SELL')
                        ? AppTheme.red.withValues(alpha: 0.15)
                        : AppTheme.orange.withValues(alpha: 0.15),
                AppTheme.cardColor
              ]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                  action.contains('BUY')
                      ? '🟢'
                      : action.contains('SELL')
                          ? '🔴'
                          : '🟡',
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('AI: $action',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary)),
                    Text('Confidence: $confidence  •  Risk: $riskLevel',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ]))
            ]),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(reason,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary, height: 1.5))
            ],
          ])),
      const SizedBox(height: 12),
      if (target != null || stopLoss != null) ...[
        Row(children: [
          if (target != null)
            Expanded(
                child: _infoCard('🎯 Target', _fmt.format(_toDouble(target)),
                    AppTheme.green)),
          if (target != null && stopLoss != null) const SizedBox(width: 8),
          if (stopLoss != null)
            Expanded(
                child: _infoCard('🛑 Stop Loss',
                    _fmt.format(_toDouble(stopLoss)), AppTheme.red)),
          if (riskReward.toString().isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
                child:
                    _infoCard('⚖️ R:R', riskReward.toString(), AppTheme.blue))
          ],
        ]),
        const SizedBox(height: 12),
      ],
      if (keyInsight.isNotEmpty) ...[
        _label('💡 Key Insight'),
        ClayCard(
            padding: const EdgeInsets.all(14),
            child: Text(keyInsight,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textPrimary, height: 1.4))),
        const SizedBox(height: 12)
      ],
      if (strengths.isNotEmpty) ...[
        _label('💪 Strengths'),
        ...strengths.take(5).map((s) => _bullet(s, '✅')),
        const SizedBox(height: 10)
      ],
      if (weaknesses.isNotEmpty) ...[
        _label('⚠️ Weaknesses'),
        ...weaknesses.take(5).map((s) => _bullet(s, '❌')),
        const SizedBox(height: 10)
      ],
      if (traderAdvice.isNotEmpty) ...[
        _label('📋 Trader Advice'),
        if (traderAdvice['longTermInvestor'] != null)
          _adviceRow(
              '🏦 Long Term', traderAdvice['longTermInvestor'].toString()),
        if (traderAdvice['swingTrader'] != null)
          _adviceRow('🔄 Swing', traderAdvice['swingTrader'].toString()),
        if (traderAdvice['intraday'] != null)
          _adviceRow('⚡ Intraday', traderAdvice['intraday'].toString()),
      ],
    ]);
  }

  // ─── FUNDAMENTALS TAB ───
  Widget _fundamentalsTab(MarketProvider market) {
    if (market.isLoadingFundamentals)
      return _loadingWidget('📊 Loading fundamentals...');
    final f = market.stockFundamentals;
    final stock = market.selectedStock;
    if (f == null && stock == null) return _emptyWidget('No fundamental data');
    final pe = (f?['pe'] ?? stock?['pe'] ?? 0).toDouble();
    final eps = (f?['eps'] ?? stock?['eps'] ?? 0).toDouble();
    final pb = (f?['pb'] ?? stock?['priceToBook'] ?? 0).toDouble();
    final roe = (f?['roe'] ?? 0).toDouble();
    final debtEq = (f?['debtToEquity'] ?? 0).toDouble();
    final divYield =
        (f?['dividendYield'] ?? stock?['dividend'] ?? 0).toDouble();
    final beta = (f?['beta'] ?? 0).toDouble();
    final marketCap = (f?['marketCap'] ?? stock?['marketCap'] ?? 0).toDouble();
    final bookVal = (f?['bookValue'] ?? stock?['bookValue'] ?? 0).toDouble();
    final profitMargin = (f?['profitMargin'] ?? 0).toDouble();
    final revenueGrowth = (f?['revenueGrowth'] ?? 0).toDouble();
    final opMargin = (f?['operatingMargin'] ?? 0).toDouble();
    final currentRatio = (f?['currentRatio'] ?? 0).toDouble();
    final high52 =
        (f?['fiftyTwoWeekHigh'] ?? stock?['fiftyTwoWeekHigh'] ?? 0).toDouble();
    final low52 =
        (f?['fiftyTwoWeekLow'] ?? stock?['fiftyTwoWeekLow'] ?? 0).toDouble();
    final cap = f?['capCategory'] ?? '';
    final healthScore = (f?['healthScore'] ?? 0).toDouble();
    final price = (stock?['price'] ?? 0).toDouble();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('💰 Valuation'),
      _dGrid([
        _dItem(
            'P/E',
            pe > 0 ? pe.toStringAsFixed(2) : 'N/A',
            pe > 0 && pe < 15
                ? AppTheme.green
                : pe > 25
                    ? AppTheme.red
                    : null),
        _dItem('P/B', pb > 0 ? pb.toStringAsFixed(2) : 'N/A', null),
        _dItem('EPS', eps != 0 ? '₹${eps.toStringAsFixed(2)}' : 'N/A', null),
        _dItem('Book Val',
            bookVal > 0 ? '₹${bookVal.toStringAsFixed(0)}' : 'N/A', null)
      ]),
      const SizedBox(height: 12),
      _label('📈 Profitability'),
      _dGrid([
        _dItem(
            'ROE',
            roe > 0 ? '${roe.toStringAsFixed(1)}%' : 'N/A',
            roe > 15
                ? AppTheme.green
                : roe > 10
                    ? AppTheme.orange
                    : null),
        _dItem(
            'Profit Mgn',
            profitMargin != 0
                ? '${(profitMargin * 100).toStringAsFixed(1)}%'
                : 'N/A',
            null),
        _dItem(
            'Op. Margin',
            opMargin != 0 ? '${(opMargin * 100).toStringAsFixed(1)}%' : 'N/A',
            null),
        _dItem(
            'Rev Growth',
            revenueGrowth != 0
                ? '${(revenueGrowth * 100).toStringAsFixed(1)}%'
                : 'N/A',
            revenueGrowth > 0 ? AppTheme.green : AppTheme.red)
      ]),
      const SizedBox(height: 12),
      _label('🏥 Financial Health'),
      _dGrid([
        _dItem('Debt/Eq', debtEq > 0 ? debtEq.toStringAsFixed(2) : 'N/A',
            debtEq > 1 ? AppTheme.red : AppTheme.green),
        _dItem(
            'Curr Ratio',
            currentRatio > 0 ? currentRatio.toStringAsFixed(2) : 'N/A',
            currentRatio > 1.5 ? AppTheme.green : AppTheme.orange),
        _dItem('Beta', beta > 0 ? beta.toStringAsFixed(2) : 'N/A', null),
        _dItem('Div Yield',
            divYield > 0 ? '${divYield.toStringAsFixed(2)}%' : 'N/A', null)
      ]),
      const SizedBox(height: 12),
      _label('📏 52-Week Range'),
      ClayCard(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_fmt.format(low52),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.red,
                      fontWeight: FontWeight.w700)),
              if (cap.isNotEmpty)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(cap,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent))),
              if (healthScore > 0)
                Text('Health: ${healthScore.toInt()}/100',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: healthScore > 60
                            ? AppTheme.green
                            : AppTheme.orange)),
              Text(_fmt.format(high52),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.green,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            ClayProgressBar(
                value:
                    high52 > low52 ? (price - low52) / (high52 - low52) : 0.5,
                gradient: AppTheme.accentGradient),
            const SizedBox(height: 6),
            Text('Market Cap: ${_fmtNum(marketCap)}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ])),
    ]);
  }

  // ─── SCORE TAB ───
  Widget _scoreTab(MarketProvider market) {
    final score = market.fundamentalScore;
    if (score == null) return _loadingWidget('💪 Loading score...');
    final overall = (score['overallScore'] ?? 0).toDouble();
    final rec = score['recommendation'] ?? 'HOLD';
    final redFlags = List<Map<String, dynamic>>.from(score['redFlags'] ?? []);
    final greenFlags =
        List<Map<String, dynamic>>.from(score['greenFlags'] ?? []);
    final scores = score['scores'] as Map<String, dynamic>? ?? {};
    final risk = score['riskLevel'] ?? 'MEDIUM';
    Color recC = rec == 'BUY'
        ? AppTheme.green
        : rec == 'SELL'
            ? AppTheme.red
            : AppTheme.orange;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [recC.withValues(alpha: 0.12), AppTheme.cardColor]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border)),
          child: Row(children: [
            SizedBox(
                width: 80,
                height: 80,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                      value: overall / 100,
                      strokeWidth: 6,
                      backgroundColor: AppTheme.surfaceColor,
                      color: recC),
                  Text('${overall.toInt()}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: recC))
                ])),
            const SizedBox(width: 20),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Fundamental Score',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: recC.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(rec,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: recC))),
                    const SizedBox(width: 8),
                    Text('Risk: $risk',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary))
                  ]),
                ])),
          ])),
      if (scores.isNotEmpty) ...[
        const SizedBox(height: 12),
        _label('📊 Score Breakdown'),
        ...scores.entries.take(8).map((e) {
          final v = (e.value ?? 0).toDouble();
          return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(
                    width: 90,
                    child: Text(e.key.replaceAll('_', ' '),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary))),
                Expanded(
                    child: ClayProgressBar(
                        value: v / 100,
                        gradient: LinearGradient(
                            colors: [recC, recC.withValues(alpha: 0.5)]))),
                const SizedBox(width: 8),
                Text('${v.toInt()}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: v > 60
                            ? AppTheme.green
                            : v > 40
                                ? AppTheme.orange
                                : AppTheme.red))
              ]));
        })
      ],
      if (greenFlags.isNotEmpty) ...[
        const SizedBox(height: 10),
        _label('✅ Green Flags'),
        ...greenFlags
            .take(5)
            .map((f) => _bullet(f['flag']?.toString() ?? '', '🟢'))
      ],
      if (redFlags.isNotEmpty) ...[
        const SizedBox(height: 10),
        _label('🚩 Red Flags'),
        ...redFlags.take(5).map(
            (f) => _bullet('${f['flag'] ?? ''} — ${f['detail'] ?? ''}', '🔴'))
      ],
    ]);
  }

  // ─── TECHNICAL TAB ───
  Widget _technicalTab(MarketProvider market) {
    final ai = market.stockAnalysis;
    final chart = market.stockChart;
    if (ai == null && chart == null)
      return _loadingWidget('⚡ Loading technicals...');
    final techSummary = ai?['technicalSummary'] as Map<String, dynamic>? ?? {};
    final indicators = chart?['indicators'] as Map<String, dynamic>? ?? {};
    final macdSignal = ai?['macdSignal'] ?? '';
    final volumeSignal = ai?['volumeSignal'] ?? '';
    final trendAnalysis = ai?['trendAnalysis'] ?? '';
    final candleSignal = ai?['candlestickSignal'] ?? '';
    final techVerdict = ai?['technicalVerdict'] ?? '';
    final support = List.from(ai?['supportLevels'] ?? []);
    final resistance = List.from(ai?['resistanceLevels'] ?? []);
    final trend = techSummary['trend'] ?? indicators['trend'] ?? '';
    final rsiRaw = indicators['rsi'];
    final rsi = rsiRaw is num
        ? rsiRaw.toDouble()
        : (rsiRaw is Map ? (rsiRaw['value'] ?? 0).toDouble() : null);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (techVerdict.isNotEmpty) ...[
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: techVerdict.toString().contains('BULL')
                    ? AppTheme.green.withValues(alpha: 0.1)
                    : techVerdict.toString().contains('BEAR')
                        ? AppTheme.red.withValues(alpha: 0.1)
                        : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border)),
            child: Row(children: [
              Text(
                  techVerdict.toString().contains('BULL')
                      ? '🐂'
                      : techVerdict.toString().contains('BEAR')
                          ? '🐻'
                          : '⚖️',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(techVerdict.toString(),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)))
            ])),
        const SizedBox(height: 12)
      ],
      _label('📡 Signals'),
      _dGrid([
        _dItem('Trend', trend.toString(),
            trend.toString().contains('UP') ? AppTheme.green : AppTheme.red),
        _dItem(
            'RSI',
            rsi != null ? rsi.toStringAsFixed(1) : 'N/A',
            (rsi ?? 50) > 70
                ? AppTheme.red
                : (rsi ?? 50) < 30
                    ? AppTheme.green
                    : null),
        _dItem(
            'MACD',
            macdSignal.toString().isNotEmpty
                ? macdSignal.toString().split(' ').first
                : 'N/A',
            null),
        _dItem(
            'Volume',
            volumeSignal.toString().isNotEmpty
                ? volumeSignal.toString().split(' ').first
                : 'N/A',
            null)
      ]),
      if (support.isNotEmpty || resistance.isNotEmpty) ...[
        const SizedBox(height: 12),
        _label('📐 Support & Resistance'),
        Row(children: [
          if (support.isNotEmpty)
            Expanded(
                child: ClayCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🟢 Support',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.green)),
                          ...support.take(3).map((s) => Text(
                              _fmt.format(_toDouble(s)),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary)))
                        ]))),
          if (support.isNotEmpty && resistance.isNotEmpty)
            const SizedBox(width: 8),
          if (resistance.isNotEmpty)
            Expanded(
                child: ClayCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔴 Resistance',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.red)),
                          ...resistance.take(3).map((r) => Text(
                              _fmt.format(_toDouble(r)),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary)))
                        ]))),
        ])
      ],
      if (candleSignal.isNotEmpty) ...[
        const SizedBox(height: 12),
        _label('🕯️ Candlestick'),
        ClayCard(
            padding: const EdgeInsets.all(14),
            child: Text(candleSignal,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textPrimary, height: 1.4)))
      ],
      if (trendAnalysis.isNotEmpty) ...[
        const SizedBox(height: 12),
        _label('📈 Trend'),
        ClayCard(
            padding: const EdgeInsets.all(14),
            child: Text(trendAnalysis,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textPrimary, height: 1.4)))
      ],
    ]);
  }

  // ═══════════ HELPERS ═══════════
  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(t,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary)));
  Widget _loadingWidget(String m) => Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: AppTheme.accent),
        const SizedBox(height: 12),
        Text(m, style: const TextStyle(color: AppTheme.textSecondary))
      ])));
  Widget _emptyWidget(String m) => Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
          child:
              Text(m, style: const TextStyle(color: AppTheme.textSecondary))));
  Widget _infoCard(String l, String v, Color c) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border)),
      child: Column(children: [
        Text(l,
            style:
                const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(v,
            style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c))
      ]));
  Widget _dGrid(List<Widget> items) =>
      Wrap(spacing: 8, runSpacing: 8, children: items);
  Widget _dItem(String l, String v, Color? c) => Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        Text(v,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c ?? AppTheme.textPrimary))
      ]));
  Widget _bullet(String t, String e) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(t,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textPrimary, height: 1.4)))
      ]));
  Widget _adviceRow(String l, String a) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClayCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent)),
            const SizedBox(height: 4),
            Text(a,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textPrimary, height: 1.3))
          ])));
  double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
  String _fmtNum(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  void _trade(String type, Map<String, dynamic>? stock, double price) {
    if (stock == null || _symbol == null) return;
    final qtyCtrl = TextEditingController(text: '1');
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.cardColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              return Padding(
                  padding: EdgeInsets.fromLTRB(
                      24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    Text('${type == 'BUY' ? '💰' : '💸'} $type $_symbol',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text('at ${_fmt.format(price)}',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(height: 20),
                    ClayInput(
                        controller: qtyCtrl,
                        labelText: 'QUANTITY',
                        hintText: '1',
                        prefixIcon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => ss(() {})),
                    const SizedBox(height: 12),
                    ClayCard(
                        depth: 0.4,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary)),
                              Text(_fmt.format(price * qty),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary))
                            ])),
                    const SizedBox(height: 20),
                    ClayButton(
                        gradient: type == 'BUY'
                            ? AppTheme.greenGradient
                            : AppTheme.redGradient,
                        onPressed: qty < 1 ? null : () async {
                          HapticFeedback.mediumImpact();
                          try {
                            await context.read<PortfolioProvider>().placeOrder(
                                symbol: _symbol!,
                                name: (stock['name'] ?? _symbol) ?? _symbol!,
                                type: type,
                                quantity: qty,
                                price: price);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('$type order placed! ✅'),
                                      backgroundColor: type == 'BUY'
                                          ? AppTheme.green
                                          : AppTheme.red));
                            }
                          } catch (e) {
                            if (ctx.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppTheme.red));
                          }
                        },
                        child: Text('Confirm $type ✨',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700))),
                  ]));
            }));
  }
}
