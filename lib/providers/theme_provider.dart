import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Theme modes
  static const String _key = 'app_theme';
  String _currentTheme = 'midnight'; // midnight, ocean, forest, sunset, neon, light
  
  String get currentTheme => _currentTheme;
  bool get isDark => _currentTheme != 'light';

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = prefs.getString(_key) ?? 'midnight';
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme);
    notifyListeners();
  }

  // ═══════════════════ THEME DEFINITIONS ═══════════════════
  static const themes = {
    'midnight': {
      'name': 'Midnight Purple',
      'emoji': '🌌',
      'bg': Color(0xFF0A0E17),
      'card': Color(0xFF141B2D),
      'surface': Color(0xFF1C2438),
      'deep': Color(0xFF0D1220),
      'accent': Color(0xFF7C3AED),
      'accentLight': Color(0xFFA78BFA),
      'secondary': Color(0xFF2DD4BF),
      'textPrimary': Color(0xFFF1F5F9),
      'textSecondary': Color(0xFF8899A6),
      'border': Color(0xFF1E2A3A),
    },
    'ocean': {
      'name': 'Ocean Blue',
      'emoji': '🌊',
      'bg': Color(0xFF0B1120),
      'card': Color(0xFF122040),
      'surface': Color(0xFF1A2D52),
      'deep': Color(0xFF081428),
      'accent': Color(0xFF0EA5E9),
      'accentLight': Color(0xFF38BDF8),
      'secondary': Color(0xFF06D6A0),
      'textPrimary': Color(0xFFE8F4FD),
      'textSecondary': Color(0xFF7BA3C9),
      'border': Color(0xFF1A3055),
    },
    'forest': {
      'name': 'Forest Green',
      'emoji': '🌲',
      'bg': Color(0xFF0A1210),
      'card': Color(0xFF132420),
      'surface': Color(0xFF1C332E),
      'deep': Color(0xFF081410),
      'accent': Color(0xFF10B981),
      'accentLight': Color(0xFF34D399),
      'secondary': Color(0xFFF59E0B),
      'textPrimary': Color(0xFFE8F5E9),
      'textSecondary': Color(0xFF7BAA8A),
      'border': Color(0xFF1C3528),
    },
    'sunset': {
      'name': 'Sunset Fire',
      'emoji': '🌅',
      'bg': Color(0xFF140A0A),
      'card': Color(0xFF2D1419),
      'surface': Color(0xFF3D1C22),
      'deep': Color(0xFF120808),
      'accent': Color(0xFFEF4444),
      'accentLight': Color(0xFFF87171),
      'secondary': Color(0xFFFBBF24),
      'textPrimary': Color(0xFFFFF1F2),
      'textSecondary': Color(0xFFB08888),
      'border': Color(0xFF3A1E22),
    },
    'neon': {
      'name': 'Neon Cyber',
      'emoji': '💜',
      'bg': Color(0xFF0D0D1A),
      'card': Color(0xFF161630),
      'surface': Color(0xFF1F1F45),
      'deep': Color(0xFF0A0A14),
      'accent': Color(0xFFE040FB),
      'accentLight': Color(0xFFEA80FC),
      'secondary': Color(0xFF00E5FF),
      'textPrimary': Color(0xFFF3E8FF),
      'textSecondary': Color(0xFF9080B0),
      'border': Color(0xFF2A2050),
    },
    'light': {
      'name': 'Clean White',
      'emoji': '☀️',
      'bg': Color(0xFFF8F9FC),
      'card': Color(0xFFFFFFFF),
      'surface': Color(0xFFF1F3F8),
      'deep': Color(0xFFEBEDF2),
      'accent': Color(0xFF6366F1),
      'accentLight': Color(0xFF818CF8),
      'secondary': Color(0xFF14B8A6),
      'textPrimary': Color(0xFF1E293B),
      'textSecondary': Color(0xFF64748B),
      'border': Color(0xFFE2E8F0),
    },
  };

  // ═══════════ GETTERS ═══════════
  Color get bg => (themes[_currentTheme]!['bg'] as Color?) ?? const Color(0xFF0A0E17);
  Color get card => (themes[_currentTheme]!['card'] as Color?) ?? const Color(0xFF141B2D);
  Color get surface => (themes[_currentTheme]!['surface'] as Color?) ?? const Color(0xFF1C2438);
  Color get deep => (themes[_currentTheme]!['deep'] as Color?) ?? const Color(0xFF0D1220);
  Color get accent => (themes[_currentTheme]!['accent'] as Color?) ?? const Color(0xFF7C3AED);
  Color get accentLt => (themes[_currentTheme]!['accentLight'] as Color?) ?? const Color(0xFFA78BFA);
  Color get secondary => (themes[_currentTheme]!['secondary'] as Color?) ?? const Color(0xFF2DD4BF);
  Color get textPri => (themes[_currentTheme]!['textPrimary'] as Color?) ?? const Color(0xFFF1F5F9);
  Color get textSec => (themes[_currentTheme]!['textSecondary'] as Color?) ?? const Color(0xFF8899A6);
  Color get border => (themes[_currentTheme]!['border'] as Color?) ?? const Color(0xFF1E2A3A);
  String get themeName => (themes[_currentTheme]!['name'] as String?) ?? 'Midnight';
  String get themeEmoji => (themes[_currentTheme]!['emoji'] as String?) ?? '🌌';
}
