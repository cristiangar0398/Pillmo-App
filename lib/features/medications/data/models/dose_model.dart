import '../../domain/entities/dose_entity.dart';

class DoseModel extends DoseEntity {
  const DoseModel({
    required super.id,
    required super.medicationName,
    required super.dosage,
    required super.scheduledTime,
    required super.status,
    super.colorHex,
    super.iconName,
  });

  factory DoseModel.fromJson(Map<String, dynamic> json) {
    return DoseModel(
      id: json['dose_log_id']?.toString() ?? json['id']?.toString() ?? '',
      medicationName: json['name']?.toString() ?? json['medication_name']?.toString() ?? 'Desconocido',
      dosage: json['dosage']?.toString() ?? '',
      scheduledTime: DateTime.tryParse(
        json['scheduled_at']?.toString() ?? json['scheduled_time']?.toString() ?? '',
          ) ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'PENDING',
      colorHex: json['color_hex']?.toString(),
      iconName: json['icon_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medication_name': medicationName,
        'dosage': dosage,
        'scheduled_time': scheduledTime.toIso8601String(),
        'status': status,
        'color_hex': colorHex,
        'icon_name': iconName,
      };
}
