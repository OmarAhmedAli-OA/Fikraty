import 'package:flutter/foundation.dart';
import '../../domain/entities/post.dart';

enum MessageType {
  text,
  image,
  voice,
  video,
  videoNote,
  document,
}

class StoryReplyInfo {
  final int storyId;
  final String storyImageUrl;
  final String storyCaption;
  final String storyAuthorName;
  final String storyAuthorAvatar;

  const StoryReplyInfo({
    required this.storyId,
    required this.storyImageUrl,
    required this.storyCaption,
    required this.storyAuthorName,
    required this.storyAuthorAvatar,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final DateTime createdAt;
  final StoryReplyInfo? storyReply;
  final MessageType messageType;
  final String? mediaUrl;
  final String? duration;
  final String? fileName;
  final String? reaction;
  final bool isEdited;
  final bool isDeletedForEveryone;
  final bool isDeletedForMe;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.createdAt,
    this.storyReply,
    this.messageType = MessageType.text,
    this.mediaUrl,
    this.duration,
    this.fileName,
    this.reaction,
    this.isEdited = false,
    this.isDeletedForEveryone = false,
    this.isDeletedForMe = false,
  });

  bool get canEdit =>
      isMe &&
      !isDeletedForEveryone &&
      !isDeletedForMe &&
      text.isNotEmpty &&
      DateTime.now().difference(createdAt).inMinutes < 15;

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isMe,
    String? time,
    DateTime? createdAt,
    StoryReplyInfo? storyReply,
    MessageType? messageType,
    String? mediaUrl,
    String? duration,
    String? fileName,
    String? reaction,
    bool clearReaction = false,
    bool? isEdited,
    bool? isDeletedForEveryone,
    bool? isDeletedForMe,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      storyReply: storyReply ?? this.storyReply,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      duration: duration ?? this.duration,
      fileName: fileName ?? this.fileName,
      reaction: clearReaction ? null : (reaction ?? this.reaction),
      isEdited: isEdited ?? this.isEdited,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      isDeletedForMe: isDeletedForMe ?? this.isDeletedForMe,
    );
  }
}

class ConversationItem {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unreadCount;
  final DateTime updatedAt;

