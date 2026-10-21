import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/auth.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How will you use Fikraty?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          title: 'Entrepreneur / Founder',
          subtitle:
              'Build your professional network, create a startup profile later, and connect with investors.',
          icon: Icons.rocket_launch_rounded,
          selected: value == UserRole.entrepreneur,
          onTap: () => onChanged(UserRole.entrepreneur),
        ),
        const SizedBox(height: 10),
        _RoleCard(
          title: 'Investor',
          subtitle:
              'Set your investment thesis, discover relevant startups, and manage your deal pipeline.',
          icon: Icons.trending_up_rounded,
          selected: value == UserRole.investor,
          onTap: () => onChanged(UserRole.investor),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            color: selected ? AppColors.selectionTint : AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? colors.primary : AppColors.tertiaryText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: selected ? colors.primary : AppColors.darkText,
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                      ),
                      child: const Icon(Icons.check, size: 12, color: AppColors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Build your professional network, create a startup profile later, and connect with investors.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.subtleText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
