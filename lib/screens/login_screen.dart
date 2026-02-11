import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../widgets/clay_widgets.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  bool _isRegister = false;
  bool _obscure = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); _nameCtrl.dispose(); _fullNameCtrl.dispose(); _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    bool success;
    if (_isRegister) {
      success = await auth.register(_nameCtrl.text.trim(), _fullNameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    } else {
      success = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    }
    if (success && mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppTheme.glowShadow(AppTheme.accent, intensity: 0.4),
                ),
                child: const Center(child: Text('₹', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white))),
              ),
              const SizedBox(height: 24),
              const Text('Pugazh Stocks', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(_isRegister ? 'Create your trading account' : 'Welcome back, trader!', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 40),

              // Form card
              ClayCard(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  // Toggle
                  Row(children: [
                    Expanded(child: ClayChip(label: 'Login', isActive: !_isRegister, onTap: () => setState(() => _isRegister = false))),
                    const SizedBox(width: 8),
                    Expanded(child: ClayChip(label: 'Register', isActive: _isRegister, onTap: () => setState(() => _isRegister = true))),
                  ]),
                  const SizedBox(height: 24),

                  if (_isRegister) ...[
                    ClayInput(controller: _nameCtrl, labelText: 'USERNAME', hintText: 'pugazh_trader', prefixIcon: Icons.person_outline),
                    const SizedBox(height: 16),
                    ClayInput(controller: _fullNameCtrl, labelText: 'FULL NAME', hintText: 'Pugazh Kumar', prefixIcon: Icons.badge_outlined),
                    const SizedBox(height: 16),
                  ],
                  ClayInput(controller: _emailCtrl, labelText: 'EMAIL', hintText: 'you@example.com', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  ClayInput(
                    controller: _passCtrl, labelText: 'PASSWORD', hintText: '••••••••', prefixIcon: Icons.lock_outline, obscureText: _obscure,
                    suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: AppTheme.textLight)),
                  ),
                  const SizedBox(height: 28),

                  if (auth.error != null) Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(auth.error!, style: const TextStyle(color: AppTheme.red, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  ),

                  ClayButton(
                    gradient: AppTheme.accentGradient,
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                    child: Text(_isRegister ? 'Create Account' : 'Sign In', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Demo hint
              ClayCard(
                depth: 0.6,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: AppTheme.accent, size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text('Paper trading with ₹10,00,000 virtual money. No real money involved.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
                ]),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }
}
