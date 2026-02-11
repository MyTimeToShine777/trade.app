import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

// ══════════════════════════════════════════════════════════════════
//  GLASS CARD — modern glassmorphism container
// ══════════════════════════════════════════════════════════════════
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double depth;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool inset;

  const ClayCard({
    super.key, required this.child, this.padding, this.margin,
    this.borderRadius = 20, this.depth = 1.0, this.color,
    this.gradient, this.onTap, this.inset = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppTheme.cardColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: gradient == null ? Border.all(color: AppTheme.border, width: 1) : null,
        boxShadow: inset ? [] : AppTheme.clayShadow(depth: depth),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY BUTTON — tactile press with spring animation
// ══════════════════════════════════════════════════════════════════
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsets? padding;
  final bool isLoading;
  final bool isSmall;
  final double width;

  const ClayButton({
    super.key, required this.child, this.onPressed, this.color,
    this.gradient, this.borderRadius = 18, this.padding,
    this.isLoading = false, this.isSmall = false, this.width = double.infinity,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) { setState(() => _pressed = true); _ctrl.forward(); HapticFeedback.lightImpact(); } : null,
      onTapUp: widget.onPressed != null ? (_) { setState(() => _pressed = false); _ctrl.reverse(); widget.onPressed!(); } : null,
      onTapCancel: () { setState(() => _pressed = false); _ctrl.reverse(); },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.width,
          padding: widget.padding ?? (widget.isSmall
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          decoration: BoxDecoration(
            color: widget.gradient == null ? (widget.color ?? AppTheme.accent) : null,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _pressed ? [] : AppTheme.glowShadow(widget.color ?? AppTheme.accent, intensity: 0.2),
          ),
          child: widget.isLoading
              ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
              : Center(child: widget.child),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY ICON BUTTON — circular icon with clay effect
// ══════════════════════════════════════════════════════════════════
class ClayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Gradient? gradient;

  const ClayIconButton({super.key, required this.icon, this.onTap, this.size = 44, this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? AppTheme.surfaceColor) : null,
          gradient: gradient,
          shape: BoxShape.circle,
          border: gradient == null ? Border.all(color: AppTheme.border, width: 1) : null,
        ),
        child: Icon(icon, color: gradient != null ? Colors.white : AppTheme.textSecondary, size: size * 0.45),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY INPUT — inset text field
// ══════════════════════════════════════════════════════════════════
class ClayInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  const ClayInput({
    super.key, this.controller, this.hintText, this.labelText,
    this.prefixIcon, this.suffixIcon, this.obscureText = false,
    this.keyboardType, this.onChanged, this.onSubmitted, this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(labelText!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: TextFormField(
            controller: controller, obscureText: obscureText, keyboardType: keyboardType,
            onChanged: onChanged, onFieldSubmitted: onSubmitted, maxLines: maxLines,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5), fontWeight: FontWeight.w400),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.accent, size: 20) : null,
              suffixIcon: suffixIcon, border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY CHIP — filter/tag
// ══════════════════════════════════════════════════════════════════
class ClayChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final IconData? icon;

  const ClayChip({super.key, required this.label, this.isActive = false, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppTheme.border, width: 1),
          boxShadow: isActive ? AppTheme.glowShadow(AppTheme.accent, intensity: 0.2) : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: isActive ? Colors.white : AppTheme.textSecondary), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY STAT CARD — metric display
// ══════════════════════════════════════════════════════════════════
class ClayStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient? iconGradient;
  final String? subtitle;
  final Color? valueColor;

  const ClayStatCard({super.key, required this.label, required this.value, required this.icon, this.iconGradient, this.subtitle, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(gradient: iconGradient ?? AppTheme.accentGradient, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 14),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: valueColor ?? AppTheme.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: subtitle!.contains('-') ? AppTheme.red : AppTheme.green))],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY BOTTOM NAV — skeuomorphic tab bar
// ══════════════════════════════════════════════════════════════════
class ClayBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ClayNavItem> items;

  const ClayBottomNav({super.key, required this.currentIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(items.length, (i) {
        final active = i == currentIndex;
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onTap(i); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: active ? 20 : 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: active ? AppTheme.accentGradient : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: active ? [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(items[i].emoji, style: TextStyle(fontSize: active ? 22 : 20)),
              if (active) ...[const SizedBox(width: 8), Text(items[i].label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))],
            ]),
          ),
        );
      })),
    );
  }
}

class ClayNavItem {
  final String emoji;
  final String label;
  const ClayNavItem({required this.emoji, required this.label});
}

// ══════════════════════════════════════════════════════════════════
//  CLAY DRAWER ITEM — sidebar navigation entry
// ══════════════════════════════════════════════════════════════════
class ClayDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Gradient? gradient;

  const ClayDrawerItem({super.key, required this.icon, required this.label, this.isActive = false, required this.onTap, this.gradient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: isActive ? (gradient ?? AppTheme.accentGradient) : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? AppTheme.glowShadow(AppTheme.accent, intensity: 0.15) : [],
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: isActive ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? Colors.white : AppTheme.textPrimary)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY SHIMMER — loading placeholder
// ══════════════════════════════════════════════════════════════════
class ClayShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ClayShimmer({super.key, this.width = double.infinity, required this.height, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(borderRadius)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAY PROGRESS BAR
// ══════════════════════════════════════════════════════════════════
class ClayProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Gradient? gradient;
  final double height;

  const ClayProgressBar({super.key, required this.value, this.gradient, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(height)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(decoration: BoxDecoration(gradient: gradient ?? AppTheme.accentGradient, borderRadius: BorderRadius.circular(height))),
      ),
    );
  }
}
