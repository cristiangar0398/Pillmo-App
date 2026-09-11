import 'package:flutter/material.dart';

/// A single consistent look for a screen's error or empty state: an icon, a
/// message, and an optional retry action. Used across Timeline, Agenda,
/// Calendar, Familia and Métricas de salud so failures read the same way
/// everywhere instead of each screen inventing its own layout.
class StatusMessageCard extends StatelessWidget {
  const StatusMessageCard({
    super.key,
    required this.message,
    this.icon = Icons.cloud_off_outlined,
    this.onRetry,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
