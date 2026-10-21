import 'package:flutter/material.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/app_colors.dart';

class LocationSelection {
  final Country country;
  final String governorate;

  const LocationSelection({
    required this.country,
    required this.governorate,
  });

  String get formatted => '$governorate, ${country.name}';
}

class LocationPickerBottomSheet extends StatefulWidget {
  final Country initialCountry;
  final String? initialGovernorate;

  const LocationPickerBottomSheet({
    super.key,
    required this.initialCountry,
    this.initialGovernorate,
  });

  static Future<LocationSelection?> show(
    BuildContext context, {
    required Country initialCountry,
    String? initialGovernorate,
  }) {
    return showModalBottomSheet<LocationSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LocationPickerBottomSheet(
        initialCountry: initialCountry,
        initialGovernorate: initialGovernorate,
      ),
    );
  }

  @override
  State<LocationPickerBottomSheet> createState() =>
      _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState extends State<LocationPickerBottomSheet> {
  int _step = 1; // 1: Country, 2: Governorate/City
  late Country _chosenCountry;
  String? _chosenGovernorate;

  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = AppCountries.list;
  List<String> _filteredGovernorates = [];

  @override
  void initState() {
    super.initState();
    _chosenCountry = widget.initialCountry;
    _chosenGovernorate = widget.initialGovernorate;
    _filteredGovernorates = AppCountries.getGovernorates(_chosenCountry.code);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (_step == 1) {
        if (query.isEmpty) {
          _filteredCountries = AppCountries.list;
        } else {
          _filteredCountries = AppCountries.list.where((c) {
            return c.name.toLowerCase().contains(query) ||
                c.code.toLowerCase().contains(query);
          }).toList();
        }
      } else {
        final allGovs = AppCountries.getGovernorates(_chosenCountry.code);
        if (query.isEmpty) {
          _filteredGovernorates = allGovs;
        } else {
          _filteredGovernorates = allGovs
              .where((g) => g.toLowerCase().contains(query))
              .toList();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCountry(Country country) {
    setState(() {
      _chosenCountry = country;
      _filteredGovernorates = AppCountries.getGovernorates(country.code);
      _searchController.clear();
      _step = 2;
    });
  }

  void _selectGovernorate(String governorate) {
    Navigator.pop(
      context,
      LocationSelection(
        country: _chosenCountry,
        governorate: governorate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (_step == 2)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: () {
                      setState(() {
                        _step = 1;
                        _searchController.clear();
                      });
                    },
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _step == 1
                            ? 'Step 1: Select Country'
                            : 'Step 2: Select Governorate / City in ${_chosenCountry.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _step == 1
                            ? 'Choose your country of residence'
                            : '${_chosenCountry.flagEmoji} ${_chosenCountry.name} · Default Currency: ${_chosenCountry.currencyCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _step == 1
                    ? 'Search country name, code...'
                    : 'Search governorate or city...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: const Color(0xFFF9FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Content List
          Expanded(
            child: _step == 1
                ? _buildCountriesList()
                : _buildGovernoratesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesList() {
    if (_filteredCountries.isEmpty) {
      return const Center(
        child: Text(
          'No countries found.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredCountries.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.cardBorder),
      itemBuilder: (context, index) {
        final c = _filteredCountries[index];
        final isSelected = c.code == _chosenCountry.code;

        return ListTile(
          onTap: () => _selectCountry(c),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Text(
            c.flagEmoji,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(
            c.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${c.code} · ${c.currencyCode} (${c.currencySymbol})',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
            size: 18,
          ),
        );
      },
    );
  }

  Widget _buildGovernoratesList() {
    if (_filteredGovernorates.isEmpty) {
      return const Center(
        child: Text(
          'No governorates found matching your search.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredGovernorates.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.cardBorder),
      itemBuilder: (context, index) {
        final gov = _filteredGovernorates[index];
        final isSelected = gov == _chosenGovernorate;

        return ListTile(
          onTap: () => _selectGovernorate(gov),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF0FF) : const Color(0xFFF0F2F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_city,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          title: Text(
            gov,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                )
              : null,
        );
      },
    );
  }
}
