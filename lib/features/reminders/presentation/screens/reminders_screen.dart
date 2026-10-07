import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:my_meds/features/reminders/presentation/screens/reminder_form_screen.dart';
import 'package:my_meds/features/reminders/presentation/widgets/dose_occurrence_card.dart';
import 'package:my_meds/features/reminders/presentation/widgets/reminder_card.dart';

/// Main Reminders screen with "Today" timeline and "All Reminders" rule management.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.today_rounded),
              text: 'Today',
            ),
            Tab(
              icon: Icon(Icons.list_alt_rounded),
              text: 'All Reminders',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(theme),
          _buildAllRemindersTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ReminderFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('New Reminder'),
      ),
    );
  }

  Widget _buildTodayTab(ThemeData theme) {
    final todayOccurrencesAsync = ref.watch(todayOccurrencesProvider);
    final todayStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayDoseLogsStreamProvider);
        ref.invalidate(userRemindersStreamProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: MedicalDisclaimer(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  todayStr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          todayOccurrencesAsync.when(
            data: (occurrences) {
              if (occurrences.isEmpty) {
                return _buildEmptyTodayState(theme);
              }

              // Progress summary computation
              final total = occurrences.length;
              final takenCount = occurrences.where((o) => o.isTaken).length;
              final progress = total > 0 ? (takenCount / total) : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.primaryContainer.withAlpha(80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's Progress",
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$takenCount / $total doses taken',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...occurrences.map((occurrence) {
                    return DoseOccurrenceCard(occurrence: occurrence);
                  }),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading doses: $err'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRemindersTab(ThemeData theme) {
    final remindersAsync = ref.watch(userRemindersStreamProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userRemindersStreamProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: MedicalDisclaimer(),
          ),
          remindersAsync.when(
            data: (reminders) {
              if (reminders.isEmpty) {
                return _buildEmptyRemindersState(theme);
              }

              return Column(
                children: reminders.map((reminder) {
                  return ReminderCard(
                    reminder: reminder,
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReminderFormScreen(
                            existingReminder: reminder,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading reminders: $err'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTodayState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 44,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Doses Scheduled for Today',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no active medication doses configured for today. Set up reminders to stay on schedule.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReminderFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text('Create Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRemindersState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Reminders Created Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up smart reminders with custom frequencies, intervals, and notification alerts.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReminderFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text('Add First Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
