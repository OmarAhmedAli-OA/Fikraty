import '../../domain/entities/startups.dart';
import '../../domain/repositories/startups_repository.dart';
import '../datasources/startups_remote_data_source.dart';
import '../models/startups_model.dart';

class StartupsRepositoryImpl implements StartupsRepository {
  StartupsRepositoryImpl({StartupsDataSource? dataSource})
      : _dataSource = dataSource ?? StartupsLocalDataSourceImpl();

  final StartupsDataSource _dataSource;

  @override
  Future<StartupEntity?> getMyStartup() {
    return _dataSource.getMyStartup();
  }

  @override
  Future<StartupEntity> saveStartup(StartupEntity startup) {
    final model = StartupModel.fromEntity(startup);
    return _dataSource.saveStartup(model);
  }

  @override
  Future<void> submitVerification({
    required String startupId,
    required String documentType,
    required String registrationNumber,
    String? note,
  }) {
    return _dataSource.submitVerification(
      startupId: startupId,
      documentType: documentType,
      registrationNumber: registrationNumber,
      note: note,
    );
  }
}
