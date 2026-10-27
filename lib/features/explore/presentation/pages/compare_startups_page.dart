import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';
import '../widgets/compare_startups_section.dart';
import 'startup_detail_page.dart';

class CompareStartupsPage extends StatelessWidget {
  const CompareStartupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Compare Startups',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ExploreBloc, ExploreState>(
        builder: (context, state) {
          if (state is ExploreLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ExploreLoadedState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: CompareStartupsSection(
                allCompanies: state.compareStartups,
                selectedIds: state.selectedCompareIds,
                onToggleCompany: (id) {
                  context
                      .read<ExploreBloc>()
                      .add(ToggleCompareStartupEvent(id));
                },
                onTapDetail: (id) {
                  final s = state.startups.firstWhere(
                    (item) => item.id == id,
                    orElse: () => state.startups.first,
                  );
                  final exploreBloc = context.read<ExploreBloc>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: exploreBloc,
                        child: StartupDetailPage(startup: s),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
