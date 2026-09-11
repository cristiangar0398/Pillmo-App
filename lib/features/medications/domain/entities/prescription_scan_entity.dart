class PrescriptionScanEntity {
  const PrescriptionScanEntity({
    required this.id,
    required this.medications,
    required this.summary,
  });

  final String id;
  final List<DetectedMedication> medications;
  final String summary;
}

class DetectedMedication {
  const DetectedMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.durationDays,
    this.instructions,
  });

  final String name;
  final String dosage;
  final String frequency;
  final int? durationDays;
  final String? instructions;
}
