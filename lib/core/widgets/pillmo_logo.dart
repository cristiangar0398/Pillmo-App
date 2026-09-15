import 'package:flutter/material.dart';

class PillmoLogo extends StatelessWidget {
  const PillmoLogo({this.size = 72, this.showName = true, super.key});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE9FFF5), Color(0xFFF8F3FF)],
          ),
          borderRadius: BorderRadius.circular(size * .28),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x241F3C68), blurRadius: 18, offset: Offset(0, 8)),
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
                    colors: [Color(0xFF8DECC0), Color(0xFF35CDB7)],
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
                      colors: [Color(0xFFFFB29D), Color(0xFFFF807B)],
                    ),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              ),
            ),
            Icon(Icons.check_rounded,
                size: size * .47, color: const Color(0xFF36CBBF)),
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
            color: const Color(0xFF18304D),
            fontSize: size * .38,
            fontWeight: FontWeight.w800,
            letterSpacing: -.3,
          ),
        ),
      ],
    );
  }
}
