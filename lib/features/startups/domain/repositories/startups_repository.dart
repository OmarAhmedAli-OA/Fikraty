import '../entities/startups.dart';

abstract interface class StartupsRepository {
  /// Returns the current entrepreneur's startup, or null if they haven't created one yet.
  Future<StartupEntity?> getMyStartup();

  /// Creates a new startup or updates the existing one.
  Future<StartupEntity> saveStartup(StartupEntity startup);

  /// Submits verification documents for the startup.
  Future<void> submitVerification({
    required String startupId,
    required String documentType,
    required String registrationNumber,
    String? note,
  });
}
