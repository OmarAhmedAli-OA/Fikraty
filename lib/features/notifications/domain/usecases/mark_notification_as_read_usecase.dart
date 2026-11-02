import '../repositories/notifications_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<void> call(String id) {
    return repository.markAsRead(id);
  }
}
