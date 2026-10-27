import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/explore_filter.dart';

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({
    super.key,
    required this.selectedStages,
    required this.selectedIndustries,
    required this.selectedLocations,
    required this.onToggleStage,
    required this.onToggleIndustry,
    required this.onToggleLocation,
    required this.onClearAll,
  });

  final List<String> selectedStages;
  final List<String> selectedIndustries;
  final List<String> selectedLocations;
  final ValueChanged<String> onToggleStage;
  final ValueChanged<String> onToggleIndustry;
  final ValueChanged<String> onToggleLocation;
  final VoidCallback onClearAll;

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late Set<String> _stages;
  late Set<String> _industries;
  late Set<String> _locations;

  @override
  void initState() {
    super.initState();
    _stages = Set<String>.from(widget.selectedStages);
    _industries = Set<String>.from(widget.selectedIndustries);
    _locations = Set<String>.from(widget.selectedLocations);
  }

  void _toggleStage(String stage) {
    setState(() {
      if (_stages.contains(stage)) {
        _stages.remove(stage);
      } else {
        _stages.add(stage);
      }
    });
    widget.onToggleStage(stage);
  }

  void _toggleIndustry(String ind) {
    setState(() {
      if (_industries.contains(ind)) {
        _industries.remove(ind);
      } else {
        _industries.add(ind);
      }
    });
    widget.onToggleIndustry(ind);
  }

  void _toggleLocation(String loc) {
    setState(() {
      if (_locations.contains(loc)) {
        _locations.remove(loc);
      } else {
        _locations.add(loc);
      }
    });
    widget.onToggleLocation(loc);
  }

  void _clearAll() {
    setState(() {
      _stages.clear();
      _industries.clear();
      _locations.clear();
    });
    widget.onClearAll();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _stages.length + _industries.length + _locations.length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title & Clear
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (activeCount > 0)
                TextButton(
                  onPressed: _clearAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Stage section
          _buildSectionHeader('STAGE'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExploreFilter.availableStages.map((stage) {
              final isSelected = _stages.contains(stage);
              return _buildFilterChip(
                label: stage,
                isSelected: isSelected,
                onTap: () => _toggleStage(stage),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Industry section
          _buildSectionHeader('INDUSTRY'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExploreFilter.availableIndustries.map((ind) {
              final isSelected = _industries.contains(ind);
              return _buildFilterChip(
                label: ind,
                isSelected: isSelected,
                onTap: () => _toggleIndustry(ind),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Location section
          _buildSectionHeader('LOCATION'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExploreFilter.availableLocations.map((loc) {
              final isSelected = _locations.contains(loc);
              return _buildFilterChip(
                label: loc,
                isSelected: isSelected,
                onTap: () => _toggleLocation(loc),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Show Results',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.tertiaryText,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}
