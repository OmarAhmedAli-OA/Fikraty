import '../repositories/notifications_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  final NotificationsRepository repository;

  MarkAllNotificationsAsReadUseCase(this.repository);

  Future<void> call() {
    return repository.markAllAsRead();
  }
}
