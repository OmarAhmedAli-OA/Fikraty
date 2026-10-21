/// Reusable validation rules and constraint checkers for Fikraty.
///
/// Implements domain-driven validation for auth, founder profiles, investor
/// preferences, and identity verification.
library;

class PasswordRequirements {
  final bool hasMinLength;
  final bool hasMaxLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecialChar;
  final bool hasNoSurroundingWhitespace;

  const PasswordRequirements({
    required this.hasMinLength,
    required this.hasMaxLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
    required this.hasNoSurroundingWhitespace,
  });

  bool get isStrong =>
      hasMinLength &&
      hasMaxLength &&
      hasUppercase &&
      hasLowercase &&
      hasDigit &&
      hasSpecialChar &&
      hasNoSurroundingWhitespace;
}

abstract final class Validators {
  // Predefined supported values matching ERD and Figma design system
  static const List<String> defaultExpertiseOptions = [
    'Product',
    'Engineering',
    'Sales',
    'Marketing',
    'Finance',
    'Operations',
    'Fundraising',
    'Leadership',
  ];

  static const List<String> defaultSectorOptions = [
    'FinTech',
    'HealthTech',
    'EdTech',
    'AI / ML',
    'SaaS',
    'CleanTech',
    'Consumer',
    'Deep Tech',
  ];

  static const List<String> defaultCountryOptions = [
    'Egypt',
    'Saudi Arabia',
    'UAE',
    'Jordan',
    'Qatar',
    'Bahrain',
    'Kuwait',
    'Global',
  ];

  static const List<String> defaultStageOptions = [
    'Pre-seed',
    'Seed',
    'Series A',
    'Series B',
    'Growth',
  ];

  static const List<String> defaultTicketOptions = [
    r'$10K – $50K',
    r'$50K – $250K',
    r'$250K – $1M',
    r'$1M – $5M',
    r'$5M+',
  ];

  static const List<String> defaultCurrencyOptions = [
    r'USD ($) - US Dollar',
    'EGP (ج.م) - Egyptian Pound',
    'SAR (ر.س) - Saudi Riyal',
    'AED (د.إ) - UAE Dirham',
    'KWD (د.ك) - Kuwaiti Dinar',
    'QAR (ر.ق) - Qatari Riyal',
    'EUR (€) - Euro',
    'GBP (£) - British Pound',
  ];

  static const List<String> defaultRiskPreferenceOptions = [
    'Low',
    'Medium',
    'High',
  ];

  static const int maxIdFileSize = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedIdExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  // Allowed password special characters: !@#$%^&*(),.?":{}|<>
  static final RegExp _passwordSpecialCharPattern =
      RegExp(r'[!@#\$%\^&\*\(\),\.\?":{}|<>]');

  // Egyptian mobile regex: 010, 011, 012, 015 with 8 trailing digits.
  // Supports local 11 digits (01...) or international (+20 or 0020).
  static final RegExp _egyptianPhonePattern =
      RegExp(r'^(?:(?:\+20|0020)0?|0)1[0125][0-9]{8}$');

