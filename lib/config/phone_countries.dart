/// Phone country rules — mirrors Laravel config/phone.php.
class PhoneCountry {
  final String iso;
  final String name;
  final String dialCode;
  final int nationalLength;
  final RegExp pattern;
  final String example;

  PhoneCountry({
    required this.iso,
    required this.name,
    required this.dialCode,
    required this.nationalLength,
    required this.pattern,
    required this.example,
  });

  String composeE164(String national) {
    final digits = PhoneCountries.normalizeNational(national);
    return '$dialCode$digits';
  }

  String? validateNational(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Enter your phone number.';
    }

    var digits = PhoneCountries.normalizeNational(input);

    if (digits.length != nationalLength) {
      return '$name numbers must be $nationalLength digits (e.g. $example).';
    }

    if (!pattern.hasMatch(digits)) {
      return 'Invalid $name phone number format (e.g. $example).';
    }

    return null;
  }
}

class PhoneCountries {
  PhoneCountries._();

  static const String defaultIso = 'TZ';

  static final List<PhoneCountry> all = [
    PhoneCountry(
      iso: 'TZ',
      name: 'Tanzania',
      dialCode: '255',
      nationalLength: 9,
      pattern: RegExp(r'^[67]\d{8}$'),
      example: '712345678',
    ),
    PhoneCountry(
      iso: 'KE',
      name: 'Kenya',
      dialCode: '254',
      nationalLength: 9,
      pattern: RegExp(r'^[17]\d{8}$'),
      example: '712345678',
    ),
    PhoneCountry(
      iso: 'UG',
      name: 'Uganda',
      dialCode: '256',
      nationalLength: 9,
      pattern: RegExp(r'^\d{9}$'),
      example: '712345678',
    ),
    PhoneCountry(
      iso: 'RW',
      name: 'Rwanda',
      dialCode: '250',
      nationalLength: 9,
      pattern: RegExp(r'^\d{9}$'),
      example: '788123456',
    ),
    PhoneCountry(
      iso: 'BI',
      name: 'Burundi',
      dialCode: '257',
      nationalLength: 8,
      pattern: RegExp(r'^\d{8}$'),
      example: '79123456',
    ),
    PhoneCountry(
      iso: 'SS',
      name: 'South Sudan',
      dialCode: '211',
      nationalLength: 9,
      pattern: RegExp(r'^\d{9}$'),
      example: '912345678',
    ),
    PhoneCountry(
      iso: 'ET',
      name: 'Ethiopia',
      dialCode: '251',
      nationalLength: 9,
      pattern: RegExp(r'^\d{9}$'),
      example: '911234567',
    ),
    PhoneCountry(
      iso: 'NG',
      name: 'Nigeria',
      dialCode: '234',
      nationalLength: 10,
      pattern: RegExp(r'^\d{10}$'),
      example: '8012345678',
    ),
    PhoneCountry(
      iso: 'ZA',
      name: 'South Africa',
      dialCode: '27',
      nationalLength: 9,
      pattern: RegExp(r'^\d{9}$'),
      example: '821234567',
    ),
    PhoneCountry(
      iso: 'GH',
      name: 'Ghana',
      dialCode: '233',
      nationalLength: 9,
      pattern: RegExp(r'^\d{9}$'),
      example: '241234567',
    ),
    PhoneCountry(
      iso: 'US',
      name: 'United States',
      dialCode: '1',
      nationalLength: 10,
      pattern: RegExp(r'^\d{10}$'),
      example: '4155552671',
    ),
    PhoneCountry(
      iso: 'GB',
      name: 'United Kingdom',
      dialCode: '44',
      nationalLength: 10,
      pattern: RegExp(r'^7\d{9}$'),
      example: '7911123456',
    ),
    PhoneCountry(
      iso: 'IN',
      name: 'India',
      dialCode: '91',
      nationalLength: 10,
      pattern: RegExp(r'^[6-9]\d{9}$'),
      example: '9876543210',
    ),
    PhoneCountry(
      iso: 'CN',
      name: 'China',
      dialCode: '86',
      nationalLength: 11,
      pattern: RegExp(r'^1\d{10}$'),
      example: '13912345678',
    ),
    PhoneCountry(
      iso: 'AE',
      name: 'United Arab Emirates',
      dialCode: '971',
      nationalLength: 9,
      pattern: RegExp(r'^5\d{8}$'),
      example: '501234567',
    ),
    PhoneCountry(
      iso: 'SA',
      name: 'Saudi Arabia',
      dialCode: '966',
      nationalLength: 9,
      pattern: RegExp(r'^5\d{8}$'),
      example: '501234567',
    ),
  ];

  static PhoneCountry byIso(String iso) {
    return all.firstWhere(
      (c) => c.iso == iso,
      orElse: () => all.firstWhere((c) => c.iso == defaultIso),
    );
  }

  static String normalizeNational(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0') && digits.length > 1) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// Split E.164 digits into ISO + national (longest dial code match).
  static ({String iso, String national}) split(String? e164) {
    final digits = (e164 ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return (iso: defaultIso, national: '');
    }

    final sorted = List<PhoneCountry>.from(all)
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));

    for (final country in sorted) {
      if (digits.startsWith(country.dialCode)) {
        return (
          iso: country.iso,
          national: digits.substring(country.dialCode.length),
        );
      }
    }

    return (iso: defaultIso, national: digits);
  }
}
