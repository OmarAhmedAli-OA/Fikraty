/// Roles supported by the Fikraty ERD. `admin` is intentionally not exposed
/// in public registration; it must only be assigned by trusted backend logic.
enum UserRole { entrepreneur, investor }

enum InvestorRiskPreference { low, medium, high }

enum AccountStatus { active, suspended, deactivated }

/// Lookup values are represented by stable codes in the Flutter prototype.
/// The API must resolve these codes to the numeric lookup IDs in the ERD
/// (industries.id, startup_stages.id, countries.id, currencies.id).
/// Do not send display labels or assume numeric IDs from client-side lists.
class LookupSelection {
  const LookupSelection({required this.code, required this.label});
  final String code;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is LookupSelection && other.code == code;
  @override
  int get hashCode => code.hashCode;
}

class UserProfileData {
  const UserProfileData({
    required this.fullName,
    this.headline,
    this.professionalTitle,
    this.bio,
    this.cityCode,
    this.location,
    this.websiteUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.expertise = const [],
    this.idDocumentName,
    this.idDocumentUrl,
  });

  final String fullName;
  final String? headline;
  final String? professionalTitle;
  final String? bio;
  final String? cityCode;
  final String? location;
  final String? websiteUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final List<String> expertise;
  final String? idDocumentName;
  final String? idDocumentUrl;
}

/// Required startup columns in the ERD are owner_user_id, name, slug,
/// industry_id and stage_id. Lookup codes are resolved by the API.
class StartupRegistrationData {
  const StartupRegistrationData({
    required this.name,
    required this.industry,
    required this.stage,
    this.tagline,
    this.description,
    this.problem,
    this.solution,
    this.businessModel,
    this.targetMarket,
    this.cityCode,
    this.websiteUrl,
    this.demoUrl,
    this.foundedYear,
  });

  final String name;
  final LookupSelection industry;
  final LookupSelection stage;
  final String? tagline;
  final String? description;
  final String? problem;
  final String? solution;
  final String? businessModel;
  final String? targetMarket;
  final String? cityCode;
  final String? websiteUrl;
  final String? demoUrl;
  final int? foundedYear;
}

/// Investor profile values mirror investor_profiles. The three preference
/// lists map to investor_industries, investor_countries and investor_stages.
class InvestorRegistrationData {
  const InvestorRegistrationData({
    this.firmName,
    this.investorType,
    this.thesis,
    this.ticketMin,
    this.ticketMax,
    this.ticketSize,
    this.currency,
    this.riskPreference,
    this.preferredIndustries = const [],
    this.preferredCountries = const [],
    this.preferredStages = const [],
    this.providesSmartMoney = false,
    this.providesDebt = false,
  });

  final String? firmName;
  final String? investorType;
  final String? thesis;
  final double? ticketMin;
  final double? ticketMax;
  final String? ticketSize;
  final LookupSelection? currency;
  final InvestorRiskPreference? riskPreference;
  final List<LookupSelection> preferredIndustries;
  final List<LookupSelection> preferredCountries;
  final List<LookupSelection> preferredStages;
  final bool providesSmartMoney;
  final bool providesDebt;
}

class RegistrationData {
  const RegistrationData({
    required this.email,
    required this.password,
    required this.role,
    this.phone,
    required this.profile,
    this.startup,
    this.investor,
  });

  final String email;
  /// Used only by the in-memory prototype. Never serialize this into a profile
  /// or log it; production password hashing belongs to the backend.
  final String password;
  final UserRole role;
  final String? phone;
  final UserProfileData profile;
  final StartupRegistrationData? startup;
  final InvestorRegistrationData? investor;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
    this.phone,
    this.accountStatus = AccountStatus.active,
    this.emailConfirmed = false,
    this.startup,
    this.investor,
  });

  /// Prototype ID. The production API returns the database `users.id`.
  final String id;
  final String email;
  final UserRole role;
  final UserProfileData profile;
  final String? phone;
  final AccountStatus accountStatus;
  final bool emailConfirmed;
  final StartupRegistrationData? startup;
  final InvestorRegistrationData? investor;

  String get displayName => profile.fullName;
}
