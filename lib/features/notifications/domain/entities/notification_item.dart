enum NotificationTargetType {
  post,
  startup,
  investor,
  founder,
  campaign,
  chat,
}

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isUnread;
  final NotificationTargetType targetType;
  final int targetId;
  final String? chatUserName;
  final String? chatUserAvatar;
  final String group; // 'TODAY', 'YESTERDAY', 'THIS WEEK'

  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isUnread = false,
    required this.targetType,
    this.targetId = 0,
    this.chatUserName,
    this.chatUserAvatar,
    required this.group,
  });

  NotificationItem copyWith({
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
    return NotificationItem(
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
