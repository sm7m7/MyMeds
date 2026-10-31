import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/emergency/domain/models/emergency_card_data.dart';
import 'package:my_meds/features/emergency/presentation/providers/emergency_card_providers.dart';

/// Form screen allowing the user to configure their personal Emergency Medical Card:
/// - Full name
/// - Blood type (A+, A-, B+, B-, AB+, AB-, O+, O-, Unknown)
/// - Allergies list
/// - Chronic conditions & critical notes
/// - Emergency contacts list (name, phone, relation)
class EmergencyCardFormScreen extends ConsumerStatefulWidget {
  const EmergencyCardFormScreen({
    this.initialData,
    super.key,
  });

  final EmergencyCardData? initialData;

  @override
  ConsumerState<EmergencyCardFormScreen> createState() =>
      _EmergencyCardFormScreenState();
}

class _EmergencyCardFormScreenState
    extends ConsumerState<EmergencyCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _chronicController;
  String? _selectedBloodType;

  final List<EmergencyContact> _contacts = [];

  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?.fullName ?? '');
    _allergiesController =
        TextEditingController(text: data?.allergies.join(', ') ?? '');
    _chronicController =
        TextEditingController(text: data?.chronicConditions ?? '');
    _selectedBloodType = data?.bloodType;

    if (data != null && data.emergencyContacts.isNotEmpty) {
      _contacts.addAll(data.emergencyContacts);
    } else {
      // Default initial contact
      _contacts.add(const EmergencyContact(
        name: '',
        phone: '',
        relationship: 'Family',
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _chronicController.dispose();
    super.dispose();
  }

  void _addContact() {
    setState(() {
      _contacts.add(const EmergencyContact(
        name: '',
        phone: '',
        relationship: 'Family',
      ));
    });
  }

  void _removeContact(int index) {
    if (_contacts.length > 1) {
      setState(() {
        _contacts.removeAt(index);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final allergiesList = _allergiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Filter out completely blank contacts
    final validContacts = _contacts
        .where((c) => c.name.trim().isNotEmpty && c.phone.trim().isNotEmpty)
        .toList();

    final card = EmergencyCardData(
      fullName: _nameController.text.trim(),
      bloodType: _selectedBloodType,
      allergies: allergiesList,
      chronicConditions: _chronicController.text.trim(),
      emergencyContacts: validContacts,
    );

    final success =
        await ref.read(emergencyCardControllerProvider.notifier).saveCard(card);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency Card saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save Emergency Card.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(emergencyCardControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Emergency Card'),
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

                // Full Name
                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Jane Doe',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter your full name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Blood Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodType,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type (Optional)',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  items: _bloodTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (val) {
                          setState(() => _selectedBloodType = val);
                        },
                ),
                const SizedBox(height: 16),

                // Allergies
                TextFormField(
                  controller: _allergiesController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Allergies (comma-separated)',
                    hintText: 'e.g. Penicillin, Peanuts, Latex',
                    prefixIcon: Icon(Icons.warning_amber_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                // Chronic Conditions / Notes
                TextFormField(
                  controller: _chronicController,
                  enabled: !isLoading,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Chronic Conditions & Medical Notes',
                    hintText: 'e.g. Type 1 Diabetes, Asthma, Pacemaker installed',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                // Emergency Contacts Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Contact'),
                      onPressed: isLoading ? null : _addContact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Contacts list form
                ..._contacts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final contact = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Contact #${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (_contacts.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: isLoading ? null : () => _removeContact(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: contact.name,
                            decoration: const InputDecoration(
                              labelText: 'Contact Name *',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (val) {
                              if (index == 0 && (val == null || val.trim().isEmpty)) {
                                return 'At least one contact name is required';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              _contacts[index] = contact.copyWith(name: val);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: contact.phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number *',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (val) {
                              if (index == 0 && (val == null || val.trim().isEmpty)) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              _contacts[index] = contact.copyWith(phone: val);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: contact.relationship,
                            decoration: const InputDecoration(
                              labelText: 'Relationship (e.g. Spouse, Parent, Doctor)',
                              prefixIcon: Icon(Icons.favorite_outline),
                            ),
                            onChanged: (val) {
                              _contacts[index] = contact.copyWith(relationship: val);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Save button
                FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Emergency Card'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isLoading ? null : _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
