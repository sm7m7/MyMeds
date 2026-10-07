import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';

/// Screen for adding a new medication or editing an existing one in the cabinet.
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({
    this.medicationToEdit,
    this.prefilledName,
    this.prefilledDosage,
    this.prefilledStorage,
    this.prefilledNotes,
    super.key,
  });

  final Medication? medicationToEdit;
  final String? prefilledName;
  final String? prefilledDosage;
  final String? prefilledStorage;
  final String? prefilledNotes;

  bool get isEditing => medicationToEdit != null;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _quantityController;
  late final TextEditingController _storageController;
  late final TextEditingController _notesController;

  late MedicationForm _selectedForm;
  late DateTime _selectedExpirationDate;

  @override
  void initState() {
    super.initState();
    final med = widget.medicationToEdit;
    _nameController = TextEditingController(
      text: med?.name ?? widget.prefilledName ?? '',
    );
    _dosageController = TextEditingController(
      text: med?.dosage ?? widget.prefilledDosage ?? '',
    );
    _quantityController = TextEditingController(
      text: med?.quantity.toString() ?? '30',
    );
    _storageController = TextEditingController(
      text: med?.storageConditions ?? widget.prefilledStorage ?? '',
    );
    _notesController = TextEditingController(
      text: med?.notes ?? widget.prefilledNotes ?? '',
    );

    _selectedForm = med?.form ?? MedicationForm.tablet;
    _selectedExpirationDate =
        med?.expirationDate ?? DateTime.now().add(const Duration(days: 180));
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
    FocusScope.of(context).unfocus();

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    final medication = Medication(
      id: widget.medicationToEdit?.id ?? '',
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
          : null,
      createdAt: widget.medicationToEdit?.createdAt ?? DateTime.now(),
      updatedAt: widget.isEditing ? DateTime.now() : null,
    );

    final controller = ref.read(cabinetControllerProvider.notifier);
    final bool success;

    if (widget.isEditing) {
      success = await controller.updateMedication(medication);
    } else {
      success = await controller.addMedication(medication);
    }

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? '${medication.name} updated successfully!'
                  : '${medication.name} added to your cabinet!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorState = ref.read(cabinetControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorState.error?.toString() ?? 'Operation failed.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(cabinetControllerProvider);
    final isLoading = state.isLoading;
    final dateFormat = DateFormat.yMMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Medication' : 'Add Medication'),
        actions: [
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: isLoading ? null : _handleSave,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MedicalDisclaimer(),
                const SizedBox(height: 20),

                // Medication Name
                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name *',
                    hintText: 'e.g. Amoxicillin, Advil',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Medication name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Dosage & Strength
                TextFormField(
                  controller: _dosageController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Dosage / Strength *',
                    hintText: 'e.g. 500 mg, 10 ml',
                    prefixIcon: Icon(Icons.healing_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Dosage is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Form Dropdown
                DropdownButtonFormField<MedicationForm>(
                  initialValue: _selectedForm,
                  decoration: const InputDecoration(
                    labelText: 'Formulation Form *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: MedicationForm.values.map((form) {
                    return DropdownMenuItem(
                      value: form,
                      child: Text(form.displayName),
                    );
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (form) {
                          if (form != null) {
                            setState(() => _selectedForm = form);
                          }
                        },
                ),
                const SizedBox(height: 16),

                // Quantity / Stock
                TextFormField(
                  controller: _quantityController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity in Stock (Units) *',
                    hintText: 'e.g. 30',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Quantity is required';
                    }
                    final parsed = int.tryParse(val.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expiration Date Picker Tile
                InkWell(
                  onTap: isLoading ? null : _selectExpirationDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiration Date *',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
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
                  enabled: !isLoading,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Storage Conditions (Optional)',
                    hintText: 'e.g. Store in a cool dry place, below 25°C',
                    prefixIcon: Icon(Icons.thermostat_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Notes
                TextFormField(
                  controller: _notesController,
                  enabled: !isLoading,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Instructions (Optional)',
                    hintText: 'e.g. Take with food, prescribed by Dr. Smith',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 28),

                // Save Button
                FilledButton.icon(
                  onPressed: isLoading ? null : _handleSave,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    widget.isEditing
                        ? 'Update Medication'
                        : 'Add to Medicine Cabinet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
