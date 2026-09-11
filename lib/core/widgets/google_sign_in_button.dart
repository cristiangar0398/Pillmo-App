import 'package:flutter/material.dart';

import '../../app/config/app_theme.dart';
import 'glass_container.dart';

/// The "Continuar con Google" action — an outlined glass capsule (secondary
/// to [AppButton]'s tinted primary action) so it reads as an alternative
/// sign-in path rather than competing with the main button.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GlassContainer.capsule(
        tintOpacity: disabled ? .15 : .35,
        interactive: !disabled,
        onTap: onPressed,
        semanticLabel: 'Continuar con Google',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleGlyph(),
            const SizedBox(width: 12),
            Text(
              'Continuar con Google',
              style: TextStyle(
                color: context.glass.ink,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontWeight: FontWeight.w900,
          fontSize: 14,
          height: 1,
        ),
      ),
    );
  }
}
