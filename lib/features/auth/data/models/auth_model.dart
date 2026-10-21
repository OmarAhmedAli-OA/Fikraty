import '../../domain/entities/auth.dart';

/// DTO describing the database-shaped registration request expected by the
/// future ASP.NET API. Lookup codes must be resolved server-side to FK IDs.
/// Password is included only as a registration input for HTTPS transport; it is
/// never a profile field and must be hashed by the backend, never logged.
class RegistrationRequestModel {
  const RegistrationRequestModel(this.data);
  final RegistrationData data;

  Map<String, Object?> toApiJson() => {
        'email': data.email.trim().toLowerCase(),
        'phone': _nullable(data.phone),
        'password': data.password,
        'role': data.role.name,
        'profile': {
          'full_name': data.profile.fullName.trim(),
          'headline': _nullable(data.profile.headline),
          'professional_title': _nullable(data.profile.professionalTitle),
          'bio': _nullable(data.profile.bio),
          'city_code': _nullable(data.profile.cityCode),
          'website_url': _nullable(data.profile.websiteUrl),
          'linkedin_url': _nullable(data.profile.linkedinUrl),
          'twitter_url': _nullable(data.profile.twitterUrl),
        },
        if (data.role == UserRole.entrepreneur && data.startup != null)
          'startup': {
            'name': data.startup!.name.trim(),
            'industry_code': data.startup!.industry.code,
            'stage_code': data.startup!.stage.code,
            'tagline': _nullable(data.startup!.tagline),
            'description': _nullable(data.startup!.description),
            'problem': _nullable(data.startup!.problem),
            'solution': _nullable(data.startup!.solution),
            'business_model': _nullable(data.startup!.businessModel),
            'target_market': _nullable(data.startup!.targetMarket),
            'city_code': _nullable(data.startup!.cityCode),
            'website_url': _nullable(data.startup!.websiteUrl),
            'demo_url': _nullable(data.startup!.demoUrl),
            'founded_year': data.startup!.foundedYear,
          },
        if (data.role == UserRole.investor && data.investor != null)
          'investor_profile': {
            'firm_name': _nullable(data.investor!.firmName),
            'investor_type': _nullable(data.investor!.investorType),
            'thesis': _nullable(data.investor!.thesis),
            'ticket_min': data.investor!.ticketMin,
            'ticket_max': data.investor!.ticketMax,
            'currency_code': data.investor!.currency?.code,
            'risk_preference': data.investor!.riskPreference?.name,
            'provides_smart_money': data.investor!.providesSmartMoney,
            'provides_debt': data.investor!.providesDebt,
            'preferred_industry_codes':
                data.investor!.preferredIndustries.map((e) => e.code).toList(),
            'preferred_country_codes':
                data.investor!.preferredCountries.map((e) => e.code).toList(),
            'preferred_stage_codes':
                data.investor!.preferredStages.map((e) => e.code).toList(),
          },
      };

  static String? _nullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.profile,
    super.phone,
    super.accountStatus,
    super.emailConfirmed,
    super.startup,
    super.investor,
  });

  factory AuthUserModel.fromEntity(AuthUser user) => AuthUserModel(
        id: user.id,
        email: user.email,
        role: user.role,
        profile: user.profile,
        phone: user.phone,
        accountStatus: user.accountStatus,
        emailConfirmed: user.emailConfirmed,
        startup: user.startup,
        investor: user.investor,
      );
}
