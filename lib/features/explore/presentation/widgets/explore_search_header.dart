import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExploreSearchHeader extends StatelessWidget {
  const ExploreSearchHeader({
    super.key,
    required this.searchController,
    required this.onQueryChanged,
    required this.onOpenFilter,
    required this.activeFilterCount,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onOpenFilter;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.tertiaryText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onQueryChanged,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search startups, investors, campaigns…',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.tertiaryText,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: false,
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            onQueryChanged('');
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.tertiaryText,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Filter Button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: onOpenFilter,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: activeFilterCount > 0
                            ? AppColors.primary
                            : AppColors.selectionTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: activeFilterCount > 0
                            ? AppColors.white
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  if (activeFilterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
