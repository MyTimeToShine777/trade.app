import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppTheme {
  // ═══════════════════ DYNAMIC THEME ACCESS ═══════════════════
  /// Call `AppTheme.of(context)` to get theme-aware colors.
  /// Falls back to static defaults when no provider is available.
  static _DynTheme of(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return _DynTheme(tp);
  }

  static _DynTheme read(BuildContext context) {
    final tp = context.read<ThemeProvider>();
    return _DynTheme(tp);
  }

  // ═══════════════════════ DEFAULT PALETTE (Midnight Purple) ═══════════════════════
  static const Color bgColor = Color(0xFF0A0E17);
  static const Color cardColor = Color(0xFF141B2D);
  static const Color surfaceColor = Color(0xFF1C2438);
  static const Color deepSurface = Color(0xFF0D1220);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF8899A6);
  static const Color textLight = Color(0xFF4A5568);

  // Accents — vibrant electric  
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color accentDark = Color(0xFF5B21B6);
  static const Color secondary = Color(0xFF2DD4BF);

  // Semantic
  static const Color green = Color(0xFF00E676);
  static const Color greenDark = Color(0xFF00C853);
  static const Color red = Color(0xFFFF5252);
  static const Color redDark = Color(0xFFFF1744);
  static const Color orange = Color(0xFFFFAB40);
  static const Color gold = Color(0xFFFFD740);
  static const Color blue = Color(0xFF448AFF);
  static const Color cyan = Color(0xFF18FFFF);
  static const Color pink = Color(0xFFFF4081);

  // Borders & Glass
  static const Color border = Color(0xFF1E2A3A);
  static const Color glass = Color(0x1AFFFFFF);

  // ═══════════════════ SHADOWS ═══════════════════
  static List<BoxShadow> clayShadow({double depth = 1.0}) {
    return [
      BoxShadow(color: Colors.black.withValues(alpha: 0.3 * depth), offset: Offset(0, 2 * depth), blurRadius: 8 * depth),
      BoxShadow(color: accent.withValues(alpha: 0.05 * depth), offset: Offset(0, 0), blurRadius: 20 * depth),
    ];
  }

  static List<BoxShadow> clayInset({double depth = 1.0}) {
    return [
      BoxShadow(color: Colors.black.withValues(alpha: 0.4 * depth), offset: Offset(0, 2 * depth), blurRadius: 4 * depth),
    ];
  }

  static List<BoxShadow> clayFloat({double depth = 1.5}) => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.4), offset: Offset(0, 4 * depth), blurRadius: 16 * depth),
        BoxShadow(color: accent.withValues(alpha: 0.08), offset: const Offset(0, 0), blurRadius: 30),
      ];

  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.3}) => [
        BoxShadow(color: color.withValues(alpha: intensity), blurRadius: 16, offset: const Offset(0, 4)),
        BoxShadow(color: color.withValues(alpha: intensity * 0.5), blurRadius: 40, offset: const Offset(0, 8)),
      ];

  // ═══════════════════ GRADIENTS ═══════════════════
  static const accentGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]);
  static const greenGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF00E676), Color(0xFF00BFA5)]);
  static const redGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF5252), Color(0xFFFF1744)]);
  static const goldGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFAB40), Color(0xFFFF6D00)]);
  static const blueGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF448AFF), Color(0xFF2979FF)]);
  static const cyanGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF18FFFF), Color(0xFF00E5FF)]);
  static const pinkGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF4081), Color(0xFFF50057)]);
  static const darkGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1C2438), Color(0xFF0A0E17)]);
  static const premiumGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)]);
  static LinearGradient get clayGradient => const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1C2438), Color(0xFF141B2D)]);
  static const shimmerGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1C2438), Color(0xFF243044), Color(0xFF1C2438)]);

  // ═══════════════════ RADII ═══════════════════
  static const double radiusS = 12;
  static const double radiusM = 18;
  static const double radiusL = 24;
  static const double radiusXL = 32;

  static const colorScheme = ColorScheme.dark(primary: accent, secondary: secondary, surface: cardColor, error: red);
}

/// Dynamic theme wrapper — reads colors from ThemeProvider
class _DynTheme {
  final ThemeProvider tp;
  const _DynTheme(this.tp);

  Color get bg => tp.bg;
  Color get card => tp.card;
  Color get surface => tp.surface;
  Color get deep => tp.deep;
  Color get accent => tp.accent;
  Color get accentLt => tp.accentLt;
  Color get secondary => tp.secondary;
  Color get textPrimary => tp.textPri;
  Color get textSecondary => tp.textSec;
  Color get border => tp.border;

  LinearGradient get accentGradient => LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [tp.accent, tp.accentLt],
  );

  List<BoxShadow> glowShadow(Color color, {double intensity = 0.3}) => [
    BoxShadow(color: color.withValues(alpha: intensity), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: color.withValues(alpha: intensity * 0.5), blurRadius: 40, offset: const Offset(0, 8)),
  ];

  List<BoxShadow> clayShadow({double depth = 1.0}) => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.3 * depth), offset: Offset(0, 2 * depth), blurRadius: 8 * depth),
    BoxShadow(color: tp.accent.withValues(alpha: 0.05 * depth), offset: const Offset(0, 0), blurRadius: 20 * depth),
  ];
}
