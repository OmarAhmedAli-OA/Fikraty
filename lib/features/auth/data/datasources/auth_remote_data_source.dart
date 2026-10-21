import '../../domain/entities/auth.dart';

/// In-memory development source only. It is intentionally not a production
/// identity provider and loses all accounts when the app process restarts.
/// Replace it with the ASP.NET API before release.
abstract interface class AuthRemoteDataSource {
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> signUp(RegistrationData data);
  Future<void> requestPasswordReset(String email);
  Future<void> signOut();
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource() {
    _seedDefaultAccounts();
  }

  final Map<String, ({String password, AuthUser user})> _accounts = {};
  AuthUser? _currentUser;
  int _nextId = 1;

  void _seedDefaultAccounts() {
    // Demo Entrepreneur account (Sarah)
    const sarahProfile = UserProfileData(
      fullName: 'Sarah Al-Mansouri',
      professionalTitle: 'Product Lead & Founder',
      bio: 'Building next-generation enterprise and AI tools. Passionate about empowering founders across the MENA ecosystem.',
      location: 'Dubai, UAE',
      linkedinUrl: 'https://linkedin.com/in/sarah-almansouri',
      expertise: ['Product', 'Engineering', 'Leadership', 'Fundraising'],
    );
    final sarahUser = AuthUser(
      id: 'demo-founder-1',
      email: 'sarah@startup.com',
      role: UserRole.entrepreneur,
      profile: sarahProfile,
      phone: '01012345678',
    );
    _accounts['sarah@startup.com'] = (password: 'password123', user: sarahUser);

    // Demo Investor account (Omar)
    const omarProfile = UserProfileData(
      fullName: 'Omar Farooq',
      professionalTitle: 'Partner at Oasis Ventures',
      bio: 'Early-stage tech investor targeting high-impact FinTech, HealthTech, and AI startups.',
      location: 'Cairo, Egypt',
      linkedinUrl: 'https://linkedin.com/in/omar-farooq',
    );
    const omarThesis = InvestorRegistrationData(
      firmName: 'Oasis Ventures',
      investorType: 'Venture Capital',
      thesis: 'FinTech and AI early stage with solid traction.',
      ticketSize: r'$50K – $250K',
      preferredIndustries: [
        LookupSelection(code: 'fintech', label: 'FinTech'),
        LookupSelection(code: 'ai-ml', label: 'AI / ML'),
      ],
      preferredCountries: [
        LookupSelection(code: 'SA', label: 'Saudi Arabia'),
        LookupSelection(code: 'AE', label: 'UAE'),
        LookupSelection(code: 'EG', label: 'Egypt'),
      ],
      preferredStages: [
        LookupSelection(code: 'Seed', label: 'Seed'),
        LookupSelection(code: 'Series A', label: 'Series A'),
      ],
    );
    final omarUser = AuthUser(
      id: 'demo-investor-1',
      email: 'omar@investor.com',
      role: UserRole.investor,
      profile: omarProfile,
      phone: '01198765432',
      investor: omarThesis,
    );
    _accounts['omar@investor.com'] = (password: 'password123', user: omarUser);
  }

  /// Exposed for prototype tests/debugging only; never use this as server auth.
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const AuthDataException('Enter your email and password.');
    }
    final account = _accounts[normalizedEmail];
    if (account == null || account.password != password) {
      throw const AuthDataException('Email or password is incorrect.');
    }
    _currentUser = account.user;
    return account.user;
  }

  @override
  Future<AuthUser> signUp(RegistrationData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final email = data.email.trim().toLowerCase();
    if (data.profile.fullName.trim().isEmpty || email.isEmpty || data.password.length < 8) {
      throw const AuthDataException('Please check the required account information.');
    }
    if (_accounts.containsKey(email)) {
      throw const AuthDataException('An account with this email already exists.');
    }
    final normalizedPhone = data.phone?.trim();
    if (normalizedPhone != null &&
        normalizedPhone.isNotEmpty &&
        _accounts.values.any((account) => account.user.phone == normalizedPhone)) {
      throw const AuthDataException('An account with this phone number already exists.');
    }
    if (data.role == UserRole.investor && data.investor == null) {
      throw const AuthDataException('Investor profile information is required.');
    }
    if (data.role == UserRole.entrepreneur && data.investor != null ||
        data.role == UserRole.investor && data.startup != null) {
      throw const AuthDataException('Registration data does not match the selected role.');
    }

    // Startup is optional during signup (can be completed in Member 3's startup wizard).
    // If provided, validate it.
    if (data.role == UserRole.entrepreneur && data.startup != null) {
      final startup = data.startup!;
      if (startup.name.trim().isEmpty ||
          startup.industry.code.trim().isEmpty ||
          startup.stage.code.trim().isEmpty) {
        throw const AuthDataException(
          'Entrepreneurs must provide a valid startup name, industry, and stage.',
        );
      }
      if (startup.foundedYear != null &&
          (startup.foundedYear! < 1800 || startup.foundedYear! > DateTime.now().year)) {
        throw const AuthDataException('Enter a valid startup founding year.');
      }
    }

    if (data.role == UserRole.investor && data.investor != null) {
      final investor = data.investor!;
      if ((investor.ticketMin != null || investor.ticketMax != null) &&
          investor.currency == null &&
          investor.ticketSize == null) {
        throw const AuthDataException('Select a currency for the investment range.');
      }
      if (investor.ticketMin != null && investor.ticketMin! < 0 ||
          investor.ticketMax != null && investor.ticketMax! < 0) {
        throw const AuthDataException('Investment amounts cannot be negative.');
      }
      if (investor.ticketMin != null &&
          investor.ticketMax != null &&
          investor.ticketMin! > investor.ticketMax!) {
        throw const AuthDataException('Minimum investment cannot exceed maximum investment.');
      }
    }

    final profile = UserProfileData(
      fullName: data.profile.fullName.trim(),
      headline: data.profile.headline,
      professionalTitle: data.profile.professionalTitle,
      bio: data.profile.bio,
      cityCode: data.profile.cityCode,
      location: data.profile.location,
      websiteUrl: data.profile.websiteUrl,
      linkedinUrl: data.profile.linkedinUrl,
      twitterUrl: data.profile.twitterUrl,
      expertise: data.profile.expertise,
      idDocumentName: data.profile.idDocumentName,
      idDocumentUrl: data.profile.idDocumentUrl,
    );

    final user = AuthUser(
      id: 'prototype-user-${_nextId++}',
      email: email,
      role: data.role,
      profile: profile,
      phone: normalizedPhone == null || normalizedPhone.isEmpty ? null : normalizedPhone,
      startup: data.startup,
      investor: data.investor,
    );

    _accounts[email] = (password: data.password, user: user);
    _currentUser = user;
    return user;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

class AuthDataException implements Exception {
  const AuthDataException(this.message);
  final String message;
  @override
  String toString() => message;
}
