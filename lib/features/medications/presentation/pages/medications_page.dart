import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../domain/entities/prescription_scan_entity.dart';
import '../blocs/medications_cubit.dart';
import '../widgets/medication_tile.dart';

Future<void> showManualMedicationDialog(BuildContext context,
    {required String userId}) async {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  final formKey = GlobalKey<FormState>();

  final shouldSave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Crear medicamento manual'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'Nombre del medicamento'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Obligatorio'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dosageController,
                      decoration: const InputDecoration(labelText: 'Dosis'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Obligatorio'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: frequencyController,
                      decoration: const InputDecoration(
                        labelText: 'Frecuencia',
                        hintText: 'Cada 8 horas',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(child: Text('Horario')),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setState(() => selectedTime = picked);
                            }
                          },
                          child: Text(selectedTime.format(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );

  if (shouldSave != true || !context.mounted) {
    return;
  }

  await context.read<MedicationCubit>().addManualMedication(
        userId: userId,
        medicineName: nameController.text,
        dosage: dosageController.text,
        time: selectedTime,
      );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Vista actualizada temporalmente. Falta el endpoint de creación para persistirlo.')),
    );
  }
}

void showMedicationActionSheet(BuildContext context, {required String userId}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.document_scanner_outlined),
                title: const Text('Incluir receta con foto (IA)'),
                subtitle: const Text(
                    'Usa /prescriptions/scan para leer el tratamiento'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/medications/scan');
                },
              ),
              ListTile(
                leading: const Icon(Icons.medication_rounded),
                title: const Text('Crear Medicamento Manual'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  showManualMedicationDialog(context, userId: userId);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class PrescriptionScanConfirmationDialog extends StatefulWidget {
  const PrescriptionScanConfirmationDialog({
    required this.scan,
    required this.userId,
    super.key,
  });

  final PrescriptionScanEntity scan;
  final String userId;

  @override
  State<PrescriptionScanConfirmationDialog> createState() =>
      _PrescriptionScanConfirmationDialogState();
}

class _PrescriptionScanConfirmationDialogState
    extends State<PrescriptionScanConfirmationDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _frequencyController;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final firstMedication = widget.scan.medications.isNotEmpty
        ? widget.scan.medications.first
        : null;
    _nameController = TextEditingController(text: firstMedication?.name ?? '');
    _dosageController =
        TextEditingController(text: firstMedication?.dosage ?? '');
    _frequencyController =
        TextEditingController(text: firstMedication?.frequency ?? '');
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Receta extraída'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.scan.summary),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Medicamento'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(labelText: 'Frecuencia'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Horario del tratamiento')),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) {
                      setState(() => _selectedTime = picked);
                    }
                  },
                  child: Text(_selectedTime.format(context)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            final cubit = context.read<MedicationCubit>();
            await cubit.addManualMedication(
              userId: widget.userId,
              medicineName: _nameController.text,
              dosage: _dosageController.text,
              time: _selectedTime,
            );
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Tratamiento guardado y actualizado.')),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

Future<void> submitPrescriptionScan(
  BuildContext context, {
  required String userId,
  required String imagePath,
}) async {
  final extension = imagePath.split('.').last.toLowerCase();
  final isSupported = {'jpg', 'jpeg', 'png'}.contains(extension);
  if (!isSupported) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se permiten imágenes JPG o PNG.')),
      );
    }
    return;
  }

  final cubit = getIt<MedicationCubit>();
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Procesando receta...'),
          ],
        ),
      ),
    );
  }

  await cubit.scanPrescription(userId: userId, imagePath: imagePath);

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  if (!context.mounted) {
    return;
  }

  final state = cubit.state;
  if (state is MedicationError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message)),
    );
    return;
  }

  if (state is PrescriptionScanned) {
    showDialog(
      context: context,
      builder: (_) => PrescriptionScanConfirmationDialog(
        scan: state.scan,
        userId: userId,
      ),
    );
  }
}

Future<void> pickAndScanPrescription(
  BuildContext context, {
  required String userId,
}) async {
  final source = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Escanear receta'),
      content: const Text('Elige cómo quieres cargar la imagen.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ImageSource.camera),
          child: const Text('Cámara'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
          child: const Text('Galería'),
        ),
      ],
    ),
  );

  if (source == null || !context.mounted) {
    return;
  }

  final picker = ImagePicker();
  final file = await picker.pickImage(source: source, imageQuality: 85);
  if (file == null || !context.mounted) {
    return;
  }

  await submitPrescriptionScan(
    context,
    userId: userId,
    imagePath: file.path,
  );
}

