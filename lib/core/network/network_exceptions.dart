class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.fieldErrors,
    this.lockedUntil,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, List<String>>? fieldErrors;
  final DateTime? lockedUntil;

  bool get isLocked => statusCode == 423;
  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 400;

  @override
  String toString() => message;
}
