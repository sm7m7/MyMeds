import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/presentation/providers/cabinet_providers.dart';
import 'package:my_meds/features/search/domain/medication_info.dart';

/// Modal bottom sheet providing a prefilled form to add an openFDA medication to the user's personal cabinet.
class AddToCabinetModal extends ConsumerStatefulWidget {
  const AddToCabinetModal({
    required this.medication,
    super.key,
  });

  final MedicationInfo medication;

  /// Convenience method to display the modal bottom sheet.
  static Future<void> show(BuildContext context, MedicationInfo medication) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddToCabinetModal(medication: medication),
    );
  }

  @override
  ConsumerState<AddToCabinetModal> createState() => _AddToCabinetModalState();
}

class _AddToCabinetModalState extends ConsumerState<AddToCabinetModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _quantityController;
  late final TextEditingController _instructionsController;

  MedicationForm _selectedForm = MedicationForm.tablet;
  final DateTime _expirationDate = DateTime.now().add(const Duration(days: 180));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _dosageController = TextEditingController(
      text: widget.medication.activeIngredients.isNotEmpty
          ? widget.medication.activeIngredients.first
          : '1 dose',
    );
    _quantityController = TextEditingController(text: '30');
    _instructionsController = TextEditingController(
      text: widget.medication.purpose ?? widget.medication.genericName ?? '',
    );

    // Guess form from route if possible
    final routeStr = widget.medication.route.join(' ').toLowerCase();
    if (routeStr.contains('injection')) {
      _selectedForm = MedicationForm.injection;
    } else if (routeStr.contains('drop') || routeStr.contains('ophthalmic') || routeStr.contains('otic')) {
      _selectedForm = MedicationForm.drops;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 30;

    final newMedication = Medication(
      id: '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      form: _selectedForm,
      quantity: quantity,
      expirationDate: _expirationDate,
      storageConditions: widget.medication.storageAndHandling,
      notes: _instructionsController.text.trim().isNotEmpty
          ? _instructionsController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    final success = await ref
        .read(cabinetControllerProvider.notifier)
        .addMedication(newMedication);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} added to your cabinet!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorState = ref.read(cabinetControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorState.error?.toString() ?? 'Failed to save to cabinet.',
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add to My Cabinet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const MedicalDisclaimer(),
                const SizedBox(height: 16),

                // Medication Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),

                // Dosage / Strength
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage / Strength',
                    hintText: 'e.g. 200 mg, 1 tablet',
                    prefixIcon: Icon(Icons.healing_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Dosage is required' : null,
                ),
                const SizedBox(height: 12),

                // Formulation Form dropdown
                DropdownButtonFormField<MedicationForm>(
                  initialValue: _selectedForm,
                  decoration: const InputDecoration(
                    labelText: 'Formulation Form',
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
                const SizedBox(height: 12),

                // Current Inventory
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Inventory (Doses)',
                    hintText: 'e.g. 30',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (v) {
                    if (v == null || int.tryParse(v) == null) {
                      return 'Enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Instructions & notes
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Usage Notes / Instructions',
                    hintText: 'e.g. Take with food',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                FilledButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_task_rounded),
                  label: const Text('Save to Cabinet'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
