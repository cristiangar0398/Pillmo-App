import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({this.controller, this.label, super.key});
  final TextEditingController? controller;
  final String? label;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      );
}
