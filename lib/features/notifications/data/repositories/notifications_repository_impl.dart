import 'dart:async';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsLocalDataSource localDataSource;
  final StreamController<List<NotificationItem>> _notificationsController =
      StreamController<List<NotificationItem>>.broadcast();

  NotificationsRepositoryImpl(this.localDataSource);

  @override
  Stream<List<NotificationItem>> get notificationsStream =>
      _notificationsController.stream;

  @override
  Future<List<NotificationItem>> getNotifications() async {
    final items = await localDataSource.getNotifications();
    _notificationsController.add(items);
    return items;
  }

  @override
  Future<void> markAsRead(String id) async {
    await localDataSource.markAsRead(id);
    final items = await localDataSource.getNotifications();
    _notificationsController.add(items);
  }

  @override
  Future<void> markAllAsRead() async {
    await localDataSource.markAllAsRead();
    final items = await localDataSource.getNotifications();
    _notificationsController.add(items);
  }

  void dispose() {
    _notificationsController.close();
  }
}
