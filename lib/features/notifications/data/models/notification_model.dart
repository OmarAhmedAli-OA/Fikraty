import '../../domain/entities/notification_item.dart';

class NotificationModel extends NotificationItem {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.timeAgo,
    super.isUnread = false,
    required super.targetType,
    super.targetId = 0,
    super.chatUserName,
    super.chatUserAvatar,
    required super.group,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? 'Just now',
      isUnread: json['isUnread'] as bool? ?? false,
      targetType: _parseTargetType(json['targetType'] as String?),
      targetId: (json['targetId'] as num?)?.toInt() ?? 0,
      chatUserName: json['chatUserName'] as String?,
      chatUserAvatar: json['chatUserAvatar'] as String?,
      group: json['group'] as String? ?? 'TODAY',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'timeAgo': timeAgo,
      'isUnread': isUnread,
      'targetType': targetType.name,
      'targetId': targetId,
      if (chatUserName != null) 'chatUserName': chatUserName,
      if (chatUserAvatar != null) 'chatUserAvatar': chatUserAvatar,
      'group': group,
    };
  }

  /// Parses an incoming Firebase Cloud Messaging (FCM) remote payload.
  /// FCM payloads deliver key-value data strings in the data map or notification block.
  factory NotificationModel.fromFcmPayload(Map<String, dynamic> payload) {
    final data = (payload['data'] is Map<String, dynamic>)
        ? payload['data'] as Map<String, dynamic>
        : payload;

    final notificationBlock = (payload['notification'] is Map<String, dynamic>)
        ? payload['notification'] as Map<String, dynamic>
        : <String, dynamic>{};

    final title = data['title']?.toString() ??
        notificationBlock['title']?.toString() ??
        'New Notification';

    final subtitle = data['body']?.toString() ??
        data['subtitle']?.toString() ??
        notificationBlock['body']?.toString() ??
        '';

    final id = data['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final targetTypeStr =
        data['target_type']?.toString() ?? data['targetType']?.toString();
    final targetIdStr =
        data['target_id']?.toString() ?? data['targetId']?.toString();

    return NotificationModel(
      id: id,
      title: title,
      subtitle: subtitle,
      timeAgo: data['timeAgo']?.toString() ?? 'Just now',
      isUnread: true,
      targetType: _parseTargetType(targetTypeStr),
      targetId: int.tryParse(targetIdStr ?? '0') ?? 0,
      chatUserName: data['chat_user_name']?.toString() ??
          data['chatUserName']?.toString(),
      chatUserAvatar: data['chat_user_avatar']?.toString() ??
          data['chatUserAvatar']?.toString(),
      group: data['group']?.toString() ?? 'TODAY',
    );
  }

  static NotificationTargetType _parseTargetType(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'post':
        return NotificationTargetType.post;
      case 'startup':
        return NotificationTargetType.startup;
      case 'investor':
        return NotificationTargetType.investor;
      case 'founder':
        return NotificationTargetType.founder;
      case 'campaign':
        return NotificationTargetType.campaign;
      case 'chat':
      case 'message':
        return NotificationTargetType.chat;
      default:
        return NotificationTargetType.post;
    }
  }

  @override
  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? timeAgo,
    bool? isUnread,
    NotificationTargetType? targetType,
    int? targetId,
    String? chatUserName,
    String? chatUserAvatar,
    String? group,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      chatUserName: chatUserName ?? this.chatUserName,
      chatUserAvatar: chatUserAvatar ?? this.chatUserAvatar,
      group: group ?? this.group,
    );
  }
}
