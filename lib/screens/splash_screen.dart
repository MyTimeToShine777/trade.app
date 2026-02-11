import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 600), () => _textCtrl.forward());
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.init();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, auth.isLoggedIn ? '/home' : '/login');
  }

  @override
  void dispose() { _logoCtrl.dispose(); _textCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Animated Logo
          AnimatedBuilder(animation: Listenable.merge([_logoCtrl, _pulseCtrl]), builder: (_, __) {
            return Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value * _pulse.value,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: AppTheme.glowShadow(AppTheme.accent, intensity: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.asset('assets/pugazh.png', width: 120, height: 120, fit: BoxFit.cover),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          // App name
          AnimatedBuilder(animation: _textCtrl, builder: (_, __) {
            return Opacity(
              opacity: _textOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _textSlide.value),
                child: Column(children: [
                  Text('Pugazh Stocks', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5, shadows: [Shadow(color: AppTheme.accent.withValues(alpha: 0.2), blurRadius: 20)])),
                  const SizedBox(height: 8),
                  const Text('AI-Powered Paper Trading', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary, letterSpacing: 1)),
                ]),
              ),
            );
          }),
          const SizedBox(height: 60),
          // Loading indicator
          AnimatedBuilder(animation: _textCtrl, builder: (_, __) {
            return Opacity(opacity: _textOpacity.value, child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.accent.withValues(alpha: 0.6))));
          }),
        ]),
      ),
    );
  }
}
