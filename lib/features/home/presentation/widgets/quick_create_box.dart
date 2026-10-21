import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/feed_bloc.dart';
import '../pages/create_post_page.dart';

class QuickCreateBox extends StatelessWidget {
  const QuickCreateBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Current user avatar
          ClipOval(
            child: Image.network(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.purpleLight,
                child: Icon(Icons.person, color: AppColors.primaryPurple),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Clickable prompt pill
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<FeedBloc>(),
                      child: const CreatePostPage(),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Light grayish slate
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Share a startup update...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
