import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/interactions/domain/models/drug_interaction.dart';
import 'package:my_meds/features/interactions/presentation/providers/interaction_providers.dart';
import 'package:my_meds/features/interactions/presentation/screens/interaction_detail_screen.dart';
import 'package:my_meds/features/interactions/presentation/widgets/interaction_list_tile.dart';

/// Full-screen list of all drug-drug interactions detected in the cabinet.
class InteractionsScreen extends ConsumerWidget {
  const InteractionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filteredAsync = ref.watch(filteredInteractionsProvider);
    final severityFilter = ref.watch(interactionSeverityFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Interactions'),
        actions: [
          // Total badge showing unfiltered count
          Consumer(builder: (context, innerRef, _) {
            final all = innerRef.watch(cabinetInteractionsProvider).valueOrNull;
            if (all == null || all.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${all.length} found',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: MedicalDisclaimer(),
          ),

          // Consult CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '⚕ Always consult a doctor or pharmacist before changing your medication regimen.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Severity filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: severityFilter == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(interactionSeverityFilterProvider.notifier)
                          .state = null;
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: severityFilter == InteractionSeverity.moderate
                      ? null
                      : const Icon(Icons.warning_amber_rounded, size: 16),
                  label: const Text('Moderate'),
                  selected: severityFilter == InteractionSeverity.moderate,
                  onSelected: (selected) {
                    ref.read(interactionSeverityFilterProvider.notifier).state =
                        selected ? InteractionSeverity.moderate : null;
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: severityFilter == InteractionSeverity.major
                      ? null
                      : const Icon(Icons.warning_rounded, size: 16),
                  label: const Text('Major'),
                  selected: severityFilter == InteractionSeverity.major,
                  onSelected: (selected) {
                    ref.read(interactionSeverityFilterProvider.notifier).state =
                        selected ? InteractionSeverity.major : null;
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: severityFilter == InteractionSeverity.contraindicated
                      ? null
                      : const Icon(Icons.block_rounded, size: 16),
                  label: const Text('Contraindicated'),
                  selected:
                      severityFilter == InteractionSeverity.contraindicated,
                  onSelected: (selected) {
                    ref.read(interactionSeverityFilterProvider.notifier).state =
                        selected ? InteractionSeverity.contraindicated : null;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 8),

          // Interaction list
          Expanded(
            child: filteredAsync.when(
              data: (interactions) {
                if (interactions.isEmpty) {
                  return _buildEmptyState(context, severityFilter);
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: interactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final interaction = interactions[index];
                    return InteractionListTile(
                      interaction: interaction,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => InteractionDetailScreen(
                            interaction: interaction,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load interactions: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, InteractionSeverity? filter) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              filter == null
                  ? 'No interactions detected'
                  : 'No ${filter.displayName.toLowerCase()} interactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              filter == null
                  ? 'Great news! No known interactions were found among '
                      'the medications in your cabinet. Always check with '
                      'your pharmacist when adding new medications.'
                  : 'No interactions at this severity level were found. '
                      'Try removing the filter to see all results.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
