import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/auth.dart' as auth;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';
import '../widgets/campaign_explore_card.dart';
import '../widgets/compare_startups_section.dart';
import '../widgets/explore_filter_sheet.dart';
import '../widgets/explore_search_header.dart';
import '../widgets/founder_explore_card.dart';
import '../widgets/investor_explore_card.dart';
import '../widgets/saved_items_section.dart';
import '../widgets/startup_explore_card.dart';
import 'campaign_detail_page.dart';
import 'founder_detail_page.dart';
import 'investor_detail_page.dart';
import 'startup_detail_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<ExploreBloc>();
      return const _ExploreViewStateful();
    } catch (_) {
      return BlocProvider<ExploreBloc>(
        create: (ctx) {
          final authUser = ctx.read<AuthBloc>().state.user;
          final role = authUser?.role == auth.UserRole.investor
              ? 'investor'
              : 'entrepreneur';
          final bloc = sl<ExploreBloc>();
          bloc.add(const LoadExploreDataEvent());
          if (role == 'investor') {
            bloc.add(const SwitchRoleEvent('investor'));
          }
          return bloc;
        },
        child: const _ExploreViewStateful(),
      );
    }
  }
}

class _ExploreViewStateful extends StatefulWidget {
  const _ExploreViewStateful();

  @override
  State<_ExploreViewStateful> createState() => _ExploreViewStatefulState();
}

