import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/explore_event.dart';

class EventExploreCard extends StatelessWidget {
  const EventExploreCard({
    super.key,
    required this.event,
    required this.onToggleSave,
    required this.onToggleRegister,
    required this.onTapDetail,
  });

  final ExploreEvent event;
  final VoidCallback onToggleSave;
  final VoidCallback onToggleRegister;
  final VoidCallback onTapDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Banner Image
          GestureDetector(
            onTap: onTapDetail,
            child: Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.background,
                      child: const Center(
                        child: Icon(Icons.event, size: 40, color: AppColors.tertiaryText),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.isFree ? 'Free' : '\$${event.price!.toInt()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.selectionTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.type,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Title & Save
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onTapDetail,
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onToggleSave,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        event.isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                        color: event.isSaved ? AppColors.primary : const Color(0xFFC0C0D0),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date & Attendees
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: AppColors.tertiaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.date} · ${event.time}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.people_outline_rounded,
                      size: 14,
                      color: AppColors.tertiaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.attendeesCount} attending',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom row: Organizer & Register CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By ${event.organizer}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiaryText,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onToggleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.isRegistered
                            ? const Color(0xFFE6FBF5)
                            : AppColors.primary,
                        foregroundColor: event.isRegistered
                            ? AppColors.secondary
                            : AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        event.isRegistered ? 'Registered ✓' : 'Register',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
