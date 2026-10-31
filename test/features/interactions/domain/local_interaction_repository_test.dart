import 'package:flutter_test/flutter_test.dart';
import 'package:my_meds/features/interactions/data/local_interaction_repository.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper factories
// ─────────────────────────────────────────────────────────────────────────────

Medication _med({
  required String id,
  required String name,
  String dosage = '1 dose',
  int quantity = 30,
}) {
  return Medication(
    id: id,
    name: name,
    dosage: dosage,
    form: MedicationForm.tablet,
    quantity: quantity,
    expirationDate: DateTime(2030),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = LocalInteractionRepository();

  // ─────────────────────────────────────────────────────────────────────────
  // normalizeToIngredient
  // ─────────────────────────────────────────────────────────────────────────
  group('LocalInteractionRepository - normalizeToIngredient', () {
    test('resolves Advil → ibuprofen (exact match)', () {
      expect(repo.normalizeToIngredient('Advil'), 'ibuprofen');
    });

    test('resolves advil (lowercase) → ibuprofen', () {
      expect(repo.normalizeToIngredient('advil'), 'ibuprofen');
    });

    test('resolves "Advil 200mg" → ibuprofen (substring match)', () {
      expect(repo.normalizeToIngredient('Advil 200mg'), 'ibuprofen');
    });

    test('resolves Tylenol → acetaminophen', () {
      expect(repo.normalizeToIngredient('Tylenol'), 'acetaminophen');
    });

    test('resolves Paracetamol → acetaminophen', () {
      expect(repo.normalizeToIngredient('Paracetamol'), 'acetaminophen');
    });

    test('resolves Coumadin → warfarin', () {
      expect(repo.normalizeToIngredient('Coumadin'), 'warfarin');
    });

    test('resolves Prozac → fluoxetine', () {
      expect(repo.normalizeToIngredient('Prozac'), 'fluoxetine');
    });

    test('resolves Lipitor → atorvastatin', () {
      expect(repo.normalizeToIngredient('Lipitor'), 'atorvastatin');
    });

    test('resolves Synthroid → levothyroxine', () {
      expect(repo.normalizeToIngredient('Synthroid'), 'levothyroxine');
    });

    test('returns lowercased name for unknown brand', () {
      expect(repo.normalizeToIngredient('SomeUnknownDrug'), 'someunknowndrug');
    });

    test('strips dosage suffix and resolves base name', () {
      // "Glucophage 500mg" → strip → "glucophage" → "metformin"
      expect(repo.normalizeToIngredient('Glucophage 500mg'), 'metformin');
    });

    test('handles empty string gracefully', () {
      expect(repo.normalizeToIngredient(''), '');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // checkInteractions — pair detection
  // ─────────────────────────────────────────────────────────────────────────
  group('LocalInteractionRepository - checkInteractions', () {
    test('returns empty list for single medication', () async {
      final meds = [_med(id: '1', name: 'Warfarin')];
      final result = await repo.checkInteractions(meds);
      expect(result, isEmpty);
    });

    test('returns empty list for empty list', () async {
      final result = await repo.checkInteractions([]);
      expect(result, isEmpty);
    });

    test('detects warfarin + aspirin interaction (major)', () async {
      final meds = [
        _med(id: '1', name: 'Warfarin'),
        _med(id: '2', name: 'Aspirin'),
      ];
      final result = await repo.checkInteractions(meds);

      expect(result.isNotEmpty, isTrue);
      final interaction = result.first;
      expect(interaction.severity, InteractionSeverity.major);
      expect(
        [interaction.ingredientA, interaction.ingredientB],
        containsAll(['warfarin', 'aspirin']),
      );
    });

    test('detects warfarin + Advil (brand name) interaction', () async {
      final meds = [
        _med(id: '1', name: 'Warfarin'),
        _med(id: '2', name: 'Advil'), // brand → ibuprofen
      ];
      final result = await repo.checkInteractions(meds);

      expect(result.isNotEmpty, isTrue);
      final interaction = result.first;
      expect(interaction.severity, InteractionSeverity.major);
    });

    test('detects sildenafil + nitroglycerin as contraindicated', () async {
      final meds = [
        _med(id: '1', name: 'Viagra'),       // → sildenafil
        _med(id: '2', name: 'Nitroglycerin'),
      ];
      final result = await repo.checkInteractions(meds);

      expect(result.isNotEmpty, isTrue);
      expect(result.first.severity, InteractionSeverity.contraindicated);
    });

    test('detects clopidogrel + omeprazole as moderate', () async {
      final meds = [
        _med(id: '1', name: 'Plavix'),   // → clopidogrel
        _med(id: '2', name: 'Prilosec'), // → omeprazole
      ];
      final result = await repo.checkInteractions(meds);

      expect(result.isNotEmpty, isTrue);
      expect(result.first.severity, InteractionSeverity.moderate);
    });

    test('returns no interaction for unrelated medications', () async {
      final meds = [
        _med(id: '1', name: 'SomeRandomDrug1'),
        _med(id: '2', name: 'SomeRandomDrug2'),
      ];
      final result = await repo.checkInteractions(meds);
      expect(result, isEmpty);
    });

    test('does not duplicate A→B and B→A for same pair', () async {
      final meds = [
        _med(id: '1', name: 'Warfarin'),
        _med(id: '2', name: 'Aspirin'),
      ];
      final result = await repo.checkInteractions(meds);

      // Should report warfarin↔aspirin only once.
      final pairs = result
          .map((i) =>
              ({i.medicationAId, i.medicationBId}).toList()..sort())
          .toList();
      expect(pairs.toSet().length, equals(pairs.length));
    });

    test('sorts results by severity — contraindicated first', () async {
      final meds = [
        _med(id: '1', name: 'Warfarin'),
        _med(id: '2', name: 'Aspirin'),     // major
        _med(id: '3', name: 'Viagra'),      // → sildenafil (none with others unless Nitroglycerin also present)
        _med(id: '4', name: 'Nitroglycerin'), // contraindicated with sildenafil
      ];
      final result = await repo.checkInteractions(meds);

      expect(result.isNotEmpty, isTrue);
      // Contraindicated severity index is highest — should be first.
      expect(result.first.severity, InteractionSeverity.contraindicated);
    });

    test('detects Lipitor + Biaxin interaction (atorvastatin + clarithromycin)', () async {
      final meds = [
        _med(id: '1', name: 'Lipitor'),  // → atorvastatin
        _med(id: '2', name: 'Biaxin'),   // → clarithromycin
      ];
      final result = await repo.checkInteractions(meds);

      expect(result.isNotEmpty, isTrue);
      expect(result.first.severity, InteractionSeverity.major);
    });

    test('does not flag same ingredient under two different brand names', () async {
      // Advil and Motrin both → ibuprofen; should not report self-interaction.
      final meds = [
        _med(id: '1', name: 'Advil'),
        _med(id: '2', name: 'Motrin'),
      ];
      final result = await repo.checkInteractions(meds);
      expect(result, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // InteractionSeverity
  // ─────────────────────────────────────────────────────────────────────────
  group('InteractionSeverity', () {
    test('fromString parses "major"', () {
      expect(InteractionSeverity.fromString('major'), InteractionSeverity.major);
    });

    test('fromString parses "contraindicated" case-insensitively', () {
      expect(
          InteractionSeverity.fromString('CONTRAINDICATED'),
          InteractionSeverity.contraindicated);
    });

    test('fromString defaults to moderate for unknown value', () {
      expect(InteractionSeverity.fromString('unknown'), InteractionSeverity.moderate);
    });

    test('displayName returns human-readable label', () {
      expect(InteractionSeverity.major.displayName, 'Major');
      expect(InteractionSeverity.moderate.displayName, 'Moderate');
      expect(InteractionSeverity.contraindicated.displayName, 'Contraindicated');
    });
  });
}
