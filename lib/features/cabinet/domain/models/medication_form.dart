/// Types of medication physical formulation forms.
enum MedicationForm {
  tablet,
  capsule,
  syrup,
  injection,
  drops,
  other;

  /// User-friendly display label.
  String get displayName {
    switch (this) {
      case MedicationForm.tablet:
        return 'Tablet';
      case MedicationForm.capsule:
        return 'Capsule';
      case MedicationForm.syrup:
        return 'Syrup';
      case MedicationForm.injection:
        return 'Injection';
      case MedicationForm.drops:
        return 'Drops';
      case MedicationForm.other:
        return 'Other';
    }
  }

  /// Parses string to [MedicationForm], defaulting to [MedicationForm.other].
  static MedicationForm fromString(String? value) {
    if (value == null) return MedicationForm.other;
    final normalized = value.trim().toLowerCase();
    for (final form in MedicationForm.values) {
      if (form.name == normalized || form.displayName.toLowerCase() == normalized) {
        return form;
      }
    }
    return MedicationForm.other;
  }
}
