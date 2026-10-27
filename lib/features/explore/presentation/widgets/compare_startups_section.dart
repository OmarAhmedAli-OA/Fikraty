import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/compare_startup_item.dart';

class CompareStartupsSection extends StatefulWidget {
  const CompareStartupsSection({
    super.key,
    required this.allCompanies,
    required this.selectedIds,
    required this.onToggleCompany,
    required this.onTapDetail,
  });

  final List<CompareStartupItem> allCompanies;
  final List<int> selectedIds;
  final ValueChanged<int> onToggleCompany;
  final ValueChanged<int> onTapDetail;

  @override
  State<CompareStartupsSection> createState() => _CompareStartupsSectionState();
}

class _CompareStartupsSectionState extends State<CompareStartupsSection> {
  bool _showPicker = false;

  @override
  Widget build(BuildContext context) {
    final shown = widget.allCompanies
        .where((c) => widget.selectedIds.contains(c.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selection chips row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: widget.allCompanies.map((c) {
              final isSelected = widget.selectedIds.contains(c.id);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => widget.onToggleCompany(c.id),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.selectionTint
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(c.colorHex),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              c.initials,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.darkText,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        if (shown.length < 2)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0A0)),
            ),
            child: const Text(
              'Select at least 2 startups above to compare.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFB07000),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Company header cards row
        Row(
          children: [
            const SizedBox(width: 80),
            ...shown.map((c) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(c.colorHex),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              c.initials,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => widget.onTapDetail(c.id),
                          child: const Text(
                            'View ↗',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),

        // Fikraty Score Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.selectionTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FIKRATY SCORE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiaryText,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                    width: 76,
                    child: Text(
                      'Overall',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...shown.map((c) => Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Text(
                                '${c.score}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (c.score / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Metrics Table Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(CompareStartupItem.metricLabels.length, (row) {
              final label = CompareStartupItem.metricLabels[row];
              final isLast = row == CompareStartupItem.metricLabels.length - 1;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.border),
                        ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 76,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ...shown.map((c) {
                      final val = c.metricValues[row];
                      // Highlight highest growth or raised
                      final isHighlight = (row == 4 && val.contains('31%')) ||
                          (row == 2 && val.contains('\$4.1M'));

                      return Expanded(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isHighlight)
                                const Text(
                                  '★ ',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              Flexible(
                                child: Text(
                                  val,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isHighlight
                                        ? AppColors.secondary
                                        : AppColors.darkText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // Add startup picker button
        if (shown.length < 3)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showPicker = !_showPicker),
              icon: Icon(
                _showPicker ? Icons.close : Icons.add_rounded,
                size: 18,
              ),
              label: Text(
                _showPicker ? 'Close Picker' : 'Add another startup (up to 3)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        if (_showPicker) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: widget.allCompanies.map((c) {
                final isAdded = widget.selectedIds.contains(c.id);
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(c.colorHex),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        c.initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  subtitle: Text(
                    '${c.industry} · ${c.stage} · Score ${c.score}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiaryText,
                    ),
                  ),
                  trailing: isAdded
                      ? const Chip(
                          label: Text(
                            'Added',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          backgroundColor: AppColors.selectionTint,
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        )
                      : TextButton(
                          onPressed: () {
                            widget.onToggleCompany(c.id);
                            if (widget.selectedIds.length >= 2) {
                              setState(() => _showPicker = false);
                            }
                          },
                          child: const Text('+ Add'),
                        ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
