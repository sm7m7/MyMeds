import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';

/// Use case to filter and search a list of medications.
class FilterMedicationsUseCase {
  const FilterMedicationsUseCase();

  List<Medication> call({
    required List<Medication> medications,
    String? query,
    MedicationForm? formFilter,
    MedicationStatus? statusFilter,
    DateTime? now,
  }) {
    var filtered = List<Medication>.from(medications);

    // 1. Text search query filter (name, dosage, notes, storage conditions)
    if (query != null && query.trim().isNotEmpty) {
      final clean = query.trim().toLowerCase();
      filtered = filtered.where((med) {
        final nameMatch = med.name.toLowerCase().contains(clean);
        final dosageMatch = med.dosage.toLowerCase().contains(clean);
        final notesMatch = med.notes?.toLowerCase().contains(clean) ?? false;
        final storageMatch =
            med.storageConditions?.toLowerCase().contains(clean) ?? false;
        return nameMatch || dosageMatch || notesMatch || storageMatch;
      }).toList();
    }

    // 2. Form filter
    if (formFilter != null) {
      filtered = filtered.where((med) => med.form == formFilter).toList();
    }

    // 3. Status filter
    if (statusFilter != null) {
      final currentTime = now ?? DateTime.now();
      filtered = filtered.where((med) {
        final allStatuses = med.getAllStatuses(currentTime);
        return allStatuses.contains(statusFilter);
      }).toList();
    }

    // Sort: Expired & Expiring soon first, then by name alphabetically
    filtered.sort((a, b) {
      final aExpired = a.isExpired(now);
      final bExpired = b.isExpired(now);
      if (aExpired != bExpired) return aExpired ? -1 : 1;

      final aExpiring = a.isExpiringSoon(now);
      final bExpiring = b.isExpiringSoon(now);
      if (aExpiring != bExpiring) return aExpiring ? -1 : 1;

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return filtered;
  }
}
