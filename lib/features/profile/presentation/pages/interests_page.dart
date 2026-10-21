import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/interest_item.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/interest_card.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  InterestDirection _currentDirection = InterestDirection.received;

  @override
  void initState() {
    super.initState();
    // Ensure interests for currently selected direction are loaded
    context
        .read<ProfileBloc>()
        .add(LoadInterestsEvent(direction: _currentDirection));
  }

  void _switchDirection(InterestDirection dir) {
    if (_currentDirection == dir) return;
    setState(() => _currentDirection = dir);
    context.read<ProfileBloc>().add(LoadInterestsEvent(direction: dir));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoadedState && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! ProfileLoadedState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final interests = state.interests;
        final pendingCount =
            interests.where((i) => i.status == InterestStatus.pending).length;

        return Scaffold(
          backgroundColor: AppColors.grayBackground,
          appBar: AppBar(
            title: const Text('Interests'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Direction Toggle Tabs (Received vs Sent)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _DirectionTab(
                        label: 'Received',
                        count: _currentDirection == InterestDirection.received
                            ? interests.length
                            : pendingCount + 2,
                        isActive:
                            _currentDirection == InterestDirection.received,
                        onTap: () =>
                            _switchDirection(InterestDirection.received),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DirectionTab(
                        label: 'Sent',
                        count: _currentDirection == InterestDirection.sent
                            ? interests.length
                            : 3,
                        isActive: _currentDirection == InterestDirection.sent,
                        onTap: () => _switchDirection(InterestDirection.sent),
                      ),
                    ),
                  ],
                ),
              ),

              // Interest Items List
              Expanded(
                child: interests.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.inbox_outlined,
                        title: _currentDirection == InterestDirection.received
                            ? 'No received interests yet'
                            : 'No sent interests yet',
                        description: _currentDirection ==
                                InterestDirection.received
                            ? 'When investors express interest in your startup, they will appear here.'
                            : 'Explore startups and founders to connect and express interest.',
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        itemCount: interests.length,
                        itemBuilder: (context, index) {
                          final item = interests[index];
                          return InterestCard(
                            item: item,
                            onAccept: () {
                              context.read<ProfileBloc>().add(
                                    UpdateInterestStatusEvent(
                                      interestId: item.id,
                                      newStatus: InterestStatus.accepted,
                                    ),
                                  );
                            },
                            onDecline: () {
                              context.read<ProfileBloc>().add(
                                    UpdateInterestStatusEvent(
                                      interestId: item.id,
                                      newStatus: InterestStatus.declined,
                                    ),
                                  );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DirectionTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _DirectionTab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.grayBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