class MedicationFormPage extends StatelessWidget {
  const MedicationFormPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final doseController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo medicamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del medicamento'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medicamento guardado')),
                );
                context.pop();
              },
              child: const Text('Guardar medicamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class PrescriptionScanPage extends StatelessWidget {
  const PrescriptionScanPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear receta')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escaneo OCR de receta',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('Selecciona cámara o galería para subir una imagen.'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pickAndScanPrescription(context, userId: userId),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Abrir escáner'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyTimelineView extends StatelessWidget {
  const EmptyTimelineView({
    required this.onScanPressed,
    required this.onManualPressed,
    super.key,
  });

  final VoidCallback onScanPressed;
  final VoidCallback onManualPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppTheme.mintPale,
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: const Icon(Icons.medication_rounded,
                                size: 42, color: AppTheme.mint),
                          ),
                          const SizedBox(height: 16),
                          const Text('PLAN DE HOY',
                              style: TextStyle(
                                  color: AppTheme.coral,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 8),
                          const Text(
                            'Tu agenda está despejada',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppTheme.ink,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Agrega un tratamiento para comenzar a organizar tus tomas.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: 180,
                                child: ElevatedButton.icon(
                                  onPressed: onScanPressed,
                                  icon: const Icon(
                                      Icons.document_scanner_outlined),
                                  label: const Text('Escanear con IA'),
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: FilledButton.icon(
                                  onPressed: onManualPressed,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar Manual'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicationCubit>()..loadTodayTimeline(userId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'Timeline diaria',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: BlocBuilder<MedicationCubit, MedicationState>(
              builder: (context, state) {
                if (state is MedicationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MedicationError) {
                  return ResponsiveCenter(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_outlined, size: 40),
                            const SizedBox(height: 12),
                            Text(state.message, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () => context
                                  .read<MedicationCubit>()
                                  .loadTodayTimeline(userId),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is MedicationLoaded) {
                  if (state.doses.isEmpty) {
                    return ResponsiveCenter(
                      child: EmptyTimelineView(
                        onScanPressed: () => context.push('/medications/scan'),
                        onManualPressed: () =>
                            showManualMedicationDialog(context, userId: userId),
                      ),
                    );
                  }

                  return ResponsiveCenter(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 96),
                      itemCount: state.doses.length,
                      itemBuilder: (context, index) {
                        final dose = state.doses[index];
                        return DoseCard(
                          dose: dose,
                          onConfirm: () => context
                              .read<MedicationCubit>()
                              .confirmDose(userId, dose.id),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationAgendaPage extends StatelessWidget {
  const MedicationAgendaPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicationCubit>()..loadTodayTimeline(userId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              _formatToday(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Agenda de medicamentos de hoy'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<MedicationCubit, MedicationState>(
              builder: (context, state) {
                if (state is MedicationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MedicationError) {
                  return Center(child: Text(state.message));
                }
                if (state is! MedicationLoaded) {
                  return const SizedBox.shrink();
                }

                final taken = state.doses
                    .where((dose) => dose.status.toUpperCase() == 'TAKEN')
                    .length;
                final pending = state.doses.length - taken;

                return ResponsiveCenter(
                  child: Column(
                    children: [
                      _AgendaSummary(
                        total: state.doses.length,
                        taken: taken,
                        pending: pending,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: state.doses.isEmpty
                            ? const _AgendaEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: state.doses.length,
                                itemBuilder: (context, index) {
                                  final dose = state.doses[index];
                                  return DoseCard(
                                    dose: dose,
                                    onConfirm: () => context
                                        .read<MedicationCubit>()
                                        .confirmDose(userId, dose.id),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatToday() {
    final today = DateTime.now();
    const weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${weekdays[today.weekday - 1]}, ${today.day} de ${months[today.month - 1]}';
  }
}

class _AgendaSummary extends StatelessWidget {
  const _AgendaSummary(
      {required this.total, required this.taken, required this.pending});

  final int total;
  final int taken;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
                child: _AgendaMetric(
                    label: 'Total', value: '$total', color: Colors.indigo)),
            Expanded(
                child: _AgendaMetric(
                    label: 'Tomadas', value: '$taken', color: Colors.green)),
            Expanded(
                child: _AgendaMetric(
                    label: 'Pendientes',
                    value: '$pending',
                    color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}

class _AgendaMetric extends StatelessWidget {
  const _AgendaMetric(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _AgendaEmptyState extends StatelessWidget {
  const _AgendaEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.event_available_outlined, size: 48),
            SizedBox(height: 12),
            Text('No hay tomas programadas para hoy',
                textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text('Incluye una receta desde el botón + para comenzar.',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
