import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_flags/country_flags.dart';
import 'package:smarttask/core/res/country_res.dart';

class CustomCountryPicker extends StatefulWidget {
  final Function(String countryName) onCountrySelected;
  final ThemeData theme;
  final String initialCountry;

  const CustomCountryPicker({
    super.key,
    required this.onCountrySelected,
    required this.theme,
    required this.initialCountry,
  });

  @override
  State<CustomCountryPicker> createState() => CustomCountryPickerState();
}

class CustomCountryPickerState extends State<CustomCountryPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredCountries = [];
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredCountries = CountryRes.countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void showCountryPicker() {
    setState(() => _isBottomSheetOpen = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
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
                      'Select Country',
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {
                      if (query.isEmpty) {
                        _filteredCountries = CountryRes.countries;
                      } else {
                        _filteredCountries = CountryRes.countries
                            .where((country) => country['name']!
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: 'Search country',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color:
                          widget.theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color:
                          widget.theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              // Country list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.onCountrySelected(country['name']!);
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
                              ],
                            ),
                          ),
                        ),
                        if (index < _filteredCountries.length - 1)
                          Divider(
                            height: 1,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                      ],
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
        _filteredCountries = CountryRes.countries;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: showCountryPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.onTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              widget.initialCountry,
              style: GoogleFonts.plusJakartaSans(
                color: widget.theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
