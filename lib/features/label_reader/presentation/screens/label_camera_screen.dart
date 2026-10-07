import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_meds/core/router/router.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/label_reader/presentation/controllers/label_reader_controller.dart';
import 'package:my_meds/features/label_reader/presentation/providers/label_reader_providers.dart';
import 'package:my_meds/features/label_reader/presentation/screens/label_confirmation_screen.dart';

/// Screen for capturing or uploading a medication container label photo.
class LabelCameraScreen extends ConsumerWidget {
  const LabelCameraScreen({super.key});

  void _onSuccess(BuildContext context, WidgetRef ref, LabelReaderSuccess state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(labelReaderControllerProvider.notifier).reset();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LabelConfirmationScreen(
            parsedLabel: state.parsedLabel,
            imagePath: state.imagePath,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(labelReaderControllerProvider);
    final controller = ref.read(labelReaderControllerProvider.notifier);

    // If success, navigate to confirmation screen
    if (state is LabelReaderSuccess) {
      _onSuccess(context, ref, state);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Label Reader'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MedicalDisclaimer(),
              const SizedBox(height: 16),

              // Viewfinder / Frame Guide Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Guide Viewfinder Box
                      Container(
                        margin: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: state is LabelReaderProcessingOcr ||
                                  state is LabelReaderAnalyzingAi ||
                                  state is LabelReaderCapturing
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      state is LabelReaderProcessingOcr
                                          ? 'Reading label text on-device (OCR)...'
                                          : 'Analyzing medication details with AI...',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.document_scanner_outlined,
                                      size: 72,
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Position medication box or bottle label here',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ensure adequate lighting & sharp focus',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Error notification card if any
              if (state is LabelReaderError) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.message,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          context.go(AppRoutes.search);
                        },
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Search Drug Database Manually'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons: Camera & Gallery
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (state is LabelReaderProcessingOcr ||
                              state is LabelReaderAnalyzingAi)
                          ? null
                          : () => controller.pickAndProcessImage(
                                source: ImageSource.gallery,
                              ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Upload Photo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (state is LabelReaderProcessingOcr ||
                              state is LabelReaderAnalyzingAi)
                          ? null
                          : () => controller.pickAndProcessImage(
                                source: ImageSource.camera,
                              ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Scan Label'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fallback manual search button
              TextButton(
                onPressed: () => context.go(AppRoutes.search),
                child: const Text('Search Medication Database Manually'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
