import 'package:flutter/material.dart';

import '../../app/config/app_theme.dart';
import 'glass_container.dart';

/// The PATIENT/CAREGIVER toggle shown during first-time registration — the
/// backend requires one of these two values to create a new user profile.
class RoleSelector extends StatelessWidget {
  const RoleSelector({required this.role, required this.onChanged, super.key});

  /// 'PATIENT' or 'CAREGIVER'.
  final String role;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleOption(
            label: 'Paciente',
            selected: role == 'PATIENT',
            onTap: () => onChanged('PATIENT'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoleOption(
            label: 'Cuidador',
            selected: role == 'CAREGIVER',
            onTap: () => onChanged('CAREGIVER'),
          ),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    return SizedBox(
      height: 48,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        tint: selected ? AppTheme.mintDeep : glass.muted,
        tintOpacity: selected ? .85 : .15,
        interactive: true,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : glass.ink,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
