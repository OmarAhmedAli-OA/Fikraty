import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/startups.dart';

class StartupMemberTile extends StatelessWidget {
  const StartupMemberTile({
    super.key,
    required this.member,
    this.onEditPressed,
    this.onDeletePressed,
  });

  final StartupMemberEntity member;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tint),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.tint,
            child: Text(
              member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isCofounder) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Co-founder',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.roleTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (member.bio != null && member.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.bio!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onEditPressed != null || onDeletePressed != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Color(0xFF6C5CE7), size: 20),
                    tooltip: 'Edit Member',
                    visualDensity: VisualDensity.compact,
                    onPressed: onEditPressed,
                  ),
                if (onDeletePressed != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 20),
                    tooltip: 'Remove Member',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDeletePressed,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
