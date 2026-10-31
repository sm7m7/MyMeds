import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/emergency/domain/models/emergency_card_data.dart';
import 'package:my_meds/features/reminders/domain/models/dose_log.dart';
import 'package:my_meds/features/reminders/domain/models/medication_reminder.dart';

/// Utility service to seed demo data into an authenticated user's Firestore profile.
///
/// Populates:
/// 1. Sample Medications (diverse forms, stock, and expiration states)
/// 2. Active Reminders
/// 3. Realistic 7-day Dose History Logs (with ~85% adherence)
/// 4. Complete Emergency Medical Card
class DemoDataSeeder {
  DemoDataSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seedUserDemoData(String userId) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    // ── 1. MEDICATIONS ────────────────────────────────────────────────────────
    final medicationsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('medications');

    final sampleMeds = [
      Medication(
        id: 'demo_med_amoxicillin',
        name: 'Amoxicillin',
        dosage: '500 mg',
        form: MedicationForm.capsule,
        quantity: 18,
        expirationDate: now.add(const Duration(days: 120)),
        storageConditions: 'Store below 25°C in a dry place',
        notes: 'Take with full glass of water. Complete full course.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Medication(
        id: 'demo_med_lipitor',
        name: 'Lipitor (Atorvastatin)',
        dosage: '20 mg',
        form: MedicationForm.tablet,
        quantity: 4, // Low stock alert!
        expirationDate: now.add(const Duration(days: 240)),
        storageConditions: 'Room temperature',
        notes: 'Take once daily in the evening',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Medication(
        id: 'demo_med_aspirin',
        name: 'Aspirin Cardio',
        dosage: '81 mg',
        form: MedicationForm.tablet,
        quantity: 45,
        expirationDate: now.add(const Duration(days: 14)), // Expiring soon!
        storageConditions: 'Keep bottle tightly closed',
        notes: 'Take with breakfast',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      Medication(
        id: 'demo_med_ventolin',
        name: 'Ventolin HFA (Albuterol)',
        dosage: '90 mcg/actuation',
        form: MedicationForm.other,
        quantity: 2,
        expirationDate: now.add(const Duration(days: 365)),
        storageConditions: 'Store between 15°C and 30°C',
        notes: 'As needed for shortness of breath',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Medication(
        id: 'demo_med_eye_drops',
        name: 'Systane Ultra Eye Drops',
        dosage: '1-2 drops',
        form: MedicationForm.drops,
        quantity: 1,
        expirationDate: now.subtract(const Duration(days: 5)), // Expired!
        storageConditions: 'Discard 30 days after opening',
        notes: 'Keep in travel pouch',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];

    for (final med in sampleMeds) {
      batch.set(medicationsRef.doc(med.id), med.toJson());
    }

    // ── 2. REMINDERS ──────────────────────────────────────────────────────────
    final remindersRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders');

    final sampleReminders = [
      MedicationReminder(
        id: 'demo_rem_amoxicillin',
        medicationId: 'demo_med_amoxicillin',
        medicationName: 'Amoxicillin',
        dosage: '500 mg',
        times: ['08:00', '20:00'],
        frequency: ReminderFrequency.daily,
        startDate: now.subtract(const Duration(days: 7)),
        durationDays: 14,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      MedicationReminder(
        id: 'demo_rem_lipitor',
        medicationId: 'demo_med_lipitor',
        medicationName: 'Lipitor (Atorvastatin)',
        dosage: '20 mg',
        times: ['21:00'],
        frequency: ReminderFrequency.daily,
        startDate: now.subtract(const Duration(days: 30)),
        durationDays: 90,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      MedicationReminder(
        id: 'demo_rem_aspirin',
        medicationId: 'demo_med_aspirin',
        medicationName: 'Aspirin Cardio',
        dosage: '81 mg',
        times: ['09:00'],
        frequency: ReminderFrequency.daily,
        startDate: now.subtract(const Duration(days: 60)),
        durationDays: 180,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];

    for (final rem in sampleReminders) {
      batch.set(remindersRef.doc(rem.id), rem.toJson());
    }

    // ── 3. DOSE LOGS (7-DAY ADHERENCE HISTORY) ─────────────────────────────────
    final doseLogsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('doseLogs');

    // Generate ~21 logs over past 7 days (18 taken, 2 skipped, 1 missed = ~86% adherence)
    int logIndex = 0;
    for (int day = 6; day >= 0; day--) {
      final logDay = now.subtract(Duration(days: day));

      // Morning Amoxicillin (taken on all days except day 2)
      final amoxMorningTime = DateTime(logDay.year, logDay.month, logDay.day, 8, 0);
      final amoxStatus = (day == 2) ? DoseLogStatus.missed : DoseLogStatus.taken;
      final amoxLog = DoseLog(
        id: 'demo_log_${logIndex++}',
        reminderId: 'demo_rem_amoxicillin',
        medicationId: 'demo_med_amoxicillin',
        medicationName: 'Amoxicillin',
        dosage: '500 mg',
        scheduledTime: amoxMorningTime,
        actualTime: amoxStatus == DoseLogStatus.taken ? amoxMorningTime.add(const Duration(minutes: 10)) : null,
        status: amoxStatus,
        createdAt: amoxMorningTime,
      );
      batch.set(doseLogsRef.doc(amoxLog.id), amoxLog.toJson());

      // Morning Aspirin (taken all days except day 4 skipped)
      final aspTime = DateTime(logDay.year, logDay.month, logDay.day, 9, 0);
      final aspStatus = (day == 4) ? DoseLogStatus.skipped : DoseLogStatus.taken;
      final aspLog = DoseLog(
        id: 'demo_log_${logIndex++}',
        reminderId: 'demo_rem_aspirin',
        medicationId: 'demo_med_aspirin',
        medicationName: 'Aspirin Cardio',
        dosage: '81 mg',
        scheduledTime: aspTime,
        actualTime: aspStatus == DoseLogStatus.taken ? aspTime.add(const Duration(minutes: 5)) : null,
        status: aspStatus,
        notes: (day == 4) ? 'Fasting for routine lab blood test' : null,
        createdAt: aspTime,
      );
      batch.set(doseLogsRef.doc(aspLog.id), aspLog.toJson());

      // Evening Lipitor (taken on all days)
      final lipTime = DateTime(logDay.year, logDay.month, logDay.day, 21, 0);
      final lipLog = DoseLog(
        id: 'demo_log_${logIndex++}',
        reminderId: 'demo_rem_lipitor',
        medicationId: 'demo_med_lipitor',
        medicationName: 'Lipitor (Atorvastatin)',
        dosage: '20 mg',
        scheduledTime: lipTime,
        actualTime: lipTime.add(const Duration(minutes: 12)),
        status: DoseLogStatus.taken,
        createdAt: lipTime,
      );
      batch.set(doseLogsRef.doc(lipLog.id), lipLog.toJson());
    }

    // ── 4. EMERGENCY MEDICAL CARD ─────────────────────────────────────────────
    final emergencyCardRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('emergencyCard')
        .doc('profile');

    final sampleEmergencyCard = EmergencyCardData(
      fullName: 'Alex Vance',
      bloodType: 'O+',
      allergies: const ['Penicillin', 'Peanuts', 'Sulfa drugs'],
      chronicConditions: 'Asthma (managed with Albuterol), Mild essential hypertension',
      emergencyContacts: const [
        EmergencyContact(
          name: 'Sarah Vance',
          phone: '+1-555-0199',
          relationship: 'Spouse',
        ),
        EmergencyContact(
          name: 'Dr. Michael Chen',
          phone: '+1-555-0144',
          relationship: 'Primary Care Physician',
        ),
      ],
      updatedAt: now,
    );
    batch.set(emergencyCardRef, sampleEmergencyCard.toJson());

    // Commit all writes atomically
    await batch.commit();
  }
}
