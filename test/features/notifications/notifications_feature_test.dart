import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/features/notifications/domain/entities/notification_item.dart';
import 'package:fikraty/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:fikraty/features/notifications/data/models/notification_model.dart';
import 'package:fikraty/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:fikraty/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:fikraty/features/notifications/data/services/push_notification_service.dart';
import 'package:fikraty/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:fikraty/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:fikraty/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:fikraty/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:fikraty/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:fikraty/features/notifications/presentation/bloc/notifications_state.dart';

void main() {
  group('NotificationModel & FCM Payload Parsing', () {
    test('parses standard JSON correctly', () {
      final json = {
        'id': '101',
        'title': 'Test Title',
        'subtitle': 'Test Subtitle',
        'timeAgo': '2m ago',
        'isUnread': true,
        'targetType': 'post',
        'targetId': 42,
        'chatUserName': 'Test User',
        'group': 'TODAY',
      };

      final model = NotificationModel.fromJson(json);
      expect(model.id, '101');
      expect(model.title, 'Test Title');
      expect(model.targetType, NotificationTargetType.post);
      expect(model.targetId, 42);
      expect(model.isUnread, isTrue);

      final outJson = model.toJson();
      expect(outJson['id'], '101');
      expect(outJson['targetType'], 'post');
    });

    test('parses FCM push payload with data block and target mapping', () {
      final fcmPayload = {
        'notification': {
          'title': 'FCM Title',
          'body': 'FCM Body Message',
        },
        'data': {
          'id': '999',
          'target_type': 'founder',
          'target_id': '15',
          'timeAgo': 'Just now',
          'group': 'TODAY',
        },
      };

      final model = NotificationModel.fromFcmPayload(fcmPayload);
      expect(model.id, '999');
      expect(model.title, 'FCM Title');
      expect(model.subtitle, 'FCM Body Message');
      expect(model.targetType, NotificationTargetType.founder);
      expect(model.targetId, 15);
      expect(model.isUnread, isTrue);
    });

    test('parses chat payload with sender details', () {
      final fcmPayload = {
        'data': {
          'id': '888',
          'title': 'New Message',
          'subtitle': 'Hey there!',
          'target_type': 'chat',
          'chat_user_name': 'Sarah',
          'chat_user_avatar': 'https://example.com/avatar.jpg',
        },
      };

      final model = NotificationModel.fromFcmPayload(fcmPayload);
      expect(model.targetType, NotificationTargetType.chat);
      expect(model.chatUserName, 'Sarah');
      expect(model.chatUserAvatar, 'https://example.com/avatar.jpg');
    });
  });

  group('Notifications Local Data Source & Disallowed Topics Check', () {
    late NotificationsLocalDataSource dataSource;

    setUp(() {
      dataSource = NotificationsLocalDataSourceImpl();
    });

    test('contains dummy data only for existing active features', () async {
      final items = await dataSource.getNotifications();
      expect(items, isNotEmpty);

      final disallowed = [
        'meeting',
        'due diligence',
        'investment phase',
        'phase',
      ];

      for (final item in items) {
        final fullText = '${item.title} ${item.subtitle}'.toLowerCase();
        for (final word in disallowed) {
          expect(
            fullText.contains(word),
            isFalse,
            reason: 'Item "${item.title}" contains disallowed keyword "$word"',
          );
        }
      }
    });

    test('marks single and all notifications as read', () async {
      final initial = await dataSource.getNotifications();
      expect(initial.any((n) => n.isUnread), isTrue);

      await dataSource.markAllAsRead();
      final updated = await dataSource.getNotifications();
      expect(updated.every((n) => !n.isUnread), isTrue);
    });
  });

  group('NotificationsBloc & Clean Architecture Pipeline', () {
    late NotificationsLocalDataSource localDataSource;
    late NotificationsRepository repository;
    late GetNotificationsUseCase getNotificationsUseCase;
    late MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
    late MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
    late PushNotificationService pushService;
    late NotificationsBloc bloc;

    setUp(() {
      localDataSource = NotificationsLocalDataSourceImpl();
      repository = NotificationsRepositoryImpl(localDataSource);
      getNotificationsUseCase = GetNotificationsUseCase(repository);
      markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(repository);
      markAllNotificationsAsReadUseCase =
          MarkAllNotificationsAsReadUseCase(repository);
      pushService = PushNotificationServiceImpl();

      bloc = NotificationsBloc(
        getNotificationsUseCase: getNotificationsUseCase,
        markNotificationAsReadUseCase: markNotificationAsReadUseCase,
        markAllNotificationsAsReadUseCase: markAllNotificationsAsReadUseCase,
        pushNotificationService: pushService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('emits Loaded state with unread count on LoadNotificationsEvent',
        () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotificationsLoading>(),
          isA<NotificationsLoaded>().having(
            (s) => s.hasUnread,
            'hasUnread',
            isTrue,
          ),
        ]),
      );

      bloc.add(const LoadNotificationsEvent());
    });

    test('MarkAllNotificationsAsReadEvent clears unreadCount to 0', () async {
      bloc.add(const LoadNotificationsEvent());
      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

      bloc.add(const MarkAllNotificationsAsReadEvent());
      final state = await bloc.stream.firstWhere(
        (s) => s is NotificationsLoaded && s.unreadCount == 0,
      ) as NotificationsLoaded;

      expect(state.unreadCount, 0);
      expect(state.hasUnread, isFalse);
    });

    test('Receives push notification and updates unread badge immediately',
        () async {
      bloc.add(const LoadNotificationsEvent());
      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

      pushService.simulateIncomingFcmPayload({
        'notification': {
          'title': 'Live Push Notification',
          'body': 'This arrived via simulated FCM',
        },
        'data': {
          'id': 'fcm_123',
          'target_type': 'post',
          'target_id': '1',
        },
      });

      final state = await bloc.stream.firstWhere(
        (s) =>
            s is NotificationsLoaded &&
            s.notifications.any((n) => n.id == 'fcm_123'),
      ) as NotificationsLoaded;

      expect(state.notifications.first.id, 'fcm_123');
      expect(state.notifications.first.title, 'Live Push Notification');
      expect(state.hasUnread, isTrue);
    });
  });
}
