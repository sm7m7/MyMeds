/// Exception types that can occur during the OCR & AI label reading pipeline.
enum LabelReaderErrorType {
  noTextFound,
  blurryImage,
  apiFailure,
  permissionDenied,
  unknown;

  String get userFriendlyMessage {
    switch (this) {
      case LabelReaderErrorType.noTextFound:
        return 'No readable text was detected on the label. Please ensure the label is well-lit and in focus.';
      case LabelReaderErrorType.blurryImage:
        return 'The image appears blurry or obstructed. Please hold the camera steady and retry.';
      case LabelReaderErrorType.apiFailure:
        return 'AI label analysis service is temporarily unavailable. You can enter details manually or search our database.';
      case LabelReaderErrorType.permissionDenied:
        return 'Camera or photo library permission is required to scan medication labels.';
      case LabelReaderErrorType.unknown:
        return 'An unexpected error occurred during label scanning. Please try again.';
    }
  }
}

/// Exception thrown during the medication label recognition pipeline.
class LabelReaderException implements Exception {
  const LabelReaderException(
    this.message, {
    this.type = LabelReaderErrorType.unknown,
    this.cause,
  });

  final String message;
  final LabelReaderErrorType type;
  final dynamic cause;

  @override
  String toString() => message;
}
