/// Failure object used across the app (mirrors your production `Failure`).
class Failure {
  final String errorDescription;
  final int? statusCode;
  final String? originalError;

  Failure({
    required this.errorDescription,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'Failure(errorDescription: $errorDescription, statusCode: $statusCode)';
}
