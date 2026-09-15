import 'package:flutter/material.dart';

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
    final status = dose.status.toUpperCase();
    final isTaken = status == 'TAKEN';
    final canConfirm = status == 'PENDING' || status == 'DELAYED';

    final Color statusColor;
    switch (status) {
      case 'TAKEN':
        statusColor = const Color(0xFF00856A);
        break;
      case 'SKIPPED':
        statusColor = const Color(0xFFB00020);
        break;
      case 'DELAYED':
        statusColor = const Color(0xFFE08A00);
        break;
      case 'PENDING':
      default:
        statusColor = const Color(0xFFE08A00);
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: _colorForDose(dose.colorHex, statusColor),
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_timeLabel(dose.scheduledTime),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink)),
                  const SizedBox(height: 4),
                  Icon(_iconForDose(dose.iconName, icon),
                      color: _colorForDose(dose.colorHex, statusColor),
                      size: 24),
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
                    Text(status,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: canConfirm
                  ? IconButton.filled(
                      onPressed: onConfirm,
                      tooltip: 'Marcar como tomada',
                      icon: const Icon(Icons.check_rounded),
                    )
                  : Icon(
                      isTaken
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_outline,
                      color: statusColor),
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
