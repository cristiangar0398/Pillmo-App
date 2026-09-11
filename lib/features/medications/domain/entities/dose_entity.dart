class DoseEntity {
  const DoseEntity({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    required this.status,
    this.colorHex,
    this.iconName,
  });

  final String id;
  final String medicationName;
  final String dosage;
  final DateTime scheduledTime;
  final String status;
  final String? colorHex;
  final String? iconName;
}
