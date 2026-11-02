import '../../domain/entities/notification_item.dart';
import '../models/notification_model.dart';

abstract class NotificationsLocalDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> addNotification(NotificationModel notification);
}

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  final List<NotificationModel> _items = [
    const NotificationModel(
      id: '1',
      title: 'Tariq Al-Mansoor followed you',
      subtitle: 'Tariq Al-Mansoor started following your founder profile',
      timeAgo: '15m ago',
      isUnread: true,
      targetType: NotificationTargetType.founder,
      targetId: 1,
      group: 'TODAY',
    ),
    const NotificationModel(
      id: '2',
      title: 'New comment on your launch',
      subtitle: 'Sarah Jenkins commented on your Agritech Seed Round post',
      timeAgo: '1h ago',
      isUnread: true,
      targetType: NotificationTargetType.post,
      targetId: 1,
      group: 'TODAY',
    ),
    const NotificationModel(
      id: '3',
      title: 'Investor expressed interest',
      subtitle: 'Nour Capital showed interest in your AgriSense startup',
      timeAgo: '3h ago',
      isUnread: true,
      targetType: NotificationTargetType.startup,
      targetId: 1,
      group: 'TODAY',
    ),
    const NotificationModel(
      id: '4',
      title: 'New message from Karim Nour',
      subtitle: 'Can you share the latest deck and traction numbers?',
      timeAgo: '5h ago',
      isUnread: true,
      targetType: NotificationTargetType.chat,
      targetId: 1,
      chatUserName: 'Karim Nour',
      chatUserAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      group: 'TODAY',
    ),
    const NotificationModel(
      id: '5',
      title: 'Fahad Al-Otaibi followed your profile',
      subtitle: 'Fahad Al-Otaibi is now following your updates',
      timeAgo: 'Yesterday',
      isUnread: false,
      targetType: NotificationTargetType.investor,
      targetId: 1,
      group: 'YESTERDAY',
    ),
    const NotificationModel(
      id: '6',
      title: 'New backers in CleanTech Campaign',
      subtitle: 'Your SolarGrid campaign reached 85% of its funding goal',
      timeAgo: 'Yesterday',
      isUnread: false,
      targetType: NotificationTargetType.campaign,
      targetId: 1,
      group: 'YESTERDAY',
    ),
    const NotificationModel(
      id: '7',
      title: 'Post reached 100 likes',
      subtitle: 'Your update about the seed round milestone is trending',
      timeAgo: '3d ago',
      isUnread: false,
      targetType: NotificationTargetType.post,
      targetId: 2,
      group: 'THIS WEEK',
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return List<NotificationModel>.unmodifiable(_items);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _items.indexWhere((n) => n.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isUnread: false);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].isUnread) {
        _items[i] = _items[i].copyWith(isUnread: false);
      }
    }
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    _items.insert(0, notification);
  }
}
