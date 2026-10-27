import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/explore_content_item.dart';
import '../../domain/entities/explore_event.dart';
import '../../domain/entities/explore_founder.dart';
import '../../domain/entities/explore_investor.dart';
import '../../domain/entities/explore_startup.dart';
import 'event_explore_card.dart';
import 'founder_explore_card.dart';
import 'investor_explore_card.dart';
import 'startup_explore_card.dart';

class SavedItemsSection extends StatelessWidget {
  const SavedItemsSection({
    super.key,
    required this.savedItems,
    required this.selectedCategory,
    required this.categories,
    required this.onSelectCategory,
    required this.onToggleSave,
    required this.onExpressInterest,
    required this.onToggleEventRegister,
    required this.onTapDetail,
  });

  final List<dynamic> savedItems;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onSelectCategory;
  final Function(String type, int id) onToggleSave;
  final Function(String type, int id) onExpressInterest;
  final ValueChanged<int> onToggleEventRegister;
  final Function(String type, int id) onTapDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pills row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onSelectCategory(cat),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.tertiaryText,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // List of items
        if (savedItems.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.selectionTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bookmark_outline_rounded,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No saved ${selectedCategory == 'All' ? 'items' : selectedCategory.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bookmark items while exploring to see them here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.tertiaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ...savedItems.map((item) {
            if (item is ExploreStartup) {
              return StartupExploreCard(
                startup: item,
                onToggleSave: () => onToggleSave('startup', item.id),
                onTapDetail: () => onTapDetail('startup', item.id),
              );
            }
            if (item is ExploreInvestor) {
              return InvestorExploreCard(
                investor: item,
                onToggleSave: () => onToggleSave('investor', item.id),
                onExpressInterest: () => onExpressInterest('investor', item.id),
                onTapDetail: () => onTapDetail('investor', item.id),
              );
            }
            if (item is ExploreFounder) {
              return FounderExploreCard(
                founder: item,
                onToggleSave: () => onToggleSave('founder', item.id),
                onExpressInterest: () => onExpressInterest('founder', item.id),
                onTapDetail: () => onTapDetail('founder', item.id),
              );
            }
            if (item is ExploreEvent) {
              return EventExploreCard(
                event: item,
                onToggleSave: () => onToggleSave('event', item.id),
                onToggleRegister: () => onToggleEventRegister(item.id),
                onTapDetail: () => onTapDetail('event', item.id),
              );
            }
            if (item is ExploreContentItem) {
              return _buildContentItemCard(item);
            }
            return const SizedBox.shrink();
          }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContentItemCard(ExploreContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.iconOrEmoji != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.selectionTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.iconOrEmoji!,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF5F5F72),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onToggleSave('content', item.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.bookmark,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
