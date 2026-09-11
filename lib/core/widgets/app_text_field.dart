import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/config/app_theme.dart';

/// A frosted glass input field: a blurred, translucent capsule that lets
/// the canvas gradient show through instead of a flat opaque fill.
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: glass.surface.withOpacity(.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: glass.surfaceBorder.withOpacity(.8), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(color: glass.ink, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: label,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
