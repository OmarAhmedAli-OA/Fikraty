import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/domain/entities/user_profile.dart' as profile_model;
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import 'founder_analytics_page.dart';
import 'investor_analytics_page.dart';

class MyAnalyticsPage extends StatelessWidget {
  const MyAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect whether current user is an investor from AuthBloc first, with fallback to ProfileBloc
    final authUser = context.watch<AuthBloc>().state.user;
    bool isInvestor = false;
    if (authUser != null) {
      isInvestor = authUser.role == UserRole.investor;
    } else {
      try {
        final profileState = context.read<ProfileBloc>().state;
        if (profileState is ProfileLoadedState) {
          isInvestor =
              profileState.profile.role == profile_model.UserRole.investor;
        }
      } catch (_) {}
    }

    if (isInvestor) {
      return const InvestorAnalyticsPage();
    } else {
      return const FounderAnalyticsPage();
    }
  }
}
