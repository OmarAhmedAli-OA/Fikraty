import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/chat_service.dart';
import 'chat_detail_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<ConversationItem>>(
        valueListenable: ChatService.instance.conversationsNotifier,
        builder: (context, conversations, _) {
          if (conversations.isEmpty) {
            return const Center(
              child: Text(
                'No messages yet',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: conversations.length,
            separatorBuilder: (_, _) =>
                const Divider(color: Color(0xFFF1F5F9), height: 1),
            itemBuilder: (context, index) {
              final item = conversations[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(
                        conversationId: item.id,
                        userName: item.name,
                        userAvatar: item.avatar,
                        isOnline: item.isOnline,
                        initialMessage: item.lastMessage,
                        initialTime: item.time,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: Image.network(
                              item.avatar,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.purpleLight,
                                child: Icon(Icons.person,
                                    color: AppColors.primaryPurple),
                              ),
                            ),
                          ),
                          if (item.isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981), // Online green
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  item.time,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: item.lastMessage.startsWith('Replied to story')
                                    ? AppColors.primaryPurple
                                    : AppColors.textMuted,
                                fontWeight:
                                    item.lastMessage.startsWith('Replied to story')
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