class _ExploreViewStatefulState extends State<_ExploreViewStateful> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context, ExploreLoadedState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExploreFilterSheet(
        selectedStages: state.selectedStages,
        selectedIndustries: state.selectedIndustries,
        selectedLocations: state.selectedLocations,
        onToggleStage: (stage) =>
            context.read<ExploreBloc>().add(ToggleFilterStageEvent(stage)),
        onToggleIndustry: (ind) =>
            context.read<ExploreBloc>().add(ToggleFilterIndustryEvent(ind)),
        onToggleLocation: (loc) =>
            context.read<ExploreBloc>().add(ToggleFilterLocationEvent(loc)),
        onClearAll: () =>
            context.read<ExploreBloc>().add(const ClearAllFiltersEvent()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            final targetRole = authState.user?.role == auth.UserRole.investor
                ? 'investor'
                : 'entrepreneur';
            final exploreState = context.read<ExploreBloc>().state;
            if (exploreState is ExploreLoadedState &&
                exploreState.userRole != targetRole) {
              context.read<ExploreBloc>().add(SwitchRoleEvent(targetRole));
            }
          },
        ),
        BlocListener<ExploreBloc, ExploreState>(
          listener: (context, state) {
            if (state is ExploreLoadedState && state.feedbackMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.feedbackMessage!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.darkText,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ExploreBloc, ExploreState>(
        builder: (context, state) {
          if (state is ExploreLoadingState) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (state is ExploreErrorState) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ExploreBloc>()
                              .add(const LoadExploreDataEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is ExploreLoadedState) {
            // Auto-sync role if it differs from current AuthBloc user role
            final authRole = context.read<AuthBloc>().state.user?.role ==
                    auth.UserRole.investor
                ? 'investor'
                : 'entrepreneur';
            if (state.userRole != authRole) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<ExploreBloc>().add(SwitchRoleEvent(authRole));
                }
              });
            }

            return _buildLoadedContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, ExploreLoadedState state) {
    final tabs = state.currentTabs;
    final resolvedTabIndex =
        state.selectedTabIndex.clamp(0, tabs.length - 1);
    final currentTab = tabs[resolvedTabIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header (No Role Switcher)
            ExploreSearchHeader(
              searchController: _searchController,
              onQueryChanged: (q) {
                context
                    .read<ExploreBloc>()
                    .add(SearchExploreQueryEvent(q));
              },
              onOpenFilter: () => _openFilterSheet(context, state),
              activeFilterCount: state.activeFiltersCount,
            ),

            // Horizontal Tab Bar
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final isSelected = resolvedTabIndex == i;
                    final tab = tabs[i];
                    return InkWell(
                      onTap: () {
                        context
                            .read<ExploreBloc>()
                            .add(ChangeExploreTabEvent(i));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.tertiaryText,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<ExploreBloc>().add(
                        const LoadExploreDataEvent(isRefresh: true),
                      );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildTabBody(context, state, currentTab),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(
    BuildContext context,
    ExploreLoadedState state,
    String currentTab,
  ) {
    final exploreBloc = context.read<ExploreBloc>();

    switch (currentTab) {
      case 'Startups':
        final list = state.filteredStartups;
        if (list.isEmpty) {
          return _buildEmptyFilterState('No startups match your search or filters.');
        }
        return Column(
          children: list.map((s) {
            return StartupExploreCard(
              startup: s,
              onToggleSave: () {
                context.read<ExploreBloc>().add(
                      ToggleBookmarkEvent(type: 'startup', id: s.id),
                    );
              },
              onTapDetail: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: exploreBloc,
                      child: StartupDetailPage(startup: s),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );

      case 'Investors':
        final list = state.filteredInvestors;
        if (list.isEmpty) {
          return _buildEmptyFilterState('No investors match your search or filters.');
        }
        return Column(
          children: list.map((inv) {
            return InvestorExploreCard(
              investor: inv,
              onToggleSave: () {
                context.read<ExploreBloc>().add(
                      ToggleBookmarkEvent(type: 'investor', id: inv.id),
                    );
              },
              onExpressInterest: () {
                context.read<ExploreBloc>().add(
                      ExpressInterestEvent(type: 'investor', id: inv.id),
                    );
              },
              onTapDetail: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: exploreBloc,
                      child: InvestorDetailPage(investor: inv),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );

      case 'Campaigns':
        final list = state.filteredCampaigns;
        if (list.isEmpty) {
          return _buildEmptyFilterState('No campaigns match your search or filters.');
        }
        return Column(
          children: list.map((c) {
            return CampaignExploreCard(
              campaign: c,
              onToggleSave: () {
                context.read<ExploreBloc>().add(
                      ToggleBookmarkEvent(type: 'campaign', id: c.id),
                    );
              },
              onExpressInterest: () {
                context.read<ExploreBloc>().add(
                      ExpressInterestEvent(type: 'campaign', id: c.id),
                    );
              },
              onTapDetail: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: exploreBloc,
                      child: CampaignDetailPage(campaign: c),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );

      case 'Founders':
        final list = state.filteredFounders;
        if (list.isEmpty) {
          return _buildEmptyFilterState('No founders match your search.');
        }
        return Column(
          children: list.map((f) {
            return FounderExploreCard(
              founder: f,
              onToggleSave: () {
                context.read<ExploreBloc>().add(
                      ToggleBookmarkEvent(type: 'founder', id: f.id),
                    );
              },
              onExpressInterest: () {
                context.read<ExploreBloc>().add(
                      ExpressInterestEvent(type: 'founder', id: f.id),
                    );
              },
              onTapDetail: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: exploreBloc,
                      child: FounderDetailPage(founder: f),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );

      case 'Compare':
        return CompareStartupsSection(
          allCompanies: state.compareStartups,
          selectedIds: state.selectedCompareIds,
          onToggleCompany: (id) {
            context.read<ExploreBloc>().add(
                  ToggleCompareStartupEvent(id),
                );
          },
          onTapDetail: (id) {
            final startup = state.startups.firstWhere(
              (s) => s.id == id,
              orElse: () => state.startups.first,
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: exploreBloc,
                  child: StartupDetailPage(startup: startup),
                ),
              ),
            );
          },
        );

      case 'Saved':
        return SavedItemsSection(
          savedItems: state.savedItemsList,
          selectedCategory: state.savedCategoryFilter,
          categories: ExploreLoadedState.savedCategories,
          onSelectCategory: (cat) {
            context.read<ExploreBloc>().add(
                  FilterSavedCategoryEvent(cat),
                );
          },
          onToggleSave: (type, id) {
            context.read<ExploreBloc>().add(
                  ToggleBookmarkEvent(type: type, id: id),
                );
          },
          onExpressInterest: (type, id) {
            context.read<ExploreBloc>().add(
                  ExpressInterestEvent(type: type, id: id),
                );
          },
          onToggleEventRegister: (eventId) {
            context.read<ExploreBloc>().add(
                  ToggleEventRegistrationEvent(eventId),
                );
          },
          onTapDetail: (type, id) {
            if (type == 'startup') {
              final s = state.startups.firstWhere((item) => item.id == id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: exploreBloc,
                    child: StartupDetailPage(startup: s),
                  ),
                ),
              );
            } else if (type == 'investor') {
              final inv = state.investors.firstWhere((item) => item.id == id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: exploreBloc,
                    child: InvestorDetailPage(investor: inv),
                  ),
                ),
              );
            } else if (type == 'founder') {
              final f = state.founders.firstWhere((item) => item.id == id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: exploreBloc,
                    child: FounderDetailPage(founder: f),
                  ),
                ),
              );
            }
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyFilterState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.selectionTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}
