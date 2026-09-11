import 'package:flutter_test/flutter_test.dart';
import 'package:pillmo_app/features/medications/data/models/prescription_scan_model.dart';

void main() {
  test('parses the backend OCR response', () {
    final model = PrescriptionScanModel.fromJson({
      'medications': [
        {
          'name': 'Amoxicilina',
          'dosage': '500 mg',
          'frequency_hours': 8,
          'duration_days': 7,
          'instructions': 'Tomar después de comer',
        },
      ],
    });

    expect(model.medications, hasLength(1));
    expect(model.medications.single.name, 'Amoxicilina');
    // POST /medications requires "cada|every <N> horas|hours" (see
    // medication_service.go), so the raw frequency_hours count from the scan
    // must be formatted into that phrase, not left as a bare number.
    expect(model.medications.single.frequency, 'Cada 8 horas');
    expect(model.medications.single.durationDays, 7);
    expect(model.medications.single.instructions, 'Tomar después de comer');
  });

  test('derives a summary when the backend does not send one', () {
    final model = PrescriptionScanModel.fromJson({
      'medications': [
        {'name': 'Amoxicilina', 'dosage': '500 mg', 'frequency_hours': 8},
      ],
    });

    expect(model.summary, contains('Amoxicilina'));
  });
}
