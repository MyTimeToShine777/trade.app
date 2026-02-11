import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 16),
          Row(children: [
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                child: Center(child: Text('☰', style: TextStyle(fontSize: 18, color: AppTheme.textPrimary))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text('👤 Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
          ]),
          const SizedBox(height: 24),

          // Avatar
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(gradient: AppTheme.accentGradient, shape: BoxShape.circle, boxShadow: AppTheme.glowShadow(AppTheme.accent, intensity: 0.3)),
            child: Center(child: Text(auth.displayName.isNotEmpty ? '${auth.displayName[0].toUpperCase()}' : '👤', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(height: 16),
          Text(auth.displayName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(auth.user?['email'] ?? '', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),

          // Theme Selector
          ClayCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🎨 Color Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Current: ${theme.themeEmoji} ${theme.themeName}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: ThemeProvider.themes.entries.map((entry) {
              final t = entry.value;
              final isActive = theme.currentTheme == entry.key;
              return GestureDetector(
                onTap: () => theme.setTheme(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (MediaQuery.of(context).size.width - 60 - 20) / 3,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? (t['accent'] as Color).withValues(alpha: 0.15) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isActive ? t['accent'] as Color : AppTheme.border, width: isActive ? 2 : 1),
                  ),
                  child: Column(children: [
                    Text(t['emoji'] as String, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(t['name'] as String, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? t['accent'] as Color : AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _colorDot(t['accent'] as Color),
                      _colorDot(t['bg'] as Color),
                      _colorDot(t['secondary'] as Color),
                    ]),
                  ]),
                ),
              );
            }).toList()),
          ])),
          const SizedBox(height: 16),

          // Menu items with emojis
          ClayCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [
            _menuItem('💰', 'Wallet', () => Navigator.pushNamed(context, '/wallet')),
            _divider(),
            _menuItem('📋', 'Orders', () => Navigator.pushNamed(context, '/orders')),
            _divider(),
            _menuItem('⭐', 'Watchlist', () => Navigator.pushNamed(context, '/watchlist')),
            _divider(),
            _menuItem('📝', 'Trade Journal', () => Navigator.pushNamed(context, '/journal')),
            _divider(),
            _menuItem('🏆', '100 Days Challenge', () => Navigator.pushNamed(context, '/challenge')),
            _divider(),
            _menuItem('📚', 'Learn', () => Navigator.pushNamed(context, '/learn')),
          ])),
          const SizedBox(height: 16),

          ClayCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [
            _menuItem('⚠️', 'Risk Analysis', () => Navigator.pushNamed(context, '/risk')),
            _divider(),
            _menuItem('🔍', 'Stock Screener', () => Navigator.pushNamed(context, '/screener')),
            _divider(),
            _menuItem('🤖', 'Auto Invest', () => Navigator.pushNamed(context, '/auto-invest')),
          ])),
          const SizedBox(height: 24),

          // Logout
          ClayButton(
            color: AppTheme.surfaceColor,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🚪', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: AppTheme.red, fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 12),
          Text('Pugazh Stocks Simulator v2.0 ✨', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  static Widget _colorDot(Color c) => Container(width: 12, height: 12, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  static Widget _menuItem(String emoji, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
            Text('›', style: TextStyle(fontSize: 20, color: AppTheme.textLight)),
          ]),
        ),
      ),
    );
  }

  static Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Divider(height: 1, color: AppTheme.surfaceColor),
  );
}
