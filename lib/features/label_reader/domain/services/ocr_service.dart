/// Contract for on-device optical character recognition (OCR).
abstract class OcrService {
  /// Extracts raw text from an image at [imagePath].
  ///
  /// Throws [LabelReaderException] if text recognition fails or no text is detected.
  Future<String> recognizeTextFromImagePath(String imagePath);

  /// Releases ML Kit text recognizer resources.
  void dispose();
}
