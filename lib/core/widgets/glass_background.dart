import 'package:flutter/material.dart';

import '../../app/config/app_theme.dart';

/// Decorative canvas painted behind every screen: a soft directional
/// gradient plus two large, low-opacity color blooms. Glass surfaces
/// placed above this (app bars, nav bars, cards) have something with
/// texture and color to blur, which is what makes Liquid Glass read as
/// glass instead of plain translucency.
///
/// Pair with `Scaffold(backgroundColor: Colors.transparent, extendBody:
/// true, extendBodyBehindAppBar: true)` and place as the first child of a
/// [Stack] behind the page content.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [glass.canvasTop, glass.canvasMid, glass.canvasBottom],
            stops: const [0, .55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _bloom(320, AppTheme.mint.withOpacity(.22)),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: _bloom(360, AppTheme.coral.withOpacity(.16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloom(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}
