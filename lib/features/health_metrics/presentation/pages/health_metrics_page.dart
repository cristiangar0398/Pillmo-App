import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/responsive_center.dart';

class DoseHistoryItem {
  const DoseHistoryItem({
    required this.medicationName,
    required this.status,
    required this.time,
    required this.dosage,
  });

  final String medicationName;
  final String status;
  final String time;
  final String dosage;
}

class HealthMetricsPage extends StatefulWidget {
  const HealthMetricsPage({super.key, required this.userId});

  final String userId;

  @override
  State<HealthMetricsPage> createState() => _HealthMetricsPageState();
}

class _HealthMetricsPageState extends State<HealthMetricsPage> {
  bool _loading = true;
  String? _error;
  double _adherence = 0;
  List<DoseHistoryItem> _history = const [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final apiClient = getIt<ApiClient>();
    final startDate = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .split('T')
        .first;
    final endDate = DateTime.now().toIso8601String().split('T').first;

    try {
      final adherenceResponse = await apiClient.get<Map<String, dynamic>>(
        '/analytics/adherence',
        queryParameters: {'user_id': widget.userId},
      );

      final historyResponse = await apiClient.get<List<dynamic>>(
        '/history',
        queryParameters: {
          'user_id': widget.userId,
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      final data = adherenceResponse.data ?? const <String, dynamic>{};
      final rawAdherence = data['adherence_percentage'] ??
          data['adherence'] ??
          data['percentage'] ??
          0;
      final adherence = _toPercent(rawAdherence);

      final history = (historyResponse.data ?? const <dynamic>[]).map((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item as Map)
            : <String, dynamic>{};
        return DoseHistoryItem(
          medicationName: map['medication_name']?.toString() ??
              map['medicationName']?.toString() ??
              map['name']?.toString() ??
              'Medicamento',
          status: map['status']?.toString() ?? 'PENDING',
          time: map['scheduled_time']?.toString() ??
              map['date']?.toString() ??
              map['time']?.toString() ??
              'Sin fecha',
          dosage: map['dosage']?.toString() ?? map['dose']?.toString() ?? '—',
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _adherence = adherence;
        _history = history;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar la información analítica.';
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return ResponsiveCenter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas de salud',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: CircularProgressIndicator(
                        value: (_adherence / 100).clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: Colors.orange.withOpacity(0.15),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Adherencia últimos 30 días',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            '${_adherence.toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Historial de dosis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  final status = item.status.toUpperCase();
                  final color = switch (status) {
                    'TAKEN' => Colors.green,
                    'SKIPPED' => Colors.red,
                    'DELAYED' => Colors.orange,
                    _ => Colors.blueGrey,
                  };

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(Icons.medication_rounded, color: color),
                      ),
                      title: Text(item.medicationName),
                      subtitle: Text('${item.dosage} • ${item.time}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
