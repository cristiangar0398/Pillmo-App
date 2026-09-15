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
    expect(model.medications.single.frequency, '8');
    expect(model.medications.single.durationDays, 7);
    expect(model.medications.single.instructions, 'Tomar después de comer');
  });
}