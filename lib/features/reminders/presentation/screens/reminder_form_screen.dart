import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';
import 'package:my_meds/features/reminders/presentation/providers/reminders_providers.dart';

/// Form screen for creating or editing a medication reminder.
class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({
    super.key,
    this.existingReminder,
    this.prefilledMedication,
  });

  final MedicationReminder? existingReminder;
  final Medication? prefilledMedication;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Medication? _selectedMedication;
  late final TextEditingController _dosageController;
  late final TextEditingController _durationController;

  ReminderFrequency _frequency = ReminderFrequency.daily;
  int _intervalHours = 8;
  List<int> _selectedWeekdays = [1, 2, 3, 4, 5, 6, 7];
  List<String> _times = ['08:00', '20:00'];
  DateTime _startDate = DateTime.now();
  bool _isOngoing = true;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReminder;
    if (r != null) {
      _dosageController = TextEditingController(text: r.dosage);
      _durationController = TextEditingController(
        text: r.durationDays != null ? r.durationDays.toString() : '',
      );
      _frequency = r.frequency;
      _intervalHours = r.intervalHours ?? 8;
      _selectedWeekdays = r.weekdays.isNotEmpty ? List.from(r.weekdays) : [1, 2, 3, 4, 5, 6, 7];
      _times = r.times.isNotEmpty ? List.from(r.times) : ['08:00'];
      _startDate = r.startDate;
      _isOngoing = r.durationDays == null;
      _isActive = r.isActive;
    } else {
      _selectedMedication = widget.prefilledMedication;
      _dosageController = TextEditingController(
        text: widget.prefilledMedication?.dosage ?? '',
      );
      _durationController = TextEditingController();
    }

    // Request notification permissions when opening form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).requestPermissions();
    });
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingReminder != null;
    final cabinetAsync = ref.watch(cabinetMedicationsStreamProvider);
    final actionState = ref.watch(reminderCrudControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'New Reminder'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
              tooltip: 'Delete Reminder',
              onPressed: _deleteReminder,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const MedicalDisclaimer(),
            const SizedBox(height: 20),

            // 1. Medication Picker
            Text(
              'Medication',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            cabinetAsync.when(
              data: (medications) {
                if (medications.isEmpty) {
                  return Card(
                    color: theme.colorScheme.errorContainer.withAlpha(50),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your cabinet is empty.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add a medication to your medicine cabinet first before setting up reminders.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // If editing and selectedMedication not resolved yet, match by ID
                if (_selectedMedication == null && widget.existingReminder != null) {
                  final match = medications.where(
                    (m) => m.id == widget.existingReminder!.medicationId,
                  );
                  if (match.isNotEmpty) {
                    _selectedMedication = match.first;
                  }
                }

                return DropdownButtonFormField<Medication>(
                  initialValue: _selectedMedication,
                  decoration: const InputDecoration(
                    labelText: 'Select from Cabinet',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  items: medications.map((med) {
                    return DropdownMenuItem(
                      value: med,
                      child: Text('${med.name} (${med.dosage})'),
                    );
                  }).toList(),
                  validator: (val) {
                    if (val == null && widget.existingReminder == null) {
                      return 'Please select a medication';
                    }
                    return null;
                  },
                  onChanged: (selected) {
                    if (selected != null) {
                      setState(() {
                        _selectedMedication = selected;
                        if (_dosageController.text.isEmpty ||
                            _dosageController.text == '1 dose') {
                          _dosageController.text = selected.dosage;
                        }
                      });
                    }
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('Failed to load cabinet: $err'),
            ),
            const SizedBox(height: 16),

            // 2. Dosage Field
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage / Quantity to take',
                hintText: 'e.g. 500 mg, 1 tablet, 5 ml',
                prefixIcon: Icon(Icons.colorize_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please specify the dosage';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 3. Frequency Selector
            Text(
              'Frequency',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ReminderFrequency>(
              segments: const [
                ButtonSegment(
                  value: ReminderFrequency.daily,
                  label: Text('Daily'),
                  icon: Icon(Icons.calendar_today_rounded, size: 16),
                ),
                ButtonSegment(
                  value: ReminderFrequency.intervalHours,
                  label: Text('Interval'),
                  icon: Icon(Icons.timelapse_rounded, size: 16),
                ),
                ButtonSegment(
                  value: ReminderFrequency.specificWeekdays,
                  label: Text('Weekdays'),
                  icon: Icon(Icons.view_week_rounded, size: 16),
                ),
              ],
              selected: {_frequency},
              onSelectionChanged: (set) {
                setState(() {
                  _frequency = set.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Frequency Details Sub-views
            if (_frequency == ReminderFrequency.daily) ...[
              _buildTimesListSection(theme),
            ] else if (_frequency == ReminderFrequency.intervalHours) ...[
              _buildIntervalSection(theme),
            ] else if (_frequency == ReminderFrequency.specificWeekdays) ...[
              _buildWeekdaysSection(theme),
              const SizedBox(height: 16),
              _buildTimesListSection(theme),
            ],

            const SizedBox(height: 24),

            // 4. Start Date & Duration
            Text(
              'Schedule Schedule & Duration',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Start Date'),
              subtitle: Text(DateFormat('EEEE, MMMM d, yyyy').format(_startDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ongoing (No end date)'),
              subtitle: const Text('Repeats indefinitely until stopped'),
              value: _isOngoing,
              onChanged: (val) {
                setState(() {
                  _isOngoing = val;
                });
              },
            ),
            if (!_isOngoing) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (in days)',
                  hintText: 'e.g. 7, 10, 14',
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                validator: (val) {
                  if (!_isOngoing) {
                    final num = int.tryParse(val?.trim() ?? '');
                    if (num == null || num <= 0) {
                      return 'Enter a valid number of days';
                    }
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Submit Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: actionState is ReminderActionLoading ? null : _saveReminder,
              icon: actionState is ReminderActionLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                isEditing ? 'Update Reminder' : 'Save Reminder',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimesListSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dose Times (${_times.length}/day)',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Time'),
              onPressed: _addNewTime,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _times.map((t) {
            return Chip(
              avatar: const Icon(Icons.access_time, size: 16),
              label: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
              deleteIcon: _times.length > 1 ? const Icon(Icons.close, size: 16) : null,
              onDeleted: _times.length > 1
                  ? () {
                      setState(() {
                        _times.remove(t);
                      });
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntervalSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interval: Every $_intervalHours hours',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _intervalHours.toDouble(),
          min: 2,
          max: 12,
          divisions: 5, // 2, 4, 6, 8, 10, 12
          label: '$_intervalHours hrs',
          onChanged: (val) {
            setState(() {
              _intervalHours = val.toInt();
            });
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.alarm_on_outlined),
          title: const Text('First dose of the day'),
          subtitle: Text(_times.isNotEmpty ? _times.first : '08:00'),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 8, minute: 0),
            );
            if (picked != null) {
              final formatted =
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              setState(() {
                _times = [formatted];
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeekdaysSection(ThemeData theme) {
    const dayLabels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Days',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final dayIndex = i + 1;
            final isSelected = _selectedWeekdays.contains(dayIndex);
            return FilterChip(
              label: Text(dayLabels[dayIndex]!),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedWeekdays.add(dayIndex);
                  } else {
                    if (_selectedWeekdays.length > 1) {
                      _selectedWeekdays.remove(dayIndex);
                    }
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Future<void> _addNewTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_times.contains(formatted)) {
        setState(() {
          _times.add(formatted);
          _times.sort();
        });
      }
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final medId = _selectedMedication?.id ?? widget.existingReminder?.medicationId ?? '';
    final medName = _selectedMedication?.name ?? widget.existingReminder?.medicationName ?? 'Medication';

    final duration = !_isOngoing ? int.tryParse(_durationController.text.trim()) : null;

    final reminder = MedicationReminder(
      id: widget.existingReminder?.id ?? '',
      medicationId: medId,
      medicationName: medName,
      dosage: _dosageController.text.trim(),
      times: _times,
      frequency: _frequency,
      intervalHours: _frequency == ReminderFrequency.intervalHours ? _intervalHours : null,
      weekdays: _frequency == ReminderFrequency.specificWeekdays ? _selectedWeekdays : const [],
      startDate: _startDate,
      durationDays: duration,
      isActive: _isActive,
      createdAt: widget.existingReminder?.createdAt ?? DateTime.now(),
      updatedAt: widget.existingReminder != null ? DateTime.now() : null,
    );

    final success = await ref
        .read(reminderCrudControllerProvider.notifier)
        .saveReminder(reminder);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder saved and notifications scheduled!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  void _deleteReminder() {
    final r = widget.existingReminder;
    if (r == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text('Are you sure you want to delete the reminder for "${r.medicationName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(reminderCrudControllerProvider.notifier).deleteReminder(r.id);
              if (mounted) context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
