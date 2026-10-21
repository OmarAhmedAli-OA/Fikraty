import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/core/utils/validators.dart';
import 'package:fikraty/core/widgets/app_logo.dart';

void main() {
  // =========================================================================
  // 1. EGYPTIAN MOBILE NUMBER VALIDATION & NORMALIZATION
  // =========================================================================
  group('Validators.egyptianPhone', () {
    test('accepts valid 11-digit Egyptian mobile numbers (010, 011, 012, 015)', () {
      expect(Validators.egyptianPhone('01012345678'), isNull);
      expect(Validators.egyptianPhone('01112345678'), isNull);
      expect(Validators.egyptianPhone('01212345678'), isNull);
      expect(Validators.egyptianPhone('01512345678'), isNull);
    });

    test('accepts international +20 and 0020 formats', () {
      expect(Validators.egyptianPhone('+201012345678'), isNull);
      expect(Validators.egyptianPhone('+2001012345678'), isNull);
      expect(Validators.egyptianPhone('00201012345678'), isNull);
      expect(Validators.egyptianPhone('002001012345678'), isNull);
      expect(Validators.egyptianPhone('+201198765432'), isNull);
      expect(Validators.egyptianPhone('+201298765432'), isNull);
      expect(Validators.egyptianPhone('+201598765432'), isNull);
    });

    test('accepts formatted inputs with spaces, dashes, and parentheses', () {
      expect(Validators.egyptianPhone('010 1234 5678'), isNull);
      expect(Validators.egyptianPhone('010-1234-5678'), isNull);
      expect(Validators.egyptianPhone('(010) 1234 5678'), isNull);
      expect(Validators.egyptianPhone('+20 (10) 1234-5678'), isNull);
    });

    test('rejects invalid prefixes, landlines, incorrect lengths, and non-digits', () {
      final expectedMsg = Validators.egyptianPhoneErrorMessage;
      expect(Validators.egyptianPhone(''), equals(expectedMsg));
      expect(Validators.egyptianPhone(null), equals(expectedMsg));
      expect(Validators.egyptianPhone('   '), equals(expectedMsg));
      expect(Validators.egyptianPhone('01312345678'), equals(expectedMsg)); // 013 not mobile
      expect(Validators.egyptianPhone('01412345678'), equals(expectedMsg)); // 014 unassigned
      expect(Validators.egyptianPhone('01612345678'), equals(expectedMsg)); // 016 unassigned
      expect(Validators.egyptianPhone('0223456789'), equals(expectedMsg));  // Landline (Cairo)
      expect(Validators.egyptianPhone('035467890'), equals(expectedMsg));   // Landline (Alex)
      expect(Validators.egyptianPhone('0101234567'), equals(expectedMsg));  // 10 digits
      expect(Validators.egyptianPhone('010123456789'), equals(expectedMsg));// 12 digits
      expect(Validators.egyptianPhone('0101234567a'), equals(expectedMsg)); // contains letter
      expect(Validators.egyptianPhone('+12012345678'), equals(expectedMsg));// US country code
    });

    test('normalizes Egyptian numbers to standard 11-digit format', () {
      expect(Validators.normalizeEgyptianPhone('+201012345678'), equals('01012345678'));
      expect(Validators.normalizeEgyptianPhone('+2001012345678'), equals('01012345678'));
      expect(Validators.normalizeEgyptianPhone('00201012345678'), equals('01012345678'));
      expect(Validators.normalizeEgyptianPhone('010-1234-5678'), equals('01012345678'));
      expect(Validators.normalizeEgyptianPhone('(015) 9876-5432'), equals('01598765432'));
    });
  });

  // =========================================================================
  // 2. STRONG PASSWORD VALIDATION & LIVE CHECKLIST
  // =========================================================================
  group('Validators.strongPassword & checkPassword', () {
    test('accepts passwords meeting all criteria within 8-128 chars', () {
      expect(Validators.strongPassword('Pass@1234'), isNull);
      expect(Validators.strongPassword('Secure#2026!'), isNull);
      expect(Validators.strongPassword(r'Complex$Password99?'), isNull);
      expect(Validators.strongPassword('Aa1!bcde'), isNull); // 8 chars boundary
    });

    test('rejects passwords with leading or trailing whitespace without silent trimming', () {
      expect(Validators.strongPassword(' Pass@1234'), equals('Password cannot start or end with a space.'));
      expect(Validators.strongPassword('Pass@1234 '), equals('Password cannot start or end with a space.'));
      expect(Validators.strongPassword('  Pass@1234  '), equals('Password cannot start or end with a space.'));
    });

    test('rejects passwords shorter than 8 or longer than 128 characters', () {
      expect(Validators.strongPassword('Aa1!bcd'), equals('Password must be at least 8 characters.'));
      final longPassword = 'Aa1!${List<String>.filled(125, 'x').join()}'; // 129 chars
      expect(Validators.strongPassword(longPassword), equals('Password cannot exceed 128 characters.'));
    });

    test('rejects passwords missing required components', () {
      expect(Validators.strongPassword(''), equals('Password is required.'));
      expect(Validators.strongPassword(null), equals('Password is required.'));
      expect(Validators.strongPassword('alllowercase1!'), equals('Include at least one uppercase letter (A-Z).'));
      expect(Validators.strongPassword('ALLUPPERCASE1!'), equals('Include at least one lowercase letter (a-z).'));
      expect(Validators.strongPassword('NoDigitsAtAll!'), equals('Include at least one number (0-9).'));
      expect(
        Validators.strongPassword('NoSpecialChar123'),
        equals(r'Include at least one special character (!@#$%^&*(),.?":{}|<>).'),
      );
    });

    test('does not treat internal space as an allowed special character', () {
      expect(
        Validators.strongPassword('Pass Word123'),
        equals(r'Include at least one special character (!@#$%^&*(),.?":{}|<>).'),
      );
    });

    test('checkPassword evaluates granular requirements consistently with strongPassword', () {
      final reqsWeak = Validators.checkPassword('abc');
      expect(reqsWeak.hasMinLength, isFalse);
      expect(reqsWeak.hasUppercase, isFalse);
      expect(reqsWeak.hasLowercase, isTrue);
      expect(reqsWeak.hasDigit, isFalse);
      expect(reqsWeak.hasSpecialChar, isFalse);
      expect(reqsWeak.isStrong, isFalse);

      final reqsTrailingSpace = Validators.checkPassword('Pass@1234 ');
      expect(reqsTrailingSpace.hasNoSurroundingWhitespace, isFalse);
      expect(reqsTrailingSpace.isStrong, isFalse);

      final reqsStrong = Validators.checkPassword('Pass@1234');
      expect(reqsStrong.hasMinLength, isTrue);
      expect(reqsStrong.hasMaxLength, isTrue);
      expect(reqsStrong.hasUppercase, isTrue);
      expect(reqsStrong.hasLowercase, isTrue);
      expect(reqsStrong.hasDigit, isTrue);
      expect(reqsStrong.hasSpecialChar, isTrue);
      expect(reqsStrong.hasNoSurroundingWhitespace, isTrue);
      expect(reqsStrong.isStrong, isTrue);
    });
  });

  // =========================================================================
  // 3. EMAIL VALIDATION
  // =========================================================================
  group('Validators.email', () {
    test('accepts valid email addresses from recognized providers and university domains', () {
      expect(Validators.email('omar@gmail.com'), isNull);
      expect(Validators.email('user@outlook.com'), isNull);
      expect(Validators.email('name@hotmail.com'), isNull);
      expect(Validators.email('developer@yahoo.com'), isNull);
      expect(Validators.email('omar@university.edu.eg'), isNull);
      expect(Validators.email('student@aucegypt.edu'), isNull);
      expect(Validators.email('dr.ahmed@eng.cu.edu.eg'), isNull);
      expect(Validators.email('alumni@stanford.edu'), isNull);
      expect(Validators.email('user@icloud.com'), isNull);
      expect(Validators.email('user@live.com'), isNull);
    });

    test('rejects arbitrary or unknown domains like ee.com', () {
      final domainErr = Validators.emailUnrecognizedDomainMessage;
      expect(Validators.email('omar@ee.com'), equals(domainErr));
      expect(Validators.email('random@xyz.co'), equals(domainErr));
      expect(Validators.email('fake@test.net'), equals(domainErr));
      expect(Validators.email('user@arbitrary.org'), equals(domainErr));
    });

    test('trims leading and trailing whitespace', () {
      expect(Validators.email('  omar@gmail.com  '), isNull);
    });

    test('rejects malformed syntax, internal spaces, and consecutive dots', () {
      final err = Validators.emailErrorMessage;
      expect(Validators.email(''), equals(err));
      expect(Validators.email(null), equals(err));
      expect(Validators.email('sarah al@gmail.com'), equals(err)); // internal space
      expect(Validators.email('sarah..al@gmail.com'), equals(err)); // consecutive dots
      expect(Validators.email('sarah@gmail..com'), equals(err));
      expect(Validators.email('sarah@@gmail.com'), equals(err));   // multiple @
      expect(Validators.email('sarahgmail.com'), equals(err));     // missing @
      expect(Validators.email('@gmail.com'), equals(err));         // missing local part
      expect(Validators.email('sarah@'), equals(err));             // missing domain
      expect(Validators.email('sarah@gmail'), equals(err));        // missing TLD
      expect(Validators.email('sarah@gmail.c'), equals(err));      // 1-char TLD
      expect(Validators.email('sarah@-gmail.com'), equals(err));   // domain starts with hyphen
    });
  });

  // =========================================================================
  // 4. COMMON PROFILE FIELDS: FULL NAME, LINKEDIN, LOCATION, GOVERNMENT ID
  // =========================================================================
  group('Validators.fullName', () {
    test('accepts English and Arabic full names with at least two parts', () {
      expect(Validators.fullName('Sarah Al-Mansouri'), isNull);
      expect(Validators.fullName('Omar Farooq'), isNull);
      expect(Validators.fullName('أحمد علي'), isNull);
      expect(Validators.fullName('محمد صلاح الدين'), isNull);
      expect(Validators.fullName("Jean-Pierre O'Connor"), isNull);
    });

    test('respects boundary limits (3 to 80 chars)', () {
      expect(Validators.fullName('A B'), isNull); // 3 chars
      final longName = 'Sarah ${List<String>.filled(74, 'a').join()}'; // 80 chars
      expect(Validators.fullName(longName), isNull);
      final tooLongName = 'Sarah ${List<String>.filled(75, 'a').join()}'; // 81 chars
      expect(Validators.fullName(tooLongName), equals('Full name cannot exceed 80 characters.'));
    });

    test('rejects single-word names, numbers, emoji, and unsupported symbols', () {
      expect(Validators.fullName(''), equals('Full name is required.'));
      expect(Validators.fullName('Sarah'), equals('Please enter both your first and last name.'));
      expect(Validators.fullName('Sarah123 Mansouri'), equals('Full name must contain letters only (Arabic or English).'));
      expect(Validators.fullName('أحمد١ علي'), equals('Full name must contain letters only (Arabic or English).'));
      expect(Validators.fullName('Sarah 🚀 Mansouri'), equals('Full name must contain letters only (Arabic or English).'));
      expect(Validators.fullName('Sarah * Mansouri'), equals('Full name must contain letters only (Arabic or English).'));
    });
  });

  group('Validators.linkedInUrl', () {
    test('accepts HTTPS URLs on linkedin.com or www.linkedin.com with personal profile path', () {
      expect(Validators.linkedInUrl('https://linkedin.com/in/sarah-almansouri'), isNull);
      expect(Validators.linkedInUrl('https://www.linkedin.com/in/omar_farooq'), isNull);
      expect(Validators.linkedInUrl('https://linkedin.com/in/john.doe.123/'), isNull);
    });

    test('rejects HTTP, fake domains, company/school paths, and malformed URLs', () {
      expect(Validators.linkedInUrl('http://linkedin.com/in/sarah'), equals('LinkedIn URL must use HTTPS (e.g. https://linkedin.com/in/username).'));
      expect(Validators.linkedInUrl('https://not-linkedin.com/in/sarah'), equals('URL must be a LinkedIn profile (e.g. https://linkedin.com/in/username).'));
      expect(Validators.linkedInUrl('https://linkedin.com.evil.com/in/sarah'), equals('URL must be a LinkedIn profile (e.g. https://linkedin.com/in/username).'));
      expect(Validators.linkedInUrl('https://linkedin.com/company/fikraty'), equals('Enter a valid personal profile URL (e.g. https://linkedin.com/in/username).'));
      expect(Validators.linkedInUrl('https://linkedin.com/school/cairo-university'), equals('Enter a valid personal profile URL (e.g. https://linkedin.com/in/username).'));
      expect(Validators.linkedInUrl('https://linkedin.com/in/'), equals('Enter a valid personal profile URL (e.g. https://linkedin.com/in/username).'));
      expect(Validators.linkedInUrl('not-a-url'), equals('Enter a valid LinkedIn URL (e.g. https://linkedin.com/in/username).'));
      expect(Validators.linkedInUrl(''), equals('LinkedIn profile URL is required.'));
      expect(Validators.linkedInUrl('', isRequired: false), isNull);
    });
  });

  group('Validators.location', () {
    test('accepts valid locations (3 to 100 chars)', () {
      expect(Validators.location('Cairo, Egypt'), isNull);
      expect(Validators.location('Giza'), isNull);
      expect(Validators.location('Dubai, United Arab Emirates'), isNull);
    });

    test('rejects empty, whitespace-only, or invalid length', () {
      expect(Validators.location(''), equals('Country / city of residence is required.'));
      expect(Validators.location('   '), equals('Country / city of residence is required.'));
      expect(Validators.location('Ca'), equals('Location must be at least 3 characters.'));
      final longLoc = List<String>.filled(101, 'a').join();
      expect(Validators.location(longLoc), equals('Location cannot exceed 100 characters.'));
    });
  });

  group('Validators.governmentIdDocument', () {
    test('is optional at signup when isRequired is false', () {
      expect(Validators.governmentIdDocument(null, isRequired: false), isNull);
      expect(Validators.governmentIdDocument('', isRequired: false), isNull);
    });

    test('accepts allowed formats (JPG, PNG, PDF) under 5 MB', () {
      expect(Validators.governmentIdDocument('national_id.jpg', fileSizeBytes: 1024 * 1024), isNull);
      expect(Validators.governmentIdDocument('passport.jpeg', fileSizeBytes: 2 * 1024 * 1024), isNull);
      expect(Validators.governmentIdDocument('id_card.png', fileSizeBytes: 4 * 1024 * 1024), isNull);
      expect(Validators.governmentIdDocument('identification.pdf', fileSizeBytes: 5 * 1024 * 1024), isNull);
    });

    test('rejects disallowed file extensions or oversized files', () {
      expect(
        Validators.governmentIdDocument('script.exe'),
        equals('Allowed file formats are JPG, PNG, and PDF (max 5 MB).'),
      );
      expect(
        Validators.governmentIdDocument('photo.bmp'),
        equals('Allowed file formats are JPG, PNG, and PDF (max 5 MB).'),
      );
      expect(
        Validators.governmentIdDocument('national_id.jpg', fileSizeBytes: (5 * 1024 * 1024) + 1),
        equals('File size exceeds maximum allowed size of 5 MB.'),
      );
    });
  });

  // =========================================================================
  // 5. FOUNDER / ENTREPRENEUR VALIDATION
  // =========================================================================
  group('Founder Validators', () {
    test('professionalTitle requires 2-80 characters', () {
      expect(Validators.professionalTitle('Founder & CEO'), isNull);
      expect(Validators.professionalTitle('CTO'), isNull);
      expect(Validators.professionalTitle(''), equals('Current professional title is required.'));
      expect(Validators.professionalTitle('A'), equals('Professional title must be at least 2 characters.'));
      final longTitle = List<String>.filled(81, 'a').join();
      expect(Validators.professionalTitle(longTitle), equals('Professional title cannot exceed 80 characters.'));
    });

    test('bio requires 15-240 characters', () {
      expect(Validators.bio('Experienced startup founder focusing on FinTech and AI innovations.'), isNull);
      expect(Validators.bio('123456789012345'), isNull); // 15 chars boundary
      expect(Validators.bio('Short bio'), equals('Bio must be at least 15 characters.'));
      final longBio = List<String>.filled(241, 'a').join();
      expect(Validators.bio(longBio), equals('Bio cannot exceed 240 characters.'));
    });

    test('founderExpertise validates predefined and valid custom options', () {
      expect(Validators.founderExpertise(['Product', 'Engineering']), isNull);
      expect(Validators.founderExpertise(['Product', 'AI Research']), isNull); // Valid custom tag
      expect(Validators.founderExpertise([]), equals('Please select at least one area of expertise.'));
      expect(Validators.founderExpertise(null), equals('Please select at least one area of expertise.'));
      expect(
        Validators.founderExpertise(['Legal<script>']),
        equals('Expertise tag contains invalid characters (letters, numbers, and hyphens only).'),
      );
      expect(
        Validators.founderExpertise(['A']),
        equals('Expertise tag must be at least 2 characters.'),
      );
    });

    test('companyName requires 2-100 characters when required', () {
      expect(Validators.companyName('Fikraty Labs'), isNull);
      expect(Validators.companyName(''), equals('Company name is required.'));
      expect(Validators.companyName('', isRequired: false), isNull);
      expect(Validators.companyName('A'), equals('Company name must be at least 2 characters.'));
      final longName = List<String>.filled(101, 'a').join();
      expect(Validators.companyName(longName), equals('Company name cannot exceed 100 characters.'));
    });

    test('companyDescription requires 30-2000 characters when required', () {
      final validDesc = 'Fikraty is an innovative ecosystem connecting emerging entrepreneurs and strategic angel investors.';
      expect(Validators.companyDescription(validDesc), isNull);
      expect(Validators.companyDescription('Too short'), equals('Company description must be at least 30 characters.'));
      expect(Validators.companyDescription('', isRequired: false), isNull);
      final longDesc = List<String>.filled(2001, 'a').join();
      expect(Validators.companyDescription(longDesc), equals('Company description cannot exceed 2000 characters.'));
    });

    test('httpsWebsiteUrl requires valid HTTPS domain', () {
      expect(Validators.httpsWebsiteUrl('https://fikraty.com'), isNull);
      expect(Validators.httpsWebsiteUrl('https://subdomain.fikraty.ai/demo'), isNull);
      expect(Validators.httpsWebsiteUrl('', isRequired: false), isNull);
      expect(Validators.httpsWebsiteUrl('http://fikraty.com'), equals('Website URL must use HTTPS (e.g. https://example.com).'));
      expect(Validators.httpsWebsiteUrl('not-a-url'), equals('Enter a valid URL (e.g. https://example.com).'));
      expect(Validators.httpsWebsiteUrl('https://fikraty'), equals('Enter a valid domain name with an extension.'));
    });
  });

  // =========================================================================
  // 6. INVESTOR VALIDATION
  // =========================================================================
  group('Investor Validators', () {
    test('investorSectors validates predefined and valid custom sectors', () {
      expect(Validators.investorSectors(['FinTech', 'AI / ML']), isNull);
      expect(Validators.investorSectors(['FinTech', 'PropTech']), isNull); // Valid custom sector
      expect(Validators.investorSectors([]), equals('Please select at least one target sector.'));
      expect(
        Validators.investorSectors(['Sector<script>']),
        equals('Sector contains invalid characters (letters, numbers, and hyphens only).'),
      );
    });

    test('investorCountries validates predefined and valid custom countries', () {
      expect(Validators.investorCountries(['Egypt', 'UAE']), isNull);
      expect(Validators.investorCountries(['Egypt', 'Oman']), isNull); // Valid custom country
      expect(Validators.investorCountries([]), equals('Please select at least one preferred country.'));
      expect(
        Validators.investorCountries(['A']),
        equals('Country must be at least 2 characters.'),
      );
    });

    test('investorStages validates predefined and valid custom stages', () {
      expect(Validators.investorStages(['Seed', 'Series A']), isNull);
      expect(Validators.investorStages(['Seed', 'Bridge Round']), isNull); // Valid custom stage
      expect(Validators.investorStages([]), equals('Please select at least one startup stage.'));
      expect(
        Validators.investorStages(['Stage*!']),
        equals('Stage contains invalid characters (letters, numbers, and hyphens only).'),
      );
    });

    test('ticketSize validates predefined and valid custom ticket sizes', () {
      expect(Validators.ticketSize(r'$50K – $250K'), isNull);
      expect(Validators.ticketSize(r'$25K – $75K'), isNull); // Valid custom ticket size
      expect(Validators.ticketSize(''), equals('Please select your typical ticket size.'));
      expect(
        Validators.ticketSize(r'$'),
        equals('Ticket size must be at least 2 characters.'),
      );
    });

    test('currency validates predefined and custom currencies', () {
      expect(Validators.currency(r'USD ($) - US Dollar'), isNull);
      expect(Validators.currency('EGP (ج.م) - Egyptian Pound'), isNull);
      expect(Validators.currency('SAR (ر.س) - Saudi Riyal'), isNull);
      expect(Validators.currency('KWD (د.ك) - Kuwaiti Dinar'), isNull);
      expect(Validators.currency('BHD (د.ب) - Bahraini Dinar'), isNull); // Valid custom
      expect(Validators.currency(''), equals('Please select your investment currency.'));
      expect(
        Validators.currency('C*!'),
        equals('Currency contains invalid characters (letters, numbers, and hyphens only).'),
      );
    });

    test('riskPreference validates Low, Medium, High', () {
      expect(Validators.riskPreference('Low'), isNull);
      expect(Validators.riskPreference('Medium'), isNull);
      expect(Validators.riskPreference('High'), isNull);
      expect(Validators.riskPreference(''), equals('Please select your risk preference.'));
      expect(Validators.riskPreference('Ultra-High'), equals('Invalid risk preference selected (choose Low, Medium, or High).'));
    });

    test('customTag enforces length, whitelist, and duplicate check', () {
      expect(Validators.customTag('Biotech', existingOptions: ['FinTech', 'AI / ML']), isNull);
      expect(Validators.customTag('', fieldName: 'Tag'), equals('Tag is required.'));
      expect(Validators.customTag('A', fieldName: 'Tag'), equals('Tag must be at least 2 characters.'));
      expect(
        Validators.customTag('Tag<script>', fieldName: 'Tag'),
        equals('Tag contains invalid characters (letters, numbers, and hyphens only).'),
      );
      expect(
        Validators.customTag('FinTech', existingOptions: ['FinTech', 'AI / ML']),
        equals('"FinTech" already exists in the options.'),
      );
    });

    test('investmentRange rejects negative numbers or min > max', () {
      expect(Validators.investmentRange(minAmount: 10000, maxAmount: 50000), isNull);
      expect(Validators.investmentRange(minAmount: -10, maxAmount: 50000), equals('Minimum investment amount cannot be negative.'));
      expect(Validators.investmentRange(minAmount: 10000, maxAmount: -50), equals('Maximum investment amount cannot be negative.'));
      expect(Validators.investmentRange(minAmount: 100000, maxAmount: 50000), equals('Minimum investment amount cannot be greater than maximum amount.'));
    });
  });

  // =========================================================================
  // 7. PASSWORD & CONFIRM PASSWORD
  // =========================================================================
  group('Validators.password & confirmPassword', () {
    test('requires at least eight characters', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('long-enough-password'), isNull);
    });

    test('confirmPassword rejects mismatches and accepts matches', () {
      expect(Validators.confirmPassword('different', 'password123'), isNotNull);
      expect(Validators.confirmPassword('password123', 'password123'), isNull);
      expect(Validators.confirmPassword('', 'password123'), equals('Please confirm your password.'));
    });
  });

  // =========================================================================
  // 8. APP LOGO WIDGET
  // =========================================================================
  group('AppLogo', () {
    testWidgets('renders brand mark without text by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLogo(size: 48, showText: false),
          ),
        ),
      );
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('Fikraty'), findsNothing);
    });

    testWidgets('renders brand mark and "Fikraty" title when showText is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLogo(size: 40, showText: true),
          ),
        ),
      );
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('Fikraty'), findsOneWidget);
    });
  });
}
