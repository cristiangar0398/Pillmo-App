import 'package:flutter/material.dart';

import '../../app/config/app_theme.dart';

class PillmoLogo extends StatelessWidget {
  const PillmoLogo({this.size = 72, this.showName = true, super.key});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    // The mark itself is a fixed brand asset — its light chip and colored
    // bars stay the same in light and dark mode, like an app icon would.
    final mintPale = context.glass.mintPale;
    final mark = SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withOpacity(.85), mintPale],
          ),
          borderRadius: BorderRadius.circular(size * .28),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x2016233D),
                blurRadius: 20,
                offset: Offset(0, 10)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -.78,
              child: Container(
                width: size * .28,
                height: size * .66,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8DECC0), AppTheme.mintDeep],
                  ),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(size * .13, size * .16),
              child: Transform.rotate(
                angle: -.78,
                child: Container(
                  width: size * .27,
                  height: size * .46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB29D), AppTheme.coral],
                    ),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              ),
            ),
            Icon(Icons.check_rounded,
                size: size * .47, color: AppTheme.mintDeep),
          ],
        ),
      ),
    );

    if (!showName) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        Text(
          'Pillmo',
          style: TextStyle(
            color: context.glass.ink,
            fontSize: size * .38,
            fontWeight: FontWeight.w800,
            letterSpacing: -.3,
          ),
        ),
      ],
    );
  }
}
