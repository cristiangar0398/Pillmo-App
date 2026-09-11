import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      );
}
