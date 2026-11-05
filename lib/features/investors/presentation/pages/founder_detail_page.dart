import 'package:flutter/material.dart';
import '../../../explore/domain/entities/explore_founder.dart';
import '../../../explore/presentation/pages/founder_detail_page.dart';
import '../../../home/domain/entities/post.dart';

class FounderDetailScreen extends StatelessWidget {
  final RecommendedFounder? founder;
  final ExploreFounder? exploreFounder;

  const FounderDetailScreen({
    super.key,
    this.founder,
    this.exploreFounder,
  });

  @override
  Widget build(BuildContext context) {
    final ef = exploreFounder ??
        ExploreFounder(
          id: founder?.id ?? 1,
          name: founder?.name ?? 'Sarah Al-Mansouri',
          role: founder?.role ?? 'Founder & CEO',
          startupName: founder?.startupName ?? 'NovaMed AI',
          avatarUrl: founder?.avatarUrl ??
              'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
          location: founder?.location ?? 'Dubai, UAE',
          skills: (founder?.skills != null && founder!.skills.isNotEmpty)
              ? founder!.skills
              : const ['AI/ML', 'HealthTech', 'Fundraising', 'GTM'],
          followers: 1200,
          isVerified: true,
          bio: (founder?.bio != null && founder!.bio.isNotEmpty)
              ? founder!.bio
              : 'Building AI diagnostics for MENA clinics. Stanford Medicine Research Fellow. \$2.4M Seed raised.',
          lookingFor: (founder?.lookingFor != null && founder!.lookingFor.isNotEmpty)
              ? founder!.lookingFor
              : 'Co-investors for Series A expansion',
        );

    return FounderDetailPage(founder: ef);
  }
}
