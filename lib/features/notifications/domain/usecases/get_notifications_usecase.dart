import '../entities/notification_item.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationItem>> call() {
    return repository.getNotifications();
  }
}
