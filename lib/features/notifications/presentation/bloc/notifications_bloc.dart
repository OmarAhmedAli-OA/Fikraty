import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../data/services/push_notification_service.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final PushNotificationService? pushNotificationService;
  StreamSubscription<NotificationItem>? _pushSubscription;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
    this.pushNotificationService,
  }) : super(const NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<PushNotificationReceivedEvent>(_onPushNotificationReceived);

    _pushSubscription =
        pushNotificationService?.onNotificationReceived.listen((notification) {
      add(PushNotificationReceivedEvent(notification));
    });
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      final items = await getNotificationsUseCase();
      final unread = items.where((n) => n.isUnread).length;
      emit(NotificationsLoaded(notifications: items, unreadCount: unread));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await markNotificationAsReadUseCase(event.id);
      if (state is NotificationsLoaded) {
        final current = (state as NotificationsLoaded).notifications;
        final updated = current.map((n) {
          if (n.id == event.id) {
            return n.copyWith(isUnread: false);
          }
          return n;
        }).toList();
        final unread = updated.where((n) => n.isUnread).length;
        emit(NotificationsLoaded(notifications: updated, unreadCount: unread));
      } else {
        add(const LoadNotificationsEvent());
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await markAllNotificationsAsReadUseCase();
      if (state is NotificationsLoaded) {
        final current = (state as NotificationsLoaded).notifications;
        final updated =
            current.map((n) => n.copyWith(isUnread: false)).toList();
        emit(NotificationsLoaded(notifications: updated, unreadCount: 0));
      } else {
        add(const LoadNotificationsEvent());
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onPushNotificationReceived(
    PushNotificationReceivedEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final current = (state as NotificationsLoaded).notifications;
      final updated = [event.notification, ...current];
      final unread = updated.where((n) => n.isUnread).length;
      emit(NotificationsLoaded(notifications: updated, unreadCount: unread));
    } else {
      add(const LoadNotificationsEvent());
    }
  }

  @override
  Future<void> close() {
    _pushSubscription?.cancel();
    return super.close();
  }
}
