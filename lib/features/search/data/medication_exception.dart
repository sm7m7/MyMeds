/// Exception thrown during medication fetching and search operations.
class MedicationException implements Exception {
  const MedicationException(this.message, {this.cause, this.isOffline = false});

  final String message;
  final dynamic cause;
  final bool isOffline;

  @override
  String toString() => message;
}
