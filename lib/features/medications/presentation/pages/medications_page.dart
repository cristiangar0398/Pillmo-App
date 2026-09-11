import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../../../core/widgets/status_message_card.dart';
import '../../domain/entities/prescription_scan_entity.dart';
import '../blocs/medications_cubit.dart';
import '../widgets/medication_tile.dart';

// Mirrors the backend's frequency parser (internal/core/services/medication_service.go)
// so invalid formats are caught client-side instead of failing on save.
final _frequencyPattern =
    RegExp(r'(?:cada|every)\s+(\d+)\s*(?:horas?|hours?)', caseSensitive: false);

String? _validateFrequency(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Indica una frecuencia, por ejemplo: Cada 8 horas';
  }
  final match = _frequencyPattern.firstMatch(value.trim());
  if (match == null) {
    return 'Usa el formato "Cada N horas", por ejemplo: Cada 8 horas';
  }
  final hours = int.parse(match.group(1)!);
  if (hours < 1 || hours > 24) {
    return 'El intervalo debe estar entre 1 y 24 horas';
  }
  return null;
}

// Matches the app's InputDecorationTheme (filled, rounded-20, translucent white
// border) so date/time selectors read as part of the same form as the text fields
// above them, instead of a bare label-and-button row.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: glass.surface.withOpacity(.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: glass.surfaceBorder.withOpacity(.7), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.mintDeep, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(color: glass.muted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          color: glass.ink, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: glass.muted),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

Future<void> showManualMedicationDialog(BuildContext context,
    {required String userId}) async {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime? selectedEndDate;
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
                      validator: _validateFrequency,
                    ),
                    const SizedBox(height: 12),
                    _PickerField(
                      icon: Icons.schedule_outlined,
                      label: 'Horario',
                      value: selectedTime.format(context),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          initialEntryMode: TimePickerEntryMode.inputOnly,
                        );
                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _PickerField(
                      icon: Icons.event_outlined,
                      label: 'Fecha de fin',
                      value: selectedEndDate == null
                          ? 'Tratamiento continuo'
                          : _formatDate(selectedEndDate!),
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedEndDate ?? now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          setState(() => selectedEndDate = picked);
                        }
                      },
                      trailing: selectedEndDate == null
                          ? null
                          : IconButton(
                              tooltip: 'Quitar fecha de fin',
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => selectedEndDate = null),
                            ),
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

  final cubit = context.read<MedicationCubit>();
  final saved = await cubit.addManualMedication(
    userId: userId,
    medicineName: nameController.text,
    dosage: dosageController.text,
    time: selectedTime,
    frequency: frequencyController.text,
    endDate: selectedEndDate == null ? null : _formatDate(selectedEndDate!),
  );

  if (context.mounted) {
    final failureState = cubit.state;
    final message = saved
        ? 'Medicamento guardado correctamente.'
        : failureState is MedicationError
            ? failureState.message
            : 'No se pudo guardar el medicamento.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
            _PickerField(
              icon: Icons.schedule_outlined,
              label: 'Horario del tratamiento',
              value: _selectedTime.format(context),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (picked != null) {
                  setState(() => _selectedTime = picked);
                }
              },
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
            final firstMedication = widget.scan.medications.isNotEmpty
                ? widget.scan.medications.first
                : null;
            final endDate = firstMedication?.durationDays == null
                ? null
                : _formatDate(
                    DateTime.now().add(
                      Duration(days: firstMedication!.durationDays! - 1),
                    ),
                  );
            final saved = await cubit.addManualMedication(
              userId: widget.userId,
              medicineName: _nameController.text,
              dosage: _dosageController.text,
              time: _selectedTime,
              frequency: _frequencyController.text,
              endDate: endDate,
              instructions: firstMedication?.instructions,
            );
            if (context.mounted) {
              final failureState = cubit.state;
              final message = saved
                  ? 'Tratamiento guardado correctamente.'
                  : failureState is MedicationError
                      ? failureState.message
                      : 'No se pudo guardar el tratamiento.';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
              if (saved) {
                Navigator.of(context).pop();
              }
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

  final cubit = context.read<MedicationCubit>();
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

class PrescriptionScanPage extends StatelessWidget {
  const PrescriptionScanPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Escanear receta')),
      body: Stack(
        children: [
          const GlassBackground(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Escaneo OCR de receta',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                const Text(
                    'Selecciona cámara o galería para subir una imagen.'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () =>
                      pickAndScanPrescription(context, userId: userId),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Abrir escáner'),
                ),
              ],
            ),
          ),
        ],
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
                              color: context.glass.mintPale,
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
                          Text(
                            'Tu agenda está despejada',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.glass.ink,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            _formatToday(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
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
                  child: StatusMessageCard(
                    message: state.message,
                    onRetry: () => context
                        .read<MedicationCubit>()
                        .loadTodayTimeline(userId),
                  ),
                );
              }

              if (state is MedicationLoaded) {
                if (state.doses.isEmpty) {
                  return ResponsiveCenter(
                    child: RefreshIndicator(
                      onRefresh: () => context
                          .read<MedicationCubit>()
                          .loadTodayTimeline(userId),
                      child: EmptyTimelineView(
                        onScanPressed: () => context.push('/medications/scan'),
                        onManualPressed: () =>
                            showManualMedicationDialog(context, userId: userId),
                      ),
                    ),
                  );
                }

                final taken = state.doses
                    .where((dose) => dose.status.toUpperCase() == 'TAKEN')
                    .length;
                final pending = state.doses.length - taken;

                return ResponsiveCenter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _DoseSummaryBar(
                          total: state.doses.length,
                          taken: taken,
                          pending: pending,
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => context
                              .read<MedicationCubit>()
                              .loadTodayTimeline(userId),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                            itemCount: state.doses.length,
                            itemBuilder: (context, index) {
                              final dose = state.doses[index];
                              return StaggeredFadeIn(
                                index: index,
                                child: DoseCard(
                                  key: ValueKey(dose.id),
                                  dose: dose,
                                  onConfirm: () => context
                                      .read<MedicationCubit>()
                                      .confirmDose(userId, dose.id),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
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

class _DoseSummaryBar extends StatelessWidget {
  const _DoseSummaryBar(
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
                child: _SummaryMetric(
                    label: 'Total', value: '$total', color: AppTheme.info)),
            Expanded(
                child: _SummaryMetric(
                    label: 'Tomadas',
                    value: '$taken',
                    color: AppTheme.success)),
            Expanded(
                child: _SummaryMetric(
                    label: 'Pendientes',
                    value: '$pending',
                    color: AppTheme.warning)),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric(
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
