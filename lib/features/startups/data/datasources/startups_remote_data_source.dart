import '../models/startups_model.dart';

abstract interface class StartupsDataSource {
  Future<StartupModel?> getMyStartup();
  Future<StartupModel> saveStartup(StartupModel startup);
  Future<void> submitVerification({
    required String startupId,
    required String documentType,
    required String registrationNumber,
    String? note,
  });
}

class StartupsLocalDataSourceImpl implements StartupsDataSource {
  static final StartupsLocalDataSourceImpl _instance =
      StartupsLocalDataSourceImpl._internal();

  factory StartupsLocalDataSourceImpl() => _instance;

  StartupsLocalDataSourceImpl._internal() {
    // Initially null so founder sees the "Create your startup profile" flow
    _currentStartup = null;
  }

  StartupModel? _currentStartup;

  @override
  Future<StartupModel?> getMyStartup() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _currentStartup;
  }

  @override
  Future<StartupModel> saveStartup(StartupModel startup) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentStartup = startup;
    return _currentStartup!;
  }

  @override
  Future<void> submitVerification({
    required String startupId,
    required String documentType,
    required String registrationNumber,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_currentStartup != null && _currentStartup!.id == startupId) {
      _currentStartup = StartupModel.fromEntity(
        _currentStartup!.copyWith(
          verificationStatus: 'pending',
          profileCompletion: 95,
        ),
      );
    }
  }
}
