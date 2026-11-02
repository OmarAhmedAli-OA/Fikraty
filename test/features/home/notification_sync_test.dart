import 'package:fikraty/features/home/data/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    // Reset service state before each test
    // NotificationService is a singleton; we can test initial state and operations
  });

  test('NotificationService starts with unread notifications', () {
    final service = NotificationService.instance;
    expect(service.notifications, isNotEmpty);
    expect(service.notifications.any((n) => n.group == 'TODAY'), isTrue);
  });

  test('NotificationService only contains features that are currently implemented', () {
    final service = NotificationService.instance;
    final disallowedKeywords = [
      'meeting',
      'due diligence',
      'investment phase',
      'phase',
    ];

    for (final notif in service.notifications) {
      final combined = '${notif.title} ${notif.subtitle}'.toLowerCase();
      for (final keyword in disallowedKeywords) {
        expect(
          combined.contains(keyword),
          isFalse,
          reason: 'Notification "${notif.title}" contains disallowed keyword "$keyword"',
        );
      }
    }
  });

  test('markAllAsRead clears unread count and hasUnread becomes false', () {
    final service = NotificationService.instance;
    expect(service.notifications, isNotEmpty);

    service.markAllAsRead();
    expect(service.unreadCount, 0);
    expect(service.hasUnread, isFalse);
    expect(service.notifications.every((n) => !n.isUnread), isTrue);
  });

  test('Notification targets map only to valid feature entities', () {
    final service = NotificationService.instance;
    for (final notif in service.notifications) {
      expect(
        [
          NotificationTargetType.post,
          NotificationTargetType.startup,
          NotificationTargetType.founder,
          NotificationTargetType.investor,
          NotificationTargetType.campaign,
          NotificationTargetType.chat,
        ].contains(notif.targetType),
        isTrue,
      );
    }
  });
}
