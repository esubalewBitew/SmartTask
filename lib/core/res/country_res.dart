import 'package:flutter/material.dart';

class CountryRes {
  const CountryRes._();

  static final List<Map<String, String>> countries = [
    // Priority Countries (Most Used)
    {'name': 'Ethiopia', 'code': 'ET', 'dialCode': '+251'},
    {'name': 'United States', 'code': 'US', 'dialCode': '+1'},
    {'name': 'United Kingdom', 'code': 'GB', 'dialCode': '+44'},

    // East Africa
    {'name': 'Kenya', 'code': 'KE', 'dialCode': '+254'},
    {'name': 'Tanzania', 'code': 'TZ', 'dialCode': '+255'},
    {'name': 'Uganda', 'code': 'UG', 'dialCode': '+256'},
    {'name': 'Rwanda', 'code': 'RW', 'dialCode': '+250'},
    {'name': 'Sudan', 'code': 'SD', 'dialCode': '+249'},
    {'name': 'South Sudan', 'code': 'SS', 'dialCode': '+211'},
    {'name': 'Djibouti', 'code': 'DJ', 'dialCode': '+253'},
    {'name': 'Somalia', 'code': 'SO', 'dialCode': '+252'},
    {'name': 'Eritrea', 'code': 'ER', 'dialCode': '+291'},

    // Rest of Africa
    {'name': 'Nigeria', 'code': 'NG', 'dialCode': '+234'},
    {'name': 'South Africa', 'code': 'ZA', 'dialCode': '+27'},
    {'name': 'Egypt', 'code': 'EG', 'dialCode': '+20'},
    {'name': 'Morocco', 'code': 'MA', 'dialCode': '+212'},
    {'name': 'Ghana', 'code': 'GH', 'dialCode': '+233'},
    {'name': 'Algeria', 'code': 'DZ', 'dialCode': '+213'},
    {'name': 'Tunisia', 'code': 'TN', 'dialCode': '+216'},
    {'name': 'Libya', 'code': 'LY', 'dialCode': '+218'},
    {'name': 'Mozambique', 'code': 'MZ', 'dialCode': '+258'},
    {'name': 'Angola', 'code': 'AO', 'dialCode': '+244'},
    {'name': 'Zimbabwe', 'code': 'ZW', 'dialCode': '+263'},
    {'name': 'Zambia', 'code': 'ZM', 'dialCode': '+260'},
    {'name': 'Cameroon', 'code': 'CM', 'dialCode': '+237'},
    {'name': 'Ivory Coast', 'code': 'CI', 'dialCode': '+225'},
    {'name': 'Senegal', 'code': 'SN', 'dialCode': '+221'},

    // Middle East
    {'name': 'Saudi Arabia', 'code': 'SA', 'dialCode': '+966'},
    {'name': 'UAE', 'code': 'AE', 'dialCode': '+971'},
    {'name': 'Qatar', 'code': 'QA', 'dialCode': '+974'},
    {'name': 'Kuwait', 'code': 'KW', 'dialCode': '+965'},
    {'name': 'Bahrain', 'code': 'BH', 'dialCode': '+973'},
    {'name': 'Oman', 'code': 'OM', 'dialCode': '+968'},
    {'name': 'Israel', 'code': 'IL', 'dialCode': '+972'},
    {'name': 'Turkey', 'code': 'TR', 'dialCode': '+90'},
    {'name': 'Iran', 'code': 'IR', 'dialCode': '+98'},
    {'name': 'Iraq', 'code': 'IQ', 'dialCode': '+964'},
    {'name': 'Jordan', 'code': 'JO', 'dialCode': '+962'},
    {'name': 'Lebanon', 'code': 'LB', 'dialCode': '+961'},

    // Asia
    {'name': 'China', 'code': 'CN', 'dialCode': '+86'},
    {'name': 'India', 'code': 'IN', 'dialCode': '+91'},
    {'name': 'Japan', 'code': 'JP', 'dialCode': '+81'},
    {'name': 'South Korea', 'code': 'KR', 'dialCode': '+82'},
    {'name': 'Indonesia', 'code': 'ID', 'dialCode': '+62'},
    {'name': 'Pakistan', 'code': 'PK', 'dialCode': '+92'},
    {'name': 'Bangladesh', 'code': 'BD', 'dialCode': '+880'},
    {'name': 'Philippines', 'code': 'PH', 'dialCode': '+63'},
    {'name': 'Vietnam', 'code': 'VN', 'dialCode': '+84'},
    {'name': 'Thailand', 'code': 'TH', 'dialCode': '+66'},
    {'name': 'Malaysia', 'code': 'MY', 'dialCode': '+60'},
    {'name': 'Singapore', 'code': 'SG', 'dialCode': '+65'},
    {'name': 'Taiwan', 'code': 'TW', 'dialCode': '+886'},
    {'name': 'Hong Kong', 'code': 'HK', 'dialCode': '+852'},

    // Europe
    {'name': 'Germany', 'code': 'DE', 'dialCode': '+49'},
    {'name': 'France', 'code': 'FR', 'dialCode': '+33'},
    {'name': 'Italy', 'code': 'IT', 'dialCode': '+39'},
    {'name': 'Spain', 'code': 'ES', 'dialCode': '+34'},
    {'name': 'Netherlands', 'code': 'NL', 'dialCode': '+31'},
    {'name': 'Switzerland', 'code': 'CH', 'dialCode': '+41'},
    {'name': 'Belgium', 'code': 'BE', 'dialCode': '+32'},
    {'name': 'Sweden', 'code': 'SE', 'dialCode': '+46'},
    {'name': 'Norway', 'code': 'NO', 'dialCode': '+47'},
    {'name': 'Denmark', 'code': 'DK', 'dialCode': '+45'},
    {'name': 'Finland', 'code': 'FI', 'dialCode': '+358'},
    {'name': 'Austria', 'code': 'AT', 'dialCode': '+43'},
    {'name': 'Greece', 'code': 'GR', 'dialCode': '+30'},
    {'name': 'Portugal', 'code': 'PT', 'dialCode': '+351'},
    {'name': 'Ireland', 'code': 'IE', 'dialCode': '+353'},
    {'name': 'Poland', 'code': 'PL', 'dialCode': '+48'},
    {'name': 'Romania', 'code': 'RO', 'dialCode': '+40'},
    {'name': 'Russia', 'code': 'RU', 'dialCode': '+7'},

    // Americas
    {'name': 'Canada', 'code': 'CA', 'dialCode': '+1'},
    {'name': 'Mexico', 'code': 'MX', 'dialCode': '+52'},
    {'name': 'Brazil', 'code': 'BR', 'dialCode': '+55'},
    {'name': 'Argentina', 'code': 'AR', 'dialCode': '+54'},
    {'name': 'Colombia', 'code': 'CO', 'dialCode': '+57'},
    {'name': 'Chile', 'code': 'CL', 'dialCode': '+56'},
    {'name': 'Peru', 'code': 'PE', 'dialCode': '+51'},
    {'name': 'Venezuela', 'code': 'VE', 'dialCode': '+58'},

    // Oceania
    {'name': 'Australia', 'code': 'AU', 'dialCode': '+61'},
    {'name': 'New Zealand', 'code': 'NZ', 'dialCode': '+64'},
    {'name': 'Fiji', 'code': 'FJ', 'dialCode': '+679'},
    {'name': 'Papua New Guinea', 'code': 'PG', 'dialCode': '+675'},
  ];

  /// Get country by ISO code
  static Map<String, String>? getCountryByCode(String code) {
    try {
      return countries.firstWhere(
        (country) => country['code']?.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get country by dial code
  static Map<String, String>? getCountryByDialCode(String dialCode) {
    try {
      final code = dialCode.startsWith('+') ? dialCode : '+$dialCode';
      return countries.firstWhere(
        (country) => country['dialCode'] == code,
      );
    } catch (_) {
      return null;
    }
  }

  /// Search countries by name or code
  static List<Map<String, String>> searchCountries(String query) {
    final lowercaseQuery = query.toLowerCase();
    return countries.where((country) {
      final name = country['name']?.toLowerCase() ?? '';
      final code = country['code']?.toLowerCase() ?? '';
      final dialCode = country['dialCode']?.toLowerCase() ?? '';
      return name.contains(lowercaseQuery) ||
          code.contains(lowercaseQuery) ||
          dialCode.contains(lowercaseQuery);
    }).toList();
  }
}
