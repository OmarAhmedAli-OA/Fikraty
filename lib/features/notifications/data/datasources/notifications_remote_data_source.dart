import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> fetchNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> registerFcmToken(String token);
}
