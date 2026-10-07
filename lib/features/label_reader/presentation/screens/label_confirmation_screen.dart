import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/label_reader/domain/models/parsed_medication_label.dart';

/// Screen where user reviews, verifies, and edits AI-extracted medication label data before saving to Cabinet.
class LabelConfirmationScreen extends ConsumerStatefulWidget {
  const LabelConfirmationScreen({
    required this.parsedLabel,
    this.imagePath,
    super.key,
  });

  final ParsedMedicationLabel parsedLabel;
  final String? imagePath;

  @override
  ConsumerState<LabelConfirmationScreen> createState() =>
      _LabelConfirmationScreenState();
}

class _LabelConfirmationScreenState
    extends ConsumerState<LabelConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _quantityController;
  late final TextEditingController _storageController;
  late final TextEditingController _notesController;

  late MedicationForm _selectedForm;
  late DateTime _selectedExpirationDate;
  bool _showRawOcr = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final label = widget.parsedLabel;
    _nameController = TextEditingController(text: label.name ?? '');
    _dosageController = TextEditingController(text: label.dosage ?? '');
    _quantityController = TextEditingController(text: '30');
    _storageController =
        TextEditingController(text: label.storageConditions ?? '');
    _notesController = TextEditingController();

    _selectedForm = MedicationForm.fromString(label.form);
    _selectedExpirationDate = label.parseExpirationDate() ??
        DateTime.now().add(const Duration(days: 180));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _storageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _selectedExpirationDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 30;

    final medication = Medication(
      id: '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      form: _selectedForm,
      quantity: quantity,
      expirationDate: _selectedExpirationDate,
      storageConditions: _storageController.text.trim().isNotEmpty
          ? _storageController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : 'Scanned via AI Label Reader',
      createdAt: DateTime.now(),
    );

    final success = await ref
        .read(cabinetControllerProvider.notifier)
        .addMedication(medication);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        // Pop back to main cabinet view
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medication.name} saved to your medicine cabinet!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorState = ref.read(cabinetControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorState.error?.toString() ?? 'Failed to save medication.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = widget.parsedLabel;
    final confidencePct = (label.confidence * 100).toInt();
    final dateFormat = DateFormat.yMMMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Label Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Medical & Verification Disclaimer
                const MedicalDisclaimer(),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 20,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI-extracted data must be verified against your physical medication container before saving.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Confidence Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (widget.imagePath != null &&
                            File(widget.imagePath!).existsSync()) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(widget.imagePath!),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Scan Confidence',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: label.confidence,
                                      color: label.isLowConfidence
                                          ? Colors.orange
                                          : theme.colorScheme.primary,
                                      backgroundColor: theme
                                          .colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '$confidencePct%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: label.isLowConfidence
                                          ? Colors.orange[800]
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              if (label.isLowConfidence) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Some fields need attention or manual input.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Medication Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Medication Name *',
                    hintText: 'e.g. Advil, Amoxicillin',
                    prefixIcon: const Icon(Icons.medication_outlined),
                    helperText: label.name == null
                        ? '⚠️ Name not detected on label — please enter manually'
                        : null,
                    helperStyle: TextStyle(color: Colors.orange[800]),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter the medication name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Dosage Field
                TextFormField(
                  controller: _dosageController,
                  decoration: InputDecoration(
                    labelText: 'Dosage / Strength *',
                    hintText: 'e.g. 500 mg, 10 ml',
                    prefixIcon: const Icon(Icons.healing_outlined),
                    helperText: label.dosage == null
                        ? '⚠️ Dosage strength not detected — please verify'
                        : null,
                    helperStyle: TextStyle(color: Colors.orange[800]),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter the dosage'
                      : null,
                ),
                const SizedBox(height: 16),

                // Formulation Form Dropdown
                DropdownButtonFormField<MedicationForm>(
                  initialValue: _selectedForm,
                  decoration: const InputDecoration(
                    labelText: 'Formulation Form *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: MedicationForm.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedForm = val);
                  },
                ),
                const SizedBox(height: 16),

                // Quantity Field
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Inventory (Units) *',
                    hintText: 'e.g. 30',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (v) {
                    if (v == null || int.tryParse(v) == null) {
                      return 'Enter a valid count';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expiration Date Picker
                InkWell(
                  onTap: _selectExpirationDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiration Date *',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      helperText: label.expirationDate == null
                          ? '⚠️ Expiration not detected — set date from container'
                          : null,
                      helperStyle: TextStyle(color: Colors.orange[800]),
                    ),
                    child: Text(
                      dateFormat.format(_selectedExpirationDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Storage Conditions
                TextFormField(
                  controller: _storageController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Storage Instructions (Optional)',
                    hintText: 'e.g. Store below 25°C in a dry place',
                    prefixIcon: Icon(Icons.thermostat_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Optional Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    hintText: 'e.g. Take with water',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Expandable Raw OCR Text viewer
                if (label.rawOcrText.isNotEmpty) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('View Raw OCR Text'),
                    trailing: Icon(
                      _showRawOcr
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () => setState(() => _showRawOcr = !_showRawOcr),
                  ),
                  if (_showRawOcr)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label.rawOcrText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],

                // Save Button
                FilledButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Confirm & Save to Cabinet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Fallback link to manual search
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.search);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search Drug Database Instead'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
