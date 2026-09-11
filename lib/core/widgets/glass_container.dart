import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/config/app_theme.dart';

/// A frosted, translucent surface that mimics Apple's Liquid Glass material:
/// a blurred backdrop, a soft tint, and a bright top-left highlight border
/// that reads as light bending across the surface ("lensing").
///
/// Reserve this for the navigation layer — bars, toolbars, floating
/// controls — never for content-layer rows in a scrolling list.
class GlassContainer extends StatefulWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.blurSigma = 20,
    this.tint,
    this.tintOpacity = .45,
    this.interactive = false,
    this.onTap,
    this.semanticLabel,
  });

  /// Capsule-shaped glass, sized to the child's height (phone-scale controls).
  const GlassContainer.capsule({
    required this.child,
    super.key,
    this.padding,
    this.blurSigma = 20,
    this.tint,
    this.tintOpacity = .45,
    this.interactive = false,
    this.onTap,
    this.semanticLabel,
  }) : borderRadius = const BorderRadius.all(Radius.circular(999));

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final Color? tint;
  final double tintOpacity;
  final bool interactive;
  final VoidCallback? onTap;

  /// Announced by screen readers when this is tappable. Required for
  /// icon-only content (e.g. a FAB) — a raw GestureDetector doesn't expose a
  /// "button" role or label on its own, so without this a screen reader user
  /// gets no meaningful announcement at all. Not needed when [child] already
  /// contains visible text that speaks for itself.
  final String? semanticLabel;

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.interactive) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final tint = widget.tint ?? glass.surface;

    final surface = ClipRRect(
      borderRadius: widget.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withOpacity(widget.tintOpacity + .15),
                tint.withOpacity(widget.tintOpacity),
              ],
            ),
            border: Border.all(
                color: glass.surfaceBorder.withOpacity(.75), width: 1.2),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1A16233D),
                  blurRadius: 24,
                  offset: Offset(0, 10)),
            ],
          ),
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.child,
          ),
        ),
      ),
    );

    final scaled = AnimatedScale(
      scale: _pressed ? .96 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: surface,
    );

    if (widget.onTap == null) return scaled;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        child: scaled,
      ),
    );
  }
}
