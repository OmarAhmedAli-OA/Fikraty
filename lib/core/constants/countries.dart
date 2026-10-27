import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String code;
  final String name;
  final String nameAr;
  final String flagEmoji;
  final String currencyCode;
  final String currencySymbol;
  final String phoneCode;

  const Country({
    required this.code,
    required this.name,
    required this.nameAr,
    required this.flagEmoji,
    required this.currencyCode,
    required this.currencySymbol,
    required this.phoneCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'nameAr': nameAr,
      'flagEmoji': flagEmoji,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'phoneCode': phoneCode,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      code: map['code'] as String? ?? 'EG',
      name: map['name'] as String? ?? 'Egypt',
      nameAr: map['nameAr'] as String? ?? '',
      flagEmoji: map['flagEmoji'] as String? ?? '🇪🇬',
      currencyCode: map['currencyCode'] as String? ?? 'EGP',
      currencySymbol: map['currencySymbol'] as String? ?? 'E£',
      phoneCode: map['phoneCode'] as String? ?? '+20',
    );
  }

  @override
  List<Object?> get props => [code, name, currencyCode];
}

abstract final class AppCountries {
  static const List<Country> list = [
    Country(
      code: 'EG',
      name: 'Egypt',
      nameAr: '',
      flagEmoji: '🇪🇬',
      currencyCode: 'EGP',
      currencySymbol: 'E£',
      phoneCode: '+20',
    ),
    Country(
      code: 'SA',
      name: 'Saudi Arabia',
      nameAr: '',
      flagEmoji: '🇸🇦',
      currencyCode: 'SAR',
      currencySymbol: 'SR',
      phoneCode: '+966',
    ),
    Country(
      code: 'AE',
      name: 'United Arab Emirates',
      nameAr: '',
      flagEmoji: '🇦🇪',
      currencyCode: 'AED',
      currencySymbol: 'AED',
      phoneCode: '+971',
    ),
    Country(
      code: 'KW',
      name: 'Kuwait',
      nameAr: '',
      flagEmoji: '🇰🇼',
      currencyCode: 'KWD',
      currencySymbol: 'KD',
      phoneCode: '+965',
    ),
    Country(
      code: 'QA',
      name: 'Qatar',
      nameAr: '',
      flagEmoji: '🇶🇦',
      currencyCode: 'QAR',
      currencySymbol: 'QR',
      phoneCode: '+974',
    ),
    Country(
      code: 'BH',
      name: 'Bahrain',
      nameAr: '',
      flagEmoji: '🇧🇭',
      currencyCode: 'BHD',
      currencySymbol: 'BD',
      phoneCode: '+973',
    ),
    Country(
      code: 'OM',
      name: 'Oman',
      nameAr: '',
      flagEmoji: '🇴🇲',
      currencyCode: 'OMR',
      currencySymbol: 'OMR',
      phoneCode: '+968',
    ),
    Country(
      code: 'JO',
      name: 'Jordan',
      nameAr: '',
      flagEmoji: '🇯🇴',
      currencyCode: 'JOD',
      currencySymbol: 'JD',
      phoneCode: '+962',
    ),
    Country(
      code: 'US',
      name: 'United States',
      nameAr: '',
      flagEmoji: '🇺🇸',
      currencyCode: 'USD',
      currencySymbol: '\$',
      phoneCode: '+1',
    ),
    Country(
      code: 'GB',
      name: 'United Kingdom',
      nameAr: '',
      flagEmoji: '🇬🇧',
      currencyCode: 'GBP',
      currencySymbol: '£',
      phoneCode: '+44',
    ),
  ];

  static const Country defaultCountry = Country(
    code: 'EG',
    name: 'Egypt',
    nameAr: '',
    flagEmoji: '🇪🇬',
    currencyCode: 'EGP',
    currencySymbol: 'E£',
    phoneCode: '+20',
  );

  static Country findByCode(String code) {
    return list.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => defaultCountry,
    );
  }

  static Country resolve(String? query, [Country? fallback]) {
    if (query == null || query.trim().isEmpty) {
      return fallback ?? defaultCountry;
    }
    final q = query.trim().toLowerCase();

    // 1. Direct code or exact name match
    for (final c in list) {
      if (c.code.toLowerCase() == q ||
          c.name.toLowerCase() == q ||
          (c.nameAr.isNotEmpty && c.nameAr.toLowerCase() == q)) {
        return c;
      }
    }

    // 2. Common regional & global aliases
    if (q.contains('usa') ||
        q.contains('united states') ||
        q.contains('america') ||
        q == 'us') {
      return findByCode('US');
    }
    if (q.contains('uae') ||
        q.contains('emirates') ||
        q.contains('dubai') ||
        q.contains('abu dhabi') ||
        q == 'ae') {
      return findByCode('AE');
    }
    if (q.contains('egypt') ||
        q.contains('cairo') ||
        q.contains('alexandria') ||
        q.contains('مصر') ||
        q == 'eg') {
      return findByCode('EG');
    }
    if (q.contains('saudi') ||
        q.contains('ksa') ||
        q.contains('riyadh') ||
        q.contains('jeddah') ||
        q.contains('السعودية') ||
        q == 'sa') {
      return findByCode('SA');
    }
    if (q.contains('uk') ||
        q.contains('united kingdom') ||
        q.contains('britain') ||
        q.contains('london') ||
        q.contains('england') ||
        q == 'gb') {
      return findByCode('GB');
    }
    if (q.contains('kuwait') || q.contains('الكويت') || q == 'kw') {
      return findByCode('KW');
    }
    if (q.contains('qatar') || q.contains('doha') || q.contains('قطر') || q == 'qa') {
      return findByCode('QA');
    }
    if (q.contains('bahrain') || q.contains('البحرين') || q == 'bh') {
      return findByCode('BH');
    }
    if (q.contains('oman') || q.contains('عمان') || q == 'om') {
      return findByCode('OM');
    }
    if (q.contains('jordan') || q.contains('amman') || q.contains('الأردن') || q == 'jo') {
      return findByCode('JO');
    }

    // 3. Substring match against country names
    for (final c in list) {
      if (q.contains(c.name.toLowerCase()) ||
          (c.nameAr.isNotEmpty && q.contains(c.nameAr.toLowerCase()))) {
        return c;
      }
    }

    return fallback ?? defaultCountry;
  }

  static Country findByName(String name) {
    return list.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase() ||
          c.nameAr.toLowerCase() == name.toLowerCase(),
      orElse: () => defaultCountry,
    );
  }

  static const Map<String, List<String>> governoratesMap = {
    'EG': [
      'Cairo',
      'Giza',
      'Alexandria',
      'Dakahlia (Mansoura)',
      'Sharqia',
      'Qalyubia',
      'Gharbia (Tanta)',
      'Port Said',
      'Suez',
      'Ismailia',
      'Aswan',
      'Luxor',
      'Red Sea (Hurghada)',
      'South Sinai (Sharm El-Sheikh)',
      'Asyut',
      'Sohag',
      'Beni Suef',
      'Minya',
      'Matrouh',
      'Fayoum',
      'Damietta',
      'Beheira',
      'Kafr El Sheikh',
      'Monufia',
      'Qena',
      'New Valley',
      'North Sinai',
    ],
    'SA': [
      'Riyadh',
      'Jeddah',
      'Mecca',
      'Medina',
      'Dammam',
      'Khobar',
      'Dhahran',
      'Tabuk',
      'Abha',
      'Taif',
      'Hail',
      'Najran',
      'Jazan',
      'Al-Ahsa',
      'Al-Qassim (Buraidah)',
      'Yanbu',
    ],
    'AE': [
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
      'Ras Al Khaimah',
      'Fujairah',
      'Umm Al Quwain',
    ],
    'KW': [
      'Kuwait City',
      'Hawally',
      'Al Ahmadi',
      'Al Farwaniyah',
      'Mubarak Al-Kabeer',
      'Al Jahra',
    ],
    'QA': [
      'Doha',
      'Al Rayyan',
      'Al Wakrah',
      'Al Khor',
      'Umm Salal',
      'Al Daayen',
      'Madinat ash Shamal',
    ],
    'BH': [
      'Manama',
      'Muharraq',
      'Riffa',
      'Hamad Town',
      'A\'ali',
      'Isa Town',
      'Sitra',
      'Budaiya',
    ],
    'OM': [
      'Muscat',
      'Salalah',
      'Sohar',
      'Nizwa',
      'Sur',
      'Seeb',
      'Barka',
      'Rustaq',
    ],
    'JO': [
      'Amman',
      'Zarqa',
      'Irbid',
      'Aqaba',
      'Salt',
      'Madaba',
      'Jerash',
      'Ajloun',
      'Karak',
      'Ma\'an',
    ],
    'US': [
      'California (San Francisco)',
      'California (Los Angeles)',
      'New York (NYC)',
      'Texas (Austin)',
      'Washington (Seattle)',
      'Massachusetts (Boston)',
      'Florida (Miami)',
      'Illinois (Chicago)',
    ],
    'GB': [
      'London',
      'Manchester',
      'Birmingham',
      'Edinburgh',
      'Cambridge',
      'Oxford',
      'Bristol',
      'Glasgow',
    ],
  };

  static List<String> getGovernorates(String countryCode) {
    return governoratesMap[countryCode.toUpperCase()] ?? [
      'Capital Region',
      'Northern Province',
      'Southern Province',
      'Eastern Province',
      'Western Province',
    ];
  }
}
