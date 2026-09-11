import '../../domain/entities/prescription_scan_entity.dart';

class PrescriptionScanModel extends PrescriptionScanEntity {
  const PrescriptionScanModel({
    required super.id,
    required super.medications,
    required super.summary,
  });

  factory PrescriptionScanModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['medications'] as List<dynamic>? ?? const <dynamic>[];

    final medications = rawItems
        .map(
          (item) => DetectedMedication(
            name: (item as Map)['name']?.toString() ?? '',
            dosage: (item)['dosage']?.toString() ?? '',
            frequency: _formatFrequencyHours((item)['frequency_hours']),
            durationDays: (item)['duration_days'] as int?,
            instructions: (item)['instructions']?.toString(),
          ),
        )
        .toList();

    return PrescriptionScanModel(
      id: json['id']?.toString() ?? '',
      medications: medications,
      summary: json['summary']?.toString() ?? _buildSummary(medications),
    );
  }

  // POST /medications requires frequency text matching "cada|every <N> horas|hours",
  // but the scan endpoint only returns a raw hour count, so it's formatted here to
  // match what the backend expects when the user saves the scanned treatment as-is.
  static String _formatFrequencyHours(dynamic value) {
    final hours = value is num ? value.toInt() : int.tryParse('$value');
    if (hours == null) {
      return '';
    }
    return 'Cada $hours horas';
  }

  // The backend's PrescriptionScanResponse only returns `medications`, with
  // no summary text, so one is derived client-side for display.
  static String _buildSummary(List<DetectedMedication> medications) {
    if (medications.isEmpty) {
      return 'No se detectaron medicamentos en la receta.';
    }
    if (medications.length == 1) {
      return 'Se detectó 1 medicamento: ${medications.first.name}.';
    }
    final names = medications.map((med) => med.name).join(', ');
    return 'Se detectaron ${medications.length} medicamentos: $names.';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medications': medications
            .map((med) => {
                  'name': med.name,
                  'dosage': med.dosage,
                  'frequency_hours': int.tryParse(
                      RegExp(r'\d+').firstMatch(med.frequency)?.group(0) ?? ''),
                  'duration_days': med.durationDays,
                  'instructions': med.instructions,
                })
            .toList(),
        'summary': summary,
      };
}