  // Full name whitelist: Arabic letters, English letters, spaces, hyphens, and apostrophes.
  // Rejects digits (0-9 and Arabic-Indic numerals), emoji, and symbols.
  static final RegExp _nameCharPattern =
      RegExp(r"^[a-zA-Z\u0600-\u06FF\s'-]+$");
  static final RegExp _digitPattern =
      RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]');

  // Common generic required text validator
  static String? requiredText(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  // =========================================================================
  // 1. EGYPTIAN MOBILE NUMBER VALIDATION
  // =========================================================================
  static const String egyptianPhoneErrorMessage =
      'Enter a valid Egyptian mobile number (010, 011, 012, or 015).';

  /// Validates Egyptian mobile numbers (010, 011, 012, 015).
  /// Normalizes formatting spaces, dashes, and parentheses.
  static String? egyptianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return egyptianPhoneErrorMessage;
    }
    final clean = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_egyptianPhonePattern.hasMatch(clean)) {
      return egyptianPhoneErrorMessage;
    }
    return null;
  }

  /// Normalizes an accepted Egyptian mobile number into standard 11-digit local format (01xxxxxxxxx).
  static String normalizeEgyptianPhone(String value) {
    final clean = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (clean.startsWith('+200')) {
      return '0${clean.substring(4)}';
    } else if (clean.startsWith('+20')) {
      return '0${clean.substring(3)}';
    } else if (clean.startsWith('00200')) {
      return '0${clean.substring(5)}';
    } else if (clean.startsWith('0020')) {
      return '0${clean.substring(4)}';
    }
    return clean;
  }

  // =========================================================================
  // 2. STRONG PASSWORD VALIDATION & LIVE CHECKLIST
  // =========================================================================
  /// Evaluates granular password requirements for real-time UI feedback.
  static PasswordRequirements checkPassword(String? value) {
    final pwd = value ?? '';
    final hasMinLength = pwd.length >= 8;
    final hasMaxLength = pwd.length <= 128 && pwd.isNotEmpty;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(pwd);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(pwd);
    final hasDigit = RegExp(r'[0-9]').hasMatch(pwd);
    final hasSpecialChar = _passwordSpecialCharPattern.hasMatch(pwd);
    final hasNoSurroundingWhitespace =
        pwd.isNotEmpty && !pwd.startsWith(' ') && !pwd.endsWith(' ');

    return PasswordRequirements(
      hasMinLength: hasMinLength,
      hasMaxLength: hasMaxLength,
      hasUppercase: hasUppercase,
      hasLowercase: hasLowercase,
      hasDigit: hasDigit,
      hasSpecialChar: hasSpecialChar,
      hasNoSurroundingWhitespace: hasNoSurroundingWhitespace,
    );
  }

  /// Comprehensive validator for new passwords at signup or reset.
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.startsWith(' ') || value.endsWith(' ')) {
      return 'Password cannot start or end with a space.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (value.length > 128) {
      return 'Password cannot exceed 128 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter (A-Z).';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter (a-z).';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number (0-9).';
    }
    if (!_passwordSpecialCharPattern.hasMatch(value)) {
      return r'Include at least one special character (!@#$%^&*(),.?":{}|<>).';
    }
    return null;
  }

  /// Basic password length validator for sign-in.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Use at least 8 characters.';
    if (value.length > 128) return 'Password cannot exceed 128 characters.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }

  // =========================================================================
  // 3. EMAIL VALIDATION
  // =========================================================================
  static const String emailErrorMessage =
      'Enter a valid email address (e.g. name@gmail.com).';

  static const String emailUnrecognizedDomainMessage =
      'Enter a valid email from a recognized provider (e.g. Gmail, Outlook, Hotmail, Yahoo, or university email).';

  /// Standard recognized email providers.
  static const Set<String> trustedEmailProviders = {
    'gmail.com',
    'outlook.com',
    'hotmail.com',
    'yahoo.com',
    'icloud.com',
    'live.com',
    'msn.com',
    'proton.me',
    'protonmail.com',
    'zoho.com',
  };

  /// Checks if the domain belongs to a recognized provider or an educational/university institution.
  static bool isRecognizedEmailDomain(String domain) {
    final lower = domain.toLowerCase();
    if (trustedEmailProviders.contains(lower)) {
      return true;
    }
    // Recognized university/academic domains (.edu, .edu.eg, .ac.uk, etc.)
    if (lower.endsWith('.edu') ||
        lower.endsWith('.edu.eg') ||
        RegExp(r'\.(?:edu|ac)\.[a-z]{2,}$').hasMatch(lower)) {
      return true;
    }
    return false;
  }

  /// Validates email syntax and ensures the domain belongs to a recognized provider or university.
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return emailErrorMessage;
    if (trimmed.length > 254) return emailErrorMessage;
    if (trimmed.contains(' ') || trimmed.contains('..')) {
      return emailErrorMessage;
    }

    final atIndex = trimmed.indexOf('@');
    if (atIndex <= 0 || atIndex != trimmed.lastIndexOf('@')) {
      return emailErrorMessage;
    }

    final localPart = trimmed.substring(0, atIndex);
    final domainPart = trimmed.substring(atIndex + 1).toLowerCase();

    if (localPart.isEmpty || localPart.length > 64) return emailErrorMessage;
    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return emailErrorMessage;
    }

    // RFC 5322 local part subset
    final validLocal = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+$");
    if (!validLocal.hasMatch(localPart)) return emailErrorMessage;

    if (domainPart.isEmpty || domainPart.length > 253) return emailErrorMessage;
    if (domainPart.startsWith('.') || domainPart.endsWith('.') || domainPart.startsWith('-') || domainPart.endsWith('-')) {
      return emailErrorMessage;
    }

    final domainLabels = domainPart.split('.');
    if (domainLabels.length < 2) return emailErrorMessage;

    final labelPattern = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$');
    for (final label in domainLabels) {
      if (label.isEmpty || label.length > 63 || !labelPattern.hasMatch(label)) {
        return emailErrorMessage;
      }
    }

    // Top Level Domain (TLD) must be letters only and at least 2 characters
    final tld = domainLabels.last;
    if (!RegExp(r'^[a-zA-Z]{2,}$').hasMatch(tld)) {
      return emailErrorMessage;
    }

    // Enforce recognized providers or university domains (reject random domains like ee.com)
    if (!isRecognizedEmailDomain(domainPart)) {
      return emailUnrecognizedDomainMessage;
    }

    return null;
  }

  // =========================================================================
  // 4. COMMON PROFILE FIELDS
  // =========================================================================
  /// Validates full name: 3-80 chars, >= 2 parts, Arabic/English letters, no digits/emoji.
  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Full name is required.';
    if (trimmed.length < 3) return 'Full name must be at least 3 characters.';
    if (trimmed.length > 80) return 'Full name cannot exceed 80 characters.';

    if (_digitPattern.hasMatch(trimmed) || !_nameCharPattern.hasMatch(trimmed)) {
      return 'Full name must contain letters only (Arabic or English).';
    }

    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) {
      return 'Please enter both your first and last name.';
    }

    final letterPattern = RegExp(r'[a-zA-Z\u0600-\u06FF]');
    for (final part in parts) {
      if (!letterPattern.hasMatch(part)) {
        return 'Each name part must contain letters.';
      }
    }

    return null;
  }

  /// Validates LinkedIn personal profile URL (HTTPS, linkedin.com or www.linkedin.com, /in/{profile}).
  static String? linkedInUrl(String? value, {bool isRequired = true}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isRequired ? 'LinkedIn profile URL is required.' : null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid LinkedIn URL (e.g. https://linkedin.com/in/username).';
    }

    if (uri.scheme.toLowerCase() != 'https') {
      return 'LinkedIn URL must use HTTPS (e.g. https://linkedin.com/in/username).';
    }

    final host = uri.host.toLowerCase();
    if (host != 'linkedin.com' && host != 'www.linkedin.com') {
      return 'URL must be a LinkedIn profile (e.g. https://linkedin.com/in/username).';
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 2 || segments[0].toLowerCase() != 'in' || segments[1].trim().isEmpty) {
      return 'Enter a valid personal profile URL (e.g. https://linkedin.com/in/username).';
    }

    final username = segments[1];
    if (!RegExp(r'^[a-zA-Z0-9_\-\.%]+$').hasMatch(username)) {
      return 'Enter a valid LinkedIn profile username.';
    }

    return null;
  }

  /// Validates location: required, 3-100 characters.
  static String? location(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Country / city of residence is required.';
    if (trimmed.length < 3) return 'Location must be at least 3 characters.';
    if (trimmed.length > 100) return 'Location cannot exceed 100 characters.';
    return null;
  }

  /// Validates Government ID document: optional at signup, allowed formats (JPG, PNG, PDF), max 5 MB.
  static String? governmentIdDocument(
    String? filename, {
    int? fileSizeBytes,
    bool isRequired = false,
  }) {
    if (filename == null || filename.trim().isEmpty) {
      return isRequired ? 'Government ID photo is required.' : null;
    }

    final cleanName = filename.trim().toLowerCase();
    final dotIndex = cleanName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == cleanName.length - 1) {
      return 'Allowed file formats are JPG, PNG, and PDF (max 5 MB).';
    }

    final extension = cleanName.substring(dotIndex + 1);
    if (!allowedIdExtensions.contains(extension)) {
      return 'Allowed file formats are JPG, PNG, and PDF (max 5 MB).';
    }

    if (fileSizeBytes != null && fileSizeBytes > maxIdFileSize) {
      return 'File size exceeds maximum allowed size of 5 MB.';
    }

    return null;
  }

  // =========================================================================
  // 5. FOUNDER / ENTREPRENEUR VALIDATION
  // =========================================================================
  /// Validates professional title: required, 2-80 characters.
  static String? professionalTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Current professional title is required.';
    if (trimmed.length < 2) return 'Professional title must be at least 2 characters.';
    if (trimmed.length > 80) return 'Professional title cannot exceed 80 characters.';
    return null;
  }

  /// Validates founder personal bio: required, 15-240 characters.
  static String? bio(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Personal bio is required.';
    if (trimmed.length < 15) return 'Bio must be at least 15 characters.';
    if (trimmed.length > 240) return 'Bio cannot exceed 240 characters.';
    return null;
  }

  /// Validates custom tags or entries entered via the "Other / More" option.
  /// Enforces non-empty, proper length bounds, character whitelist, and duplicate check.
  static String? customTag(
    String? value, {
    String fieldName = 'Custom entry',
    int minLength = 2,
    int maxLength = 50,
    Iterable<String>? existingOptions,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName is required.';
    }
    if (trimmed.length < minLength) {
      return '$fieldName must be at least $minLength characters.';
    }
    if (trimmed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters.';
    }

    // Allows Arabic/English letters, numbers, spaces, hyphens, en/em dashes, slashes, and common currency/math symbols
    final allowedPattern = RegExp(r"^[a-zA-Z\u0600-\u06FF0-9\s'/\-\u2013\u2014\+\$\.\,\(\)]+$");
    if (!allowedPattern.hasMatch(trimmed)) {
      return '$fieldName contains invalid characters (letters, numbers, and hyphens only).';
    }

    if (existingOptions != null) {
      final isDuplicate = existingOptions.any(
        (opt) => opt.trim().toLowerCase() == trimmed.toLowerCase(),
      );
      if (isDuplicate) {
        return '"$trimmed" already exists in the options.';
      }
    }

    return null;
  }

  /// Validates areas of expertise against predefined supported tags or valid custom tags.
  static String? founderExpertise(
    Iterable<String>? selected, [
    List<String> allowedOptions = defaultExpertiseOptions,
  ]) {
    if (selected == null || selected.isEmpty) {
      return 'Please select at least one area of expertise.';
    }
    for (final tag in selected) {
      if (!allowedOptions.contains(tag)) {
        final customErr = customTag(tag, fieldName: 'Expertise tag', minLength: 2, maxLength: 50);
        if (customErr != null) {
          return customErr;
        }
      }
    }
    return null;
  }

  /// Validates company name: 2-100 characters.
  static String? companyName(String? value, {bool isRequired = true}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isRequired ? 'Company name is required.' : null;
    }
    if (trimmed.length < 2) return 'Company name must be at least 2 characters.';
    if (trimmed.length > 100) return 'Company name cannot exceed 100 characters.';
    return null;
  }

  /// Validates company description: 30-2,000 characters.
  static String? companyDescription(String? value, {bool isRequired = true}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isRequired ? 'Company description is required.' : null;
    }
    if (trimmed.length < 30) return 'Company description must be at least 30 characters.';
    if (trimmed.length > 2000) return 'Company description cannot exceed 2000 characters.';
    return null;
  }

  /// Validates optional or required website URL: must be valid HTTPS.
  static String? httpsWebsiteUrl(String? value, {bool isRequired = false}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isRequired ? 'Website URL is required.' : null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid URL (e.g. https://example.com).';
    }

    if (uri.scheme.toLowerCase() != 'https') {
      return 'Website URL must use HTTPS (e.g. https://example.com).';
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty || !host.contains('.')) {
      return 'Enter a valid domain name with an extension.';
    }

    return null;
  }

  // =========================================================================
  // 6. INVESTOR VALIDATION
  // =========================================================================
  /// Validates investor target sectors against predefined list or valid custom sectors.
  static String? investorSectors(
    Iterable<String>? selected, [
    List<String> allowedOptions = defaultSectorOptions,
  ]) {
    if (selected == null || selected.isEmpty) {
      return 'Please select at least one target sector.';
    }
    for (final item in selected) {
      if (!allowedOptions.contains(item)) {
        final customErr = customTag(item, fieldName: 'Sector', minLength: 2, maxLength: 50);
        if (customErr != null) {
          return customErr;
        }
      }
    }
    return null;
  }

  /// Validates preferred countries against predefined list or valid custom countries.
  static String? investorCountries(
    Iterable<String>? selected, [
    List<String> allowedOptions = defaultCountryOptions,
  ]) {
    if (selected == null || selected.isEmpty) {
      return 'Please select at least one preferred country.';
    }
    for (final item in selected) {
      if (!allowedOptions.contains(item)) {
        final customErr = customTag(item, fieldName: 'Country', minLength: 2, maxLength: 60);
        if (customErr != null) {
          return customErr;
        }
      }
    }
    return null;
  }

  /// Validates preferred startup stages against predefined list or valid custom stages.
  static String? investorStages(
    Iterable<String>? selected, [
    List<String> allowedOptions = defaultStageOptions,
  ]) {
    if (selected == null || selected.isEmpty) {
      return 'Please select at least one startup stage.';
    }
    for (final item in selected) {
      if (!allowedOptions.contains(item)) {
        final customErr = customTag(item, fieldName: 'Stage', minLength: 2, maxLength: 40);
        if (customErr != null) {
          return customErr;
        }
      }
    }
    return null;
  }

  /// Validates typical ticket size selection against predefined list or valid custom ticket size.
  static String? ticketSize(
    String? value, [
    List<String> allowedOptions = defaultTicketOptions,
  ]) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your typical ticket size.';
    }
    if (!allowedOptions.contains(value.trim())) {
      final customErr = customTag(value, fieldName: 'Ticket size', minLength: 2, maxLength: 40);
      if (customErr != null) {
        return customErr;
      }
    }
    return null;
  }

  /// Validates preferred currency selection against predefined list or valid custom currency.
  static String? currency(
    String? value, [
    List<String> allowedOptions = defaultCurrencyOptions,
  ]) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your investment currency.';
    }
    if (!allowedOptions.contains(value.trim())) {
      final customErr = customTag(value, fieldName: 'Currency', minLength: 2, maxLength: 40);
      if (customErr != null) {
        return customErr;
      }
    }
    return null;
  }

  /// Validates risk preference selection (Low, Medium, High).
  static String? riskPreference(
    String? value, [
    List<String> allowedOptions = defaultRiskPreferenceOptions,
  ]) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your risk preference.';
    }
    if (!allowedOptions.contains(value.trim())) {
      return 'Invalid risk preference selected (choose Low, Medium, or High).';
    }
    return null;
  }

  /// Validates investment numerical range (min <= max, non-negative).
  static String? investmentRange({
    required double? minAmount,
    required double? maxAmount,
  }) {
    if (minAmount != null && minAmount < 0) {
      return 'Minimum investment amount cannot be negative.';
    }
    if (maxAmount != null && maxAmount < 0) {
      return 'Maximum investment amount cannot be negative.';
    }
    if (minAmount != null && maxAmount != null && minAmount > maxAmount) {
      return 'Minimum investment amount cannot be greater than maximum amount.';
    }
    return null;
  }
}
