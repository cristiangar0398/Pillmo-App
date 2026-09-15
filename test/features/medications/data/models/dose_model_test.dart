import 'package:flutter_test/flutter_test.dart';
import 'package:pillmo_app/features/medications/data/models/dose_model.dart';

void main() {
  group('DoseModel', () {
    test('should parse backend timeline json', () {
      final json = {
        'dose_log_id': 'dose-1',
        'name': 'Amoxicilina',
        'dosage': '500mg',
        'scheduled_at': '2026-09-11T08:00:00Z',
        'color_hex': '#4F46E5',
        'icon_name': 'pill',
        'status': 'PENDING',
      };

      final model = DoseModel.fromJson(json);

      expect(model.id, 'dose-1');
      expect(model.medicationName, 'Amoxicilina');
      expect(model.dosage, '500mg');
      expect(model.status, 'PENDING');
      expect(model.colorHex, '#4F46E5');
      expect(model.iconName, 'pill');
      expect(model.scheduledTime, isA<DateTime>());
    });
  });
}
