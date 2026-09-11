// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pillmo_app/app/app.dart';
import 'package:pillmo_app/core/di/injection.dart';
import 'package:pillmo_app/features/medications/domain/entities/dose_entity.dart';
import 'package:pillmo_app/features/medications/presentation/pages/medications_page.dart';
import 'package:pillmo_app/features/medications/presentation/widgets/medication_tile.dart';

void main() {
  testWidgets('Pillmo muestra el formulario de inicio',
      (WidgetTester tester) async {
    await configureDependencies();
    await tester.pumpWidget(const PillmoApp());
    await tester.pumpAndSettle();

    expect(find.text('Tu día, más ligero'), findsOneWidget);
    expect(find.text('Ingresar a Pillmo'), findsOneWidget);
  });

  testWidgets('EmptyTimelineView muestra mensaje y botón para escanear receta',
      (tester) async {
    var scanned = false;

    await tester.pumpWidget(
      MaterialApp(
        home: EmptyTimelineView(
          onScanPressed: () => scanned = true,
          onManualPressed: () {},
        ),
      ),
    );

    expect(find.text('Tu agenda está despejada'), findsOneWidget);
    expect(find.text('Escanear con IA'), findsOneWidget);

    await tester.tap(find.text('Escanear con IA'));
    await tester.pump();

    expect(scanned, isTrue);
  });

  testWidgets('DoseCard muestra el estado y confirma dosis', (tester) async {
    var confirmed = false;
    final dose = DoseEntity(
      id: 'dose-1',
      medicationName: 'Ibuprofeno',
      dosage: '200 mg',
      scheduledTime: DateTime(2026, 9, 14, 8, 30),
      status: 'PENDING',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DoseCard(
          dose: dose,
          onConfirm: () => confirmed = true,
        ),
      ),
    );

    expect(find.text('PENDING'), findsOneWidget);
    expect(find.byTooltip('Marcar como tomada'), findsOneWidget);

    await tester.tap(find.byTooltip('Marcar como tomada'));
    await tester.pump();

    expect(confirmed, isTrue);
  });
}
