import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';

class PollWidget extends StatelessWidget {
  final Poll poll;
  final Function(int optionId) onVote;

  const PollWidget({
    super.key,
    required this.poll,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final hasVoted = poll.userVotedOptionId != null;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.poll_outlined,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  poll.question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Poll options
          ...poll.options.map((option) {
            final isSelected = poll.userVotedOptionId == option.id;
            final percentage = poll.totalVotes > 0
                ? (option.voteCount / poll.totalVotes) * 100
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  if (poll.userVotedOptionId != option.id) {
                    onVote(option.id);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 44,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : const Color(0xFFCBD5E1),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    color: AppColors.white,
                  ),
                  child: Stack(
                    children: [
                      // Progress bar fill when voted
                      if (hasVoted)
                        FractionallySizedBox(
                          widthFactor: (percentage / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryPurple.withValues(alpha: 0.15)
                                  : const Color(0xFFF1F5F9),
                            ),
                          ),
                        ),
                      // Text label and stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            if (isSelected) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryPurple,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                option.optionText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : AppColors.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasVoted)
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          // Total votes count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${poll.totalVotes} votes total',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hasVoted ? 'Tap option to change vote' : 'Tap an option to vote',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
