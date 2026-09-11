import 'package:flutter/material.dart';

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    required this.child,
    this.maxWidth = 500,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, maxWidth)
            : maxWidth;

        return Center(
          child: SizedBox(
            width: width,
            height:
                constraints.maxHeight.isFinite ? constraints.maxHeight : null,
            child: Padding(padding: padding, child: child),
          ),
        );
      },
    );
  }
}
