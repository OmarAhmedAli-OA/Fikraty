import '../repositories/startups_repository.dart';

class SubmitStartupVerificationUseCase {
  const SubmitStartupVerificationUseCase(this._repository);

  final StartupsRepository _repository;

  Future<void> call({
    required String startupId,
    required String documentType,
    required String registrationNumber,
    String? note,
  }) {
    if (registrationNumber.trim().isEmpty) {
      throw ArgumentError('Official commercial registration or license number is required.');
    }
    return _repository.submitVerification(
      startupId: startupId,
      documentType: documentType,
      registrationNumber: registrationNumber,
      note: note,
    );
  }
}
