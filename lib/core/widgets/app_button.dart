import 'package:flutter/material.dart';

import '../../app/config/app_theme.dart';
import 'glass_container.dart';

/// The app's primary action button — a tinted, interactive glass capsule
/// (the Liquid Glass equivalent of `.buttonStyle(.glassProminent)` with
/// `.interactive()`). Reserved for the single primary action on a screen.
class AppButton extends StatelessWidget {
  const AppButton({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GlassContainer.capsule(
        tint: disabled ? context.glass.muted : AppTheme.mintDeep,
        tintOpacity: disabled ? .25 : .85,
        interactive: !disabled,
        onTap: onPressed,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: .1,
            ),
          ),
        ),
      ),
    );
  }
}
