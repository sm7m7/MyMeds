import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:my_meds/core/widgets/medical_disclaimer.dart';

final _notifications = FlutterLocalNotificationsPlugin();

CollectionReference<Map<String, dynamic>>? _appointments() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('appointments');
}

int _notifId(String docId) => docId.hashCode & 0x7fffffff;

Future<void> _initNotifications() async {
  tzdata.initializeTimeZones();
  await _notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await _notifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

/// Schedules a notification exactly 1 day before the appointment.
Future<void> _scheduleReminder(
    String docId, String doctor, DateTime when) async {
  final remindAt = when.subtract(const Duration(days: 1));
  if (remindAt.isBefore(DateTime.now())) return;
  await _notifications.zonedSchedule(
    _notifId(docId),
    'Appointment tomorrow',
    'Appointment with $doctor at ${DateFormat.jm().format(when)}',
    tz.TZDateTime.from(remindAt, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'appointments',
        'Appointments',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
  );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _delete(String id) async {
    await _notifications.cancel(_notifId(id));
    await _appointments()?.doc(id).delete();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddAppointmentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final col = _appointments();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor appointments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Appointment'),
      ),
      body: col == null
          ? const Center(child: Text('Please sign in'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.orderBy('date').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const MedicalDisclaimer(),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      'No appointments yet.\nTap Add Appointment to create one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              for (final doc in docs)
                Builder(builder: (context) {
                  final d = doc.data();
                  final date = (d['date'] as Timestamp).toDate();
                  final past = date.isBefore(DateTime.now());
                  final notes = (d['notes'] ?? '').toString();
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.event,
                          color:
                          past ? scheme.tertiary : scheme.primary),
                      title: Text(d['doctor'] ?? ''),
                      subtitle: Text(
                        '${DateFormat.yMMMEd().add_jm().format(date)}'
                            '${notes.isNotEmpty ? '\n$notes' : ''}'
                            '\nReminder: 1 day before',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(doc.id),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _AddAppointmentSheet extends StatefulWidget {
  const _AddAppointmentSheet();

  @override
  State<_AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<_AddAppointmentSheet> {
  final _doctor = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  DateTime? get _when => (_date == null || _time == null)
      ? null
      : DateTime(
      _date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);

  @override
  void dispose() {
    _doctor.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    final when = _when;
    final col = _appointments();
    if (col == null) return;
    if (_doctor.text.trim().isEmpty || when == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the doctor, date and time')),
      );
      return;
    }
    setState(() => _saving = true);
    final doctor = _doctor.text.trim();
    final ref = await col.add({
      'doctor': doctor,
      'notes': _notes.text.trim(),
      'date': Timestamp.fromDate(when),
    });
    await _scheduleReminder(ref.id, doctor, when);

    if (!mounted) return;
    final tooLate = when.subtract(const Duration(days: 1)).isBefore(DateTime.now());
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    if (tooLate) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Saved. Less than 1 day left, so no reminder was set.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _doctor,
            decoration: const InputDecoration(labelText: 'Doctor name'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_date == null
                      ? 'Date'
                      : DateFormat.yMMMd().format(_date!)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_time == null ? 'Time' : _time!.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save and remind me 1 day before'),
            ),
          ),
        ],
      ),
    );
  }
}