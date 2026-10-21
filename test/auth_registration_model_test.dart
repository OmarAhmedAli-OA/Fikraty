import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/features/auth/data/models/auth_model.dart';
import 'package:fikraty/features/auth/domain/entities/auth.dart';

void main() {
  test('entrepreneur request maps ERD fields and normalizes optional blanks to null', () {
    final request = RegistrationRequestModel(RegistrationData(
      email: ' Founder@Example.com ',
      password: 'prototype-password',
      role: UserRole.entrepreneur,
      phone: ' +201001234567 ',
      profile: const UserProfileData(
        fullName: ' Founder Name ',
        headline: ' ',
        professionalTitle: 'Founder',
        bio: '',
      ),
      startup: const StartupRegistrationData(
        name: ' Fikraty Labs ',
        industry: LookupSelection(code: 'technology', label: 'Technology'),
        stage: LookupSelection(code: 'MVP', label: 'MVP'),
      ),
    )).toApiJson();

    expect(request['email'], 'founder@example.com');
    expect(request['phone'], '+201001234567');
    expect(request['role'], 'entrepreneur');
    expect(request.containsKey('password_hash'), isFalse);
    final profile = request['profile']! as Map<String, Object?>;
    expect(profile['full_name'], 'Founder Name');
    expect(profile['headline'], isNull);
    expect(profile['bio'], isNull);
    final startup = request['startup']! as Map<String, Object?>;
    expect(startup['name'], 'Fikraty Labs');
    expect(startup['industry_code'], 'technology');
    expect(startup['stage_code'], 'MVP');
    expect(request.containsKey('investor_profile'), isFalse);
    // The server generates slug, IDs, status, verification and timestamps.
    expect(startup.containsKey('slug'), isFalse);
    expect(startup.containsKey('owner_user_id'), isFalse);
  });

  test('investor request includes preference joins and financing flags', () {
    final request = RegistrationRequestModel(RegistrationData(
      email: 'investor@example.com',
      password: 'prototype-password',
      role: UserRole.investor,
      profile: const UserProfileData(fullName: 'Investor Name'),
      investor: const InvestorRegistrationData(
        firmName: 'Demo Ventures',
        investorType: 'Angel',
        thesis: 'Early stage',
        ticketMin: 10000,
        ticketMax: 50000,
        currency: LookupSelection(code: 'USD', label: 'USD'),
        riskPreference: InvestorRiskPreference.medium,
        preferredIndustries: [LookupSelection(code: 'technology', label: 'Technology')],
        preferredCountries: [LookupSelection(code: 'EG', label: 'Egypt')],
        preferredStages: [LookupSelection(code: 'MVP', label: 'MVP')],
        providesSmartMoney: true,
        providesDebt: true,
      ),
    )).toApiJson();

    expect(request.containsKey('startup'), isFalse);
    final investor = request['investor_profile']! as Map<String, Object?>;
    expect(investor['firm_name'], 'Demo Ventures');
    expect(investor['ticket_min'], 10000);
    expect(investor['ticket_max'], 50000);
    expect(investor['currency_code'], 'USD');
    expect(investor['risk_preference'], 'medium');
    expect(investor['preferred_industry_codes'], ['technology']);
    expect(investor['preferred_country_codes'], ['EG']);
    expect(investor['preferred_stage_codes'], ['MVP']);
    expect(investor['provides_smart_money'], isTrue);
    expect(investor['provides_debt'], isTrue);
    expect(investor.containsKey('user_id'), isFalse);
  });
}
