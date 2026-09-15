import '../../domain/entities/prescription_scan_entity.dart';

class PrescriptionScanModel extends PrescriptionScanEntity {
  const PrescriptionScanModel({
    required super.id,
    required super.medications,
    required super.summary,
  });

  factory PrescriptionScanModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['medications'] as List<dynamic>? ?? const <dynamic>[];

    return PrescriptionScanModel(
      id: json['id']?.toString() ?? '',
      medications: rawItems
          .map(
            (item) => DetectedMedication(
              name: (item as Map)['name']?.toString() ?? '',
              dosage: (item)['dosage']?.toString() ?? '',
              frequency: (item)['frequency_hours']?.toString() ?? '',
              durationDays: (item)['duration_days'] as int?,
              instructions: (item)['instructions']?.toString(),
            ),
          )
          .toList(),
      summary: json['summary']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medications': medications
            .map((med) => {
                  'name': med.name,
                  'dosage': med.dosage,
                  'frequency_hours': int.tryParse(med.frequency),
                  'duration_days': med.durationDays,
                  'instructions': med.instructions,
                })
            .toList(),
        'summary': summary,
      };
}
