import '../entities/notification_item.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Stream<List<NotificationItem>> get notificationsStream;
}
