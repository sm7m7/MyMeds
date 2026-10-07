import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:my_meds/features/label_reader/data/label_reader_exception.dart';
import 'package:my_meds/features/label_reader/domain/services/ocr_service.dart';

/// On-device OCR implementation using [google_mlkit_text_recognition].
class MlKitOcrService implements OcrService {
  MlKitOcrService({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> recognizeTextFromImagePath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _recognizer.processImage(inputImage);

      final text = recognizedText.text.trim();
      if (text.isEmpty || text.length < 3) {
        throw const LabelReaderException(
          'No readable text could be recognized from the medication label.',
          type: LabelReaderErrorType.noTextFound,
        );
      }

      return text;
    } on LabelReaderException {
      rethrow;
    } catch (e) {
      throw LabelReaderException(
        'Failed to process label image: $e',
        type: LabelReaderErrorType.blurryImage,
        cause: e,
      );
    }
  }

  @override
  void dispose() {
    _recognizer.close();
  }
}
