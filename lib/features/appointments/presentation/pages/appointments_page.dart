import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/responsive_center.dart';

class FamilyPatientItem {
  const FamilyPatientItem({
    required this.name,
    required this.compliance,
    required this.pendingDoses,
  });

  final String name;
  final double compliance;
  final int pendingDoses;
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key, required this.userId});

  final String userId;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  bool _loading = true;
  String? _error;
  List<FamilyPatientItem> _patients = const [];

  @override
  void initState() {
    super.initState();
    _loadFamilyStatus();
  }

  Future<void> _loadFamilyStatus() async {
    final apiClient = getIt<ApiClient>();

    try {
      final response = await apiClient.get<List<dynamic>>(
        '/family/status',
        queryParameters: {'user_id': widget.userId},
      );

      final patients = (response.data ?? const <dynamic>[]).map((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item as Map)
            : <String, dynamic>{};
        final rawPercent = map['adherence_percentage'] ??
            map['daily_compliance'] ??
            map['compliance'] ??
            map['percentage'] ??
            0;
        return FamilyPatientItem(
          name: map['patient_name']?.toString() ??
              map['name']?.toString() ??
              'Paciente',
          compliance: _toPercent(rawPercent),
          pendingDoses: (map['pending_doses'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _patients = patients;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar la red de apoyo.';
      });
    }
  }

  double _toPercent(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final normalized = value.replaceAll('%', '').trim();
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Familia y cuidadores',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
                'Supervisa la adherencia diaria de tus pacientes vinculados.'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    _StatusMessage(message: _error!, onRetry: _loadFamilyStatus)
                  else if (_patients.isEmpty)
                    const _StatusMessage(
                        message: 'No hay pacientes vinculados a este cuidador.')
                  else
                    ..._patients.map((patient) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.group),
                          ),
                          title: Text(patient.name),
                          subtitle: LinearProgressIndicator(
                            value: (patient.compliance / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          trailing: Text(
                            '${patient.compliance.toStringAsFixed(0)}%\n${patient.pendingDoses} pendientes',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.group_outlined, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
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