  const ConversationItem({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  ConversationItem copyWith({
    String? lastMessage,
    String? time,
    bool? isOnline,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ConversationItem(
      id: id,
      name: name,
      avatar: avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatService {
  ChatService._internal() {
    _initInitialData();
  }

  static final ChatService instance = ChatService._internal();

  final List<ConversationItem> _conversations = [];
  final Map<String, List<ChatMessage>> _messagesByConversationId = {};

  late final ValueNotifier<List<ConversationItem>> conversationsNotifier =
      ValueNotifier<List<ConversationItem>>([]);

  void _initInitialData() {
    final now = DateTime.now();

    // 1. Tariq Hassan
    _conversations.add(
      ConversationItem(
        id: 'user_tariq_hassan',
        name: 'Tariq Hassan',
        avatar:
            'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        lastMessage: '🎤 Voice message (0:18)',
        time: '1d ago',
        isOnline: true,
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    );
    _messagesByConversationId['user_tariq_hassan'] = [
      ChatMessage(
        id: 'm_th_1',
        text: 'Hi Omar! Reviewed your pitch deck, looks very promising.',
        isMe: false,
        time: 'Yesterday 10:30 AM',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessage(
        id: 'm_th_2',
        text: 'Sent you the co-investment term sheet.',
        isMe: false,
        time: 'Yesterday 11:15 AM',
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      ChatMessage(
        id: 'm_th_3',
        text: '',
        isMe: false,
        time: '1d ago',
        createdAt: now.subtract(const Duration(days: 1)),
        messageType: MessageType.voice,
        duration: '0:18',
        mediaUrl: 'sample_voice',
      ),
    ];

    // 2. Ingrid Larsen
    _conversations.add(
      ConversationItem(
        id: 'user_ingrid_larsen',
        name: 'Ingrid Larsen',
        avatar:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        lastMessage: '📷 Seed round traction report',
        time: '5h ago',
        isOnline: false,
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
    );
    _messagesByConversationId['user_ingrid_larsen'] = [
      ChatMessage(
        id: 'm_il_1',
        text:
            'Congratulations on the round! Would love to explore syndicated opportunities with your team.',
        isMe: false,
        time: '6h ago',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      ChatMessage(
        id: 'm_il_2',
        text: 'Here is our regional health-tech benchmark for this quarter:',
        isMe: false,
        time: '5h ago',
        createdAt: now.subtract(const Duration(hours: 5)),
        messageType: MessageType.image,
        mediaUrl:
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
      ),
    ];

    // 3. Omar Khalil
    _conversations.add(
      ConversationItem(
        id: 'user_omar_khalil',
        name: 'Omar Khalil',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        lastMessage:
            'Looking forward to our call tomorrow. Can we move it 15 mins later?',
        time: '2:15 PM',
        isOnline: true,
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
    );
    _messagesByConversationId['user_omar_khalil'] = [
      ChatMessage(
        id: 'm_ok_1',
        text: 'Hey! Are we still on for the due-diligence review?',
        isMe: true,
        time: '1:45 PM',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
      ),
      ChatMessage(
        id: 'm_ok_2',
        text:
            'Looking forward to our call tomorrow. Can we move it 15 mins later?',
        isMe: false,
        time: '2:15 PM',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    // 4. NovaMed AI
    _conversations.add(
      ConversationItem(
        id: 'user_novamed_ai',
        name: 'NovaMed AI',
        avatar:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150',
        lastMessage:
            'Thanks for connecting! Let us know if you want to test our AI.',
        time: '2h ago',
        isOnline: true,
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
    );
    _messagesByConversationId['user_novamed_ai'] = [
      ChatMessage(
        id: 'm_nma_1',
        text: 'Thanks for connecting! Let us know if you want to test our AI.',
        isMe: false,
        time: '2h ago',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    // 5. GreenStack
    _conversations.add(
      ConversationItem(
        id: 'user_greenstack',
        name: 'GreenStack',
        avatar:
            'https://images.unsplash.com/photo-1509391365360-2e959784a276?w=150',
        lastMessage: 'Excited to share our clean solar tech roadmap!',
        time: 'Yesterday',
        isOnline: false,
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    );
    _messagesByConversationId['user_greenstack'] = [
      ChatMessage(
        id: 'm_gs_1',
        text: 'Excited to share our clean solar tech roadmap!',
        isMe: false,
        time: 'Yesterday',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    // 6. Wamda
    _conversations.add(
      ConversationItem(
        id: 'user_wamda',
        name: 'Wamda',
        avatar:
            'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=150',
        lastMessage: 'Check out our Q3 Venture Capital report.',
        time: '3d ago',
        isOnline: false,
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    );
    _messagesByConversationId['user_wamda'] = [
      ChatMessage(
        id: 'm_w_1',
        text: 'Check out our Q3 Venture Capital report.',
        isMe: false,
        time: '3d ago',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    // 7. FlowSync
    _conversations.add(
      ConversationItem(
        id: 'user_flowsync',
        name: 'FlowSync',
        avatar:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        lastMessage: 'Automated 100K workflows this month alone! 📈',
        time: '4d ago',
        isOnline: true,
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
    );
    _messagesByConversationId['user_flowsync'] = [
      ChatMessage(
        id: 'm_fs_1',
        text: 'Automated 100K workflows this month alone! 📈',
        isMe: false,
        time: '4d ago',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    conversationsNotifier.value = List.from(_conversations);
  }

  List<ConversationItem> getConversations() {
    return List.from(_conversations);
  }

  List<ChatMessage> getMessages(String conversationId) {
    return List<ChatMessage>.from(
      _messagesByConversationId[conversationId] ?? [],
    );
  }

  String getConversationIdByName(String name, {String? avatarUrl}) {
    final normalized =
        'user_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

    final existingIndex = _conversations.indexWhere(
      (c) => c.id == normalized || c.name.toLowerCase() == name.toLowerCase(),
    );

    if (existingIndex != -1) {
      return _conversations[existingIndex].id;
    }

    // Create new conversation
    final newConv = ConversationItem(
      id: normalized,
      name: name,
      avatar: avatarUrl ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      lastMessage: 'Started conversation',
      time: 'Just now',
      isOnline: true,
      updatedAt: DateTime.now(),
    );
    _conversations.insert(0, newConv);
    _messagesByConversationId[normalized] = [];
    conversationsNotifier.value = List.from(_conversations);
    return normalized;
  }

  ConversationItem addStoryReply({
    required Story story,
    required String replyText,
  }) {
    final conversationId = getConversationIdByName(
      story.name,
      avatarUrl: story.avatarUrl,
    );

    final now = DateTime.now();
    final timeStr = _formatTime(now);

    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      text: replyText,
      isMe: true,
      time: timeStr,
      createdAt: now,
      storyReply: StoryReplyInfo(
        storyId: story.id,
        storyImageUrl: story.storyImageUrl,
        storyCaption: story.caption,
        storyAuthorName: story.name,
        storyAuthorAvatar: story.avatarUrl,
      ),
    );

    _messagesByConversationId[conversationId] ??= [];
    _messagesByConversationId[conversationId]!.add(newMsg);

    // Update conversation summary
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    final summary = 'Replied to story: $replyText';

    if (idx != -1) {
      final conv = _conversations.removeAt(idx);
      final updated = conv.copyWith(
        lastMessage: summary,
        time: 'Just now',
        updatedAt: now,
      );
      _conversations.insert(0, updated);
      conversationsNotifier.value = List.from(_conversations);
      return updated;
    } else {
      final newConv = ConversationItem(
        id: conversationId,
        name: story.name,
        avatar: story.avatarUrl,
        lastMessage: summary,
        time: 'Just now',
        isOnline: true,
        updatedAt: now,
      );
      _conversations.insert(0, newConv);
      conversationsNotifier.value = List.from(_conversations);
      return newConv;
    }
  }

  void sendMessage({
    required String conversationId,
    required String text,
  }) {
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      isMe: true,
      time: timeStr,
      createdAt: now,
    );

    _messagesByConversationId[conversationId] ??= [];
    _messagesByConversationId[conversationId]!.add(newMsg);

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final conv = _conversations.removeAt(idx);
      final updated = conv.copyWith(
        lastMessage: text,
        time: timeStr,
        updatedAt: now,
      );
      _conversations.insert(0, updated);
    }
    conversationsNotifier.value = List.from(_conversations);
  }

  void sendMediaMessage({
    required String conversationId,
    required MessageType type,
    required String mediaUrl,
    String? text,
    String? duration,
    String? fileName,
  }) {
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    String summaryText;
    switch (type) {
      case MessageType.image:
        summaryText = (text != null && text.isNotEmpty) ? '📷 $text' : '📷 Photo';
        break;
      case MessageType.voice:
        summaryText = '🎤 Voice message (${duration ?? "0:05"})';
        break;
      case MessageType.video:
        summaryText = (text != null && text.isNotEmpty) ? '🎥 $text' : '🎥 Video';
        break;
      case MessageType.videoNote:
        summaryText = '📹 Video note (${duration ?? "0:05"})';
        break;
      case MessageType.document:
        summaryText = '📄 ${fileName ?? "Document.pdf"}';
        break;
      case MessageType.text:
        summaryText = text ?? '';
        break;
    }

    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      text: text ?? '',
      isMe: true,
      time: timeStr,
      createdAt: now,
      messageType: type,
      mediaUrl: mediaUrl,
      duration: duration,
      fileName: fileName,
    );

    _messagesByConversationId[conversationId] ??= [];
    _messagesByConversationId[conversationId]!.add(newMsg);

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final conv = _conversations.removeAt(idx);
      final updated = conv.copyWith(
        lastMessage: summaryText,
        time: timeStr,
        updatedAt: now,
      );
      _conversations.insert(0, updated);
    }
    conversationsNotifier.value = List.from(_conversations);
  }

  void toggleReaction({
    required String conversationId,
    required String messageId,
    required String reactionEmoji,
  }) {
    final list = _messagesByConversationId[conversationId];
    if (list == null) return;

    final index = list.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = list[index];
      final newReaction = msg.reaction == reactionEmoji ? null : reactionEmoji;
      list[index] = msg.copyWith(
        reaction: newReaction,
        clearReaction: newReaction == null,
      );
    }
  }

  void removeReaction({
    required String conversationId,
    required String messageId,
  }) {
    final list = _messagesByConversationId[conversationId];
    if (list == null) return;

    final index = list.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = list[index];
      list[index] = msg.copyWith(clearReaction: true);
    }
  }

  bool editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  }) {
    final list = _messagesByConversationId[conversationId];
    if (list == null) return false;

    final index = list.indexWhere((m) => m.id == messageId);
    if (index == -1) return false;

    final msg = list[index];
    if (DateTime.now().difference(msg.createdAt).inMinutes >= 15) {
      return false;
    }
    if (!msg.isMe || msg.isDeletedForEveryone) {
      return false;
    }

    list[index] = msg.copyWith(
      text: newText,
      isEdited: true,
    );

    _updateConversationLastMessage(conversationId);
    return true;
  }

  void deleteMessageForEveryone({
    required String conversationId,
    required String messageId,
  }) {
    final list = _messagesByConversationId[conversationId];
    if (list == null) return;

    final index = list.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = list[index];
    list[index] = msg.copyWith(
      isDeletedForEveryone: true,
      text: 'This message was deleted',
      clearReaction: true,
    );

    _updateConversationLastMessage(conversationId);
  }

  void deleteMessageForMe({
    required String conversationId,
    required String messageId,
  }) {
    final list = _messagesByConversationId[conversationId];
    if (list == null) return;

    list.removeWhere((m) => m.id == messageId);
    _updateConversationLastMessage(conversationId);
  }

  void _updateConversationLastMessage(String conversationId) {
    final list = _messagesByConversationId[conversationId];
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    if (list == null || list.isEmpty) {
      final conv = _conversations[idx];
      _conversations[idx] = conv.copyWith(
        lastMessage: '',
      );
    } else {
      final lastMsg = list.last;
      String summary;
      if (lastMsg.isDeletedForEveryone) {
        summary = '🚫 This message was deleted';
      } else {
        switch (lastMsg.messageType) {
          case MessageType.image:
            summary = (lastMsg.text.isNotEmpty) ? '📷 ${lastMsg.text}' : '📷 Photo';
            break;
          case MessageType.voice:
            summary = '🎤 Voice message';
            break;
          case MessageType.video:
            summary = (lastMsg.text.isNotEmpty) ? '🎥 ${lastMsg.text}' : '🎥 Video';
            break;
          case MessageType.videoNote:
            summary = '📹 Video note';
            break;
          case MessageType.document:
            summary = '📄 ${lastMsg.fileName ?? "Document"}';
            break;
          case MessageType.text:
            summary = lastMsg.text;
            break;
        }
      }
      final conv = _conversations[idx];
      _conversations[idx] = conv.copyWith(
        lastMessage: summary,
        time: lastMsg.time,
      );
    }
    conversationsNotifier.value = List.from(_conversations);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
