import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_meds/features/label_reader/data/label_reader_exception.dart';
import 'package:my_meds/features/label_reader/domain/models/parsed_medication_label.dart';
import 'package:my_meds/features/label_reader/domain/services/label_parser_service.dart';
import 'package:my_meds/features/label_reader/domain/services/ocr_service.dart';

/// Pipeline execution state for the AI Label Reader.
sealed class LabelReaderState {
  const LabelReaderState();
}

class LabelReaderIdle extends LabelReaderState {
  const LabelReaderIdle();
}

class LabelReaderCapturing extends LabelReaderState {
  const LabelReaderCapturing();
}

class LabelReaderProcessingOcr extends LabelReaderState {
  const LabelReaderProcessingOcr({required this.imagePath});
  final String imagePath;
}

class LabelReaderAnalyzingAi extends LabelReaderState {
  const LabelReaderAnalyzingAi({
    required this.imagePath,
    required this.ocrText,
  });
  final String imagePath;
  final String ocrText;
}

class LabelReaderSuccess extends LabelReaderState {
  const LabelReaderSuccess({
    required this.parsedLabel,
    required this.imagePath,
  });
  final ParsedMedicationLabel parsedLabel;
  final String imagePath;
}

class LabelReaderError extends LabelReaderState {
  const LabelReaderError({
    required this.message,
    required this.type,
    this.imagePath,
  });
  final String message;
  final LabelReaderErrorType type;
  final String? imagePath;
}

/// Controller managing the complete Camera → OCR → AI Analysis → Confirmation pipeline.
class LabelReaderController extends StateNotifier<LabelReaderState> {
  LabelReaderController({
    required this.ocrService,
    required this.parserService,
    ImagePicker? imagePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        super(const LabelReaderIdle());

  final OcrService ocrService;
  final LabelParserService parserService;
  final ImagePicker _imagePicker;

  /// Captures an image via Camera or Gallery and triggers the processing pipeline.
  Future<void> pickAndProcessImage({required ImageSource source}) async {
    state = const LabelReaderCapturing();

    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (file == null) {
        // User cancelled image selection
        state = const LabelReaderIdle();
        return;
      }

      await processImagePath(file.path);
    } catch (e) {
      state = LabelReaderError(
        message: 'Could not access photo. Check camera/gallery permissions.',
        type: LabelReaderErrorType.permissionDenied,
        imagePath: null,
      );
    }
  }

  /// Runs OCR on [imagePath] and feeds extracted text into AI analysis.
  Future<void> processImagePath(String imagePath) async {
    // 1. OCR Step
    state = LabelReaderProcessingOcr(imagePath: imagePath);
    final String ocrText;

    try {
      ocrText = await ocrService.recognizeTextFromImagePath(imagePath);
    } on LabelReaderException catch (e) {
      state = LabelReaderError(
        message: e.message,
        type: e.type,
        imagePath: imagePath,
      );
      return;
    } catch (e) {
      state = LabelReaderError(
        message: 'Failed to read text from image. Make sure the label is clear.',
        type: LabelReaderErrorType.blurryImage,
        imagePath: imagePath,
      );
      return;
    }

    // 2. AI Analysis Step
    state = LabelReaderAnalyzingAi(imagePath: imagePath, ocrText: ocrText);

    try {
      final parsedLabel = await parserService.parseOcrText(ocrText);
      state = LabelReaderSuccess(
        parsedLabel: parsedLabel,
        imagePath: imagePath,
      );
    } on LabelReaderException catch (e) {
      state = LabelReaderError(
        message: e.message,
        type: e.type,
        imagePath: imagePath,
      );
    } catch (e) {
      state = LabelReaderError(
        message: 'AI analysis failed: $e',
        type: LabelReaderErrorType.apiFailure,
        imagePath: imagePath,
      );
    }
  }

  /// Resets state back to idle.
  void reset() {
    state = const LabelReaderIdle();
  }
}
