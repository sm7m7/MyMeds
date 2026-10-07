import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/search/presentation/providers/medication_search_provider.dart';
import 'package:my_meds/features/search/presentation/screens/medication_detail_screen.dart';
import 'package:my_meds/features/search/presentation/widgets/medication_card.dart';

/// Screen providing debounced medication search, recent search history, and rich result cards.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _selectSearchTerm(String term) {
    _searchController.text = term;
    ref.read(searchQueryProvider.notifier).state = term;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(medicationSearchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Search'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mandatory disclaimer
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: MedicalDisclaimer(),
            ),

            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search brand or generic name (e.g. Ibuprofen)...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
                ],
                onChanged: _onSearchChanged,
                onSubmitted: (query) {
                  _debounceTimer?.cancel();
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              ),
            ),

            // Main Content Area
            Expanded(
              child: activeQuery.isEmpty
                  ? _buildRecentSearches(theme, recentSearches)
                  : searchResultsAsync.when(
                      loading: () => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Searching medication database...'),
                          ],
                        ),
                      ),
                      error: (error, stackTrace) => _buildErrorState(
                        theme,
                        error.toString(),
                        onRetry: () => ref.refresh(medicationSearchResultsProvider),
                      ),
                      data: (medications) {
                        if (medications.isEmpty) {
                          return _buildEmptyState(theme, activeQuery);
                        }

                        return ListView.builder(
                          itemCount: medications.length,
                          padding: const EdgeInsets.only(bottom: 24),
                          itemBuilder: (context, index) {
                            final med = medications[index];
                            return MedicationCard(
                              medication: med,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MedicationDetailScreen(medication: med),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(ThemeData theme, List<String> recentSearches) {
    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for medications by brand or generic name',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try: "Amoxicillin", "Lisinopril", "Acetaminophen"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clearAll(),
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((term) {
              return ActionChip(
                avatar: const Icon(Icons.history, size: 16),
                label: Text(term),
                onPressed: () => _selectSearchTerm(term),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No medications found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any drug labels matching "$query".\nCheck the spelling or try the generic active ingredient name.',
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

  Widget _buildErrorState(
    ThemeData theme,
    String message, {
    required VoidCallback onRetry,
  }) {
    final isOffline = message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connect');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'You\'re Offline' : 'Search Failed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
