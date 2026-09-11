import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/dose_entity.dart';

import '../../../../app/config/app_theme.dart';

class DoseCard extends StatelessWidget {
  const DoseCard({
    required this.dose,
    required this.onConfirm,
    super.key,
  });

  final DoseEntity dose;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final status = dose.status.toUpperCase();
    final isTaken = status == 'TAKEN';
    final canConfirm = status == 'PENDING' || status == 'DELAYED';

    final Color statusColor;
    switch (status) {
      case 'TAKEN':
        statusColor = AppTheme.success;
        break;
      case 'SKIPPED':
        statusColor = AppTheme.danger;
        break;
      case 'DELAYED':
        statusColor = AppTheme.warning;
        break;
      case 'PENDING':
      default:
        statusColor = AppTheme.warning;
        break;
    }

    final IconData icon;
    switch (status) {
      case 'TAKEN':
        icon = Icons.check_circle;
        break;
      case 'SKIPPED':
        icon = Icons.cancel;
        break;
      case 'DELAYED':
        icon = Icons.pending_actions;
        break;
      case 'PENDING':
      default:
        icon = Icons.schedule;
        break;
    }

    final doseColor = _colorForDose(dose.colorHex, statusColor);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_timeLabel(dose.scheduledTime),
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: glass.ink)),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: doseColor.withOpacity(.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        _iconForDose(dose.iconName, icon),
                        key: ValueKey('$status-${dose.iconName}'),
                        color: doseColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dose.medicationName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Dosis: ${dose.dosage}'),
                    const SizedBox(height: 7),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12),
                      child: Text(status),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: canConfirm
                    ? IconButton.filled(
                        key: const ValueKey('confirm'),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          onConfirm();
                        },
                        tooltip: 'Marcar como tomada',
                        icon: const Icon(Icons.check_rounded),
                      )
                    : Icon(
                        isTaken
                            ? Icons.check_circle_rounded
                            : Icons.remove_circle_outline,
                        key: ValueKey('status-$status'),
                        color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(DateTime time) {
    final local = time.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  IconData _iconForDose(String? iconName, IconData fallback) {
    switch (iconName) {
      case 'pill':
        return Icons.medication_rounded;
      case 'capsule':
        return Icons.medication_liquid;
      case 'drop':
        return Icons.water_drop_outlined;
      default:
        return fallback;
    }
  }

  Color _colorForDose(String? colorHex, Color fallback) {
    if (colorHex == null) return fallback;
    final value = colorHex.replaceFirst('#', '');
    final normalized = value.length == 6 ? 'FF$value' : value;
    final color = int.tryParse(normalized, radix: 16);
    return color == null ? fallback : Color(color);
  }
}
