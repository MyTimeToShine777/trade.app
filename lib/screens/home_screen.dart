import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import 'dashboard_screen.dart';
import 'trade_screen.dart';
import 'portfolio_screen.dart';
import 'ai_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _tabs = const [
    ClayNavItem(emoji: '🏠', label: 'Home'),
    ClayNavItem(emoji: '📈', label: 'Trade'),
    ClayNavItem(emoji: '💼', label: 'Portfolio'),
    ClayNavItem(emoji: '🤖', label: 'AI'),
    ClayNavItem(emoji: '👤', label: 'Profile'),
  ];

  Widget _buildBody() {
    switch (_currentTab) {
      case 0: return DashboardScreen(onSwitchTab: (i) => setState(() => _currentTab = i));
      case 1: return const TradeScreen();
      case 2: return const PortfolioScreen();
      case 3: return const AiScreen();
      case 4: return const ProfileScreen();
      default: return DashboardScreen(onSwitchTab: (i) => setState(() => _currentTab = i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bgColor,
      drawer: _buildDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),
      bottomNavigationBar: ClayBottomNav(
        currentIndex: _currentTab,
        items: _tabs,
        onTap: (i) => setState(() => _currentTab = i),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.deepSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(28))),
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.glowShadow(AppTheme.accent, intensity: 0.3)),
                child: const Center(child: Text('💹', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Pugazh Stocks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                Text('Paper Trading 📄', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('✕', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary))),
                ),
              ),
            ]),
          ),
          Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), color: AppTheme.surfaceColor),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: [
              _dsection('📊 TRADING'),
              _ditem('🏠', 'Dashboard', 0),
              _ditem('📈', 'Trade', 1),
              _ditem('💼', 'Portfolio', 2),
              _dnavTo('📋', 'Orders', '/orders'),
              _dnavTo('⭐', 'Watchlist', '/watchlist'),
              _dnavTo('💰', 'Wallet', '/wallet'),
              const SizedBox(height: 8),
              _dsection('🤖 AI & ANALYSIS'),
              _ditem('🧠', 'AI Hub', 3),
              _dnavTo('🤖', 'Auto Invest', '/auto-invest'),
              _dnavTo('🔍', 'Screener', '/screener'),
              _dnavTo('⚠️', 'Risk Analysis', '/risk'),
              const SizedBox(height: 8),
              _dsection('💎 INVEST'),
              _dnavTo('🔄', 'SIP Plans', '/sip'),
              _dnavTo('🏦', 'Mutual Funds', '/mutual-funds'),
              _dnavTo('💎', 'Commodities', '/commodities'),
              const SizedBox(height: 8),
              _dsection('🎯 MORE'),
              _dnavTo('📝', 'Trade Journal', '/journal'),
              _dnavTo('🏆', 'Challenge', '/challenge'),
              _dnavTo('📚', 'Learn', '/learn'),
              _ditem('👤', 'Profile', 4),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _dsection(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 8, 20, 4),
    child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 1.2)),
  );

  Widget _ditem(String emoji, String label, int tabIndex) {
    final isActive = _currentTab == tabIndex;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); Navigator.pop(context); setState(() => _currentTab = tabIndex); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: isActive ? AppTheme.accent.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? AppTheme.accent : AppTheme.textPrimary)),
        ]),
      ),
    );
  }

  Widget _dnavTo(String emoji, String label, String route) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); Navigator.pop(context); Navigator.pushNamed(context, route); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }
}
