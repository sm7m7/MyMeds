import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/label_reader/data/services/llm_label_parser_service.dart';
import 'package:my_meds/features/label_reader/data/services/mlkit_ocr_service.dart';
import 'package:my_meds/features/label_reader/domain/services/label_parser_service.dart';
import 'package:my_meds/features/label_reader/domain/services/ocr_service.dart';
import 'package:my_meds/features/label_reader/presentation/controllers/label_reader_controller.dart';

/// Provider for OCR service.
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = MlKitOcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for AI Label Parser service.
final labelParserServiceProvider = Provider<LabelParserService>((ref) {
  return LlmLabelParserService();
});

/// Provider for the [LabelReaderController].
final labelReaderControllerProvider =
    StateNotifierProvider<LabelReaderController, LabelReaderState>((ref) {
  final ocr = ref.watch(ocrServiceProvider);
  final parser = ref.watch(labelParserServiceProvider);
  return LabelReaderController(
    ocrService: ocr,
    parserService: parser,
  );
});
