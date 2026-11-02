import 'dart:async';
import '../models/notification_model.dart';

abstract class PushNotificationService {
  Future<void> initialize();
  Future<String?> getDeviceToken();
  Stream<NotificationModel> get onNotificationReceived;
  Stream<NotificationModel> get onNotificationOpenedApp;
  void simulateIncomingFcmPayload(Map<String, dynamic> payload);
}

class PushNotificationServiceImpl implements PushNotificationService {
  final StreamController<NotificationModel> _receivedController =
      StreamController<NotificationModel>.broadcast();
  final StreamController<NotificationModel> _openedController =
      StreamController<NotificationModel>.broadcast();

  final String _cachedToken = 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Future<void> initialize() async {
    // When Firebase Messaging is configured, standard FCM listeners:
    // FirebaseMessaging.onMessage.listen((msg) => ...)
    // FirebaseMessaging.onMessageOpenedApp.listen((msg) => ...)
    // will route their payloads through _receivedController & _openedController.
  }

  @override
  Future<String?> getDeviceToken() async {
    return _cachedToken;
  }

  @override
  Stream<NotificationModel> get onNotificationReceived =>
      _receivedController.stream;

  @override
  Stream<NotificationModel> get onNotificationOpenedApp =>
      _openedController.stream;

  @override
  void simulateIncomingFcmPayload(Map<String, dynamic> payload) {
    final model = NotificationModel.fromFcmPayload(payload);
    _receivedController.add(model);
  }

  void dispose() {
    _receivedController.close();
    _openedController.close();
  }
}
