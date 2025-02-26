import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:math' show max, min;

class CustomPhoneInput extends StatefulWidget {
  final String initialCountryCode;
  final TextEditingController phoneController;
  final Function(String) onCountrySelected;
  final FormFieldValidator<String> validator;
  final ThemeData theme;
  final bool isRequired;

  const CustomPhoneInput({
    super.key,
    required this.initialCountryCode,
    required this.phoneController,
    required this.onCountrySelected,
    required this.validator,
    required this.theme,
    this.isRequired = false,
  });

  @override
  State<CustomPhoneInput> createState() => CustomPhoneInputState();
}

class CustomPhoneInputState extends State<CustomPhoneInput> {
  late String _selectedCountryDialCode;
  late String _selectedCountryIsoCode;
  bool _isBottomSheetOpen = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredCountries = [];

  final List<Map<String, String>> _countries = [
    // Major Economies (by GDP)
    {'name': 'United States', 'code': 'US', 'dialCode': '+1'},
    {'name': 'China', 'code': 'CN', 'dialCode': '+86'},
    {'name': 'Japan', 'code': 'JP', 'dialCode': '+81'},
    {'name': 'Germany', 'code': 'DE', 'dialCode': '+49'},
    {'name': 'India', 'code': 'IN', 'dialCode': '+91'},
    {'name': 'United Kingdom', 'code': 'GB', 'dialCode': '+44'},
    {'name': 'France', 'code': 'FR', 'dialCode': '+33'},
    {'name': 'Italy', 'code': 'IT', 'dialCode': '+39'},
    {'name': 'Canada', 'code': 'CA', 'dialCode': '+1'},
    {'name': 'South Korea', 'code': 'KR', 'dialCode': '+82'},
    {'name': 'Russia', 'code': 'RU', 'dialCode': '+7'},
    {'name': 'Brazil', 'code': 'BR', 'dialCode': '+55'},
    {'name': 'Australia', 'code': 'AU', 'dialCode': '+61'},
    // East Africa
    {'name': 'Ethiopia', 'code': 'ET', 'dialCode': '+251'},
    {'name': 'Kenya', 'code': 'KE', 'dialCode': '+254'},
    {'name': 'Sudan', 'code': 'SD', 'dialCode': '+249'},
    {'name': 'Djibouti', 'code': 'DJ', 'dialCode': '+253'},

    // Middle East (Major Markets)
    {'name': 'Saudi Arabia', 'code': 'SA', 'dialCode': '+966'},
    {'name': 'United Arab Emirates', 'code': 'AE', 'dialCode': '+971'},
    {'name': 'Qatar', 'code': 'QA', 'dialCode': '+974'},
    {'name': 'Kuwait', 'code': 'KW', 'dialCode': '+965'},
    {'name': 'Bahrain', 'code': 'BH', 'dialCode': '+973'},
    {'name': 'Israel', 'code': 'IL', 'dialCode': '+972'},
    {'name': 'Turkey', 'code': 'TR', 'dialCode': '+90'},

    // Other Significant Economies
    {'name': 'Singapore', 'code': 'SG', 'dialCode': '+65'},
    {'name': 'Switzerland', 'code': 'CH', 'dialCode': '+41'},
    {'name': 'Netherlands', 'code': 'NL', 'dialCode': '+31'},
    {'name': 'Spain', 'code': 'ES', 'dialCode': '+34'},
    {'name': 'Mexico', 'code': 'MX', 'dialCode': '+52'},
    {'name': 'Indonesia', 'code': 'ID', 'dialCode': '+62'},
    {'name': 'Malaysia', 'code': 'MY', 'dialCode': '+60'},
    {'name': 'Thailand', 'code': 'TH', 'dialCode': '+66'},
    {'name': 'Egypt', 'code': 'EG', 'dialCode': '+20'},
    {'name': 'South Africa', 'code': 'ZA', 'dialCode': '+27'},
    {'name': 'Nigeria', 'code': 'NG', 'dialCode': '+234'},

    // Additional Countries by Region
    // Europe
    {'name': 'Sweden', 'code': 'SE', 'dialCode': '+46'},
    {'name': 'Norway', 'code': 'NO', 'dialCode': '+47'},
    {'name': 'Denmark', 'code': 'DK', 'dialCode': '+45'},
    {'name': 'Finland', 'code': 'FI', 'dialCode': '+358'},
    {'name': 'Belgium', 'code': 'BE', 'dialCode': '+32'},
    {'name': 'Austria', 'code': 'AT', 'dialCode': '+43'},
    {'name': 'Ireland', 'code': 'IE', 'dialCode': '+353'},
    {'name': 'Portugal', 'code': 'PT', 'dialCode': '+351'},
    {'name': 'Greece', 'code': 'GR', 'dialCode': '+30'},
    {'name': 'Poland', 'code': 'PL', 'dialCode': '+48'},

    // Asia
    {'name': 'Vietnam', 'code': 'VN', 'dialCode': '+84'},
    {'name': 'Philippines', 'code': 'PH', 'dialCode': '+63'},
    {'name': 'Pakistan', 'code': 'PK', 'dialCode': '+92'},
    {'name': 'Bangladesh', 'code': 'BD', 'dialCode': '+880'},
    {'name': 'Taiwan', 'code': 'TW', 'dialCode': '+886'},
    {'name': 'Hong Kong', 'code': 'HK', 'dialCode': '+852'},

    // Americas
    {'name': 'Mexico', 'code': 'MX', 'dialCode': '+52'},
    {'name': 'Argentina', 'code': 'AR', 'dialCode': '+54'},
    {'name': 'Colombia', 'code': 'CO', 'dialCode': '+57'},
    {'name': 'Chile', 'code': 'CL', 'dialCode': '+56'},
    {'name': 'Peru', 'code': 'PE', 'dialCode': '+51'},
    {'name': 'Venezuela', 'code': 'VE', 'dialCode': '+58'},

    // Africa
    {'name': 'Morocco', 'code': 'MA', 'dialCode': '+212'},
    {'name': 'Ghana', 'code': 'GH', 'dialCode': '+233'},
    {'name': 'Tanzania', 'code': 'TZ', 'dialCode': '+255'},
    {'name': 'Uganda', 'code': 'UG', 'dialCode': '+256'},
    {'name': 'Algeria', 'code': 'DZ', 'dialCode': '+213'},
    {'name': 'Tunisia', 'code': 'TN', 'dialCode': '+216'},
    {'name': 'Rwanda', 'code': 'RW', 'dialCode': '+250'},
    {'name': 'Mozambique', 'code': 'MZ', 'dialCode': '+258'},

    // Oceania
    {'name': 'New Zealand', 'code': 'NZ', 'dialCode': '+64'},
    {'name': 'Fiji', 'code': 'FJ', 'dialCode': '+679'},
    {'name': 'Papua New Guinea', 'code': 'PG', 'dialCode': '+675'},

    // Caribbean
    {'name': 'Jamaica', 'code': 'JM', 'dialCode': '+1876'},
    {'name': 'Trinidad & Tobago', 'code': 'TT', 'dialCode': '+1868'},
    {'name': 'Bahamas', 'code': 'BS', 'dialCode': '+1242'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountryDialCode = '+251';
    _selectedCountryIsoCode = 'ET';
    _filteredCountries = _countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleTapOutside() {
    FocusScope.of(context).unfocus();
    closeBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isRequired)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Phone Number',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: ' *',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.onTertiary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.onTertiary.withOpacity(0.7),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(15),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: widget.theme.primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showCountryPicker,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color:
                                    widget.theme.primaryColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: CountryFlag.fromCountryCode(
                                _getCurrentCountry()['code']!,
                                height: 18,
                                width: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _getCurrentCountry()['dialCode']!,
                            style: GoogleFonts.plusJakartaSans(
                              color: widget.theme.colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: _isBottomSheetOpen ? 0.5 : 0,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: widget.theme.colorScheme.onSurface
                                  .withOpacity(0.7),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.phoneController,
                  validator: widget.validator,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    hintText: 'Enter phone number',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color:
                          widget.theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    errorStyle: const TextStyle(height: 0),
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _getCurrentCountry() {
    return _countries.firstWhere(
      (country) =>
          country['dialCode'] == _selectedCountryDialCode &&
          country['code'] == _selectedCountryIsoCode,
      orElse: () => _countries.first,
    );
  }

  void _showCountryPicker() {
    setState(() => _isBottomSheetOpen = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Bottom sheet handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Country List',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: widget.theme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.onTertiary,
                  border: Border.all(
                    color: widget.theme.primaryColor.withOpacity(0.1),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.search,
                        size: 20,
                        color:
                            widget.theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          setModalState(() {
                            if (query.isEmpty) {
                              _filteredCountries = List.from(_countries);
                            } else {
                              _filteredCountries = _countries.where((country) {
                                final name = country['name']!.toLowerCase();
                                final code = country['code']!.toLowerCase();
                                final dialCode =
                                    country['dialCode']!.toLowerCase();
                                return name.contains(query.toLowerCase()) ||
                                    code.contains(query.toLowerCase()) ||
                                    dialCode.contains(query.toLowerCase());
                              }).toList();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search country',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: widget.theme.colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: widget.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20,
                          color: widget.theme.colorScheme.onSurface
                              .withOpacity(0.5),
                        ),
                        onPressed: () => _searchController.clear(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
              // Country list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredCountries.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: widget.theme.primaryColor.withOpacity(0.05),
                  ),
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCountryDialCode = country['dialCode']!;
                          _selectedCountryIsoCode = country['code']!;
                          widget.onCountrySelected(country['dialCode']!);
                        });
                        Navigator.pop(context);
                        _searchController.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CountryFlag.fromCountryCode(
                                country['code']!,
                                height: 24,
                                width: 36,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                country['name']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              country['dialCode']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                color: widget.theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isBottomSheetOpen = false;
        _searchController.clear();
        _filteredCountries = _countries;
      });
    });
  }

  void closeBottomSheet() {
    if (_isBottomSheetOpen) {
      setState(() {
        _isBottomSheetOpen = false;
        _searchController.clear();
        _filteredCountries = _countries;
      });
    }
  }
}
