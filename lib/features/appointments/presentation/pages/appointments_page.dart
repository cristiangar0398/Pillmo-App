import 'package:flutter/material.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/status_message_card.dart';

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
            ? Map<String, dynamic>.from(item)
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
            Text('Familia y cuidadores',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Supervisa la adherencia diaria de tus pacientes vinculados.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadFamilyStatus,
                child: ListView(
                  children: [
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      StatusMessageCard(
                        message: _error!,
                        icon: Icons.group_outlined,
                        onRetry: _loadFamilyStatus,
                      )
                    else if (_patients.isEmpty)
                      const StatusMessageCard(
                        message: 'No hay pacientes vinculados a este cuidador.',
                        icon: Icons.group_outlined,
                      )
                    else
                      ..._patients.map((patient) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: context.glass.mintPale,
                              foregroundColor: AppTheme.mintDeep,
                              child: const Icon(Icons.group),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
