import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/investor_preferences.dart';
import '../bloc/investor_preferences/investor_preferences_bloc.dart';
import '../bloc/investor_preferences/investor_preferences_event.dart';
import '../bloc/investor_preferences/investor_preferences_state.dart';

const List<String> kSectors = [
  'HealthTech',
  'FinTech',
  'EdTech',
  'AI / ML',
  'SaaS',
  'CleanTech',
  'Deep Tech',
  'Consumer',
  'Logistics',
  'Other',
];

const List<String> kStages = [
  'Pre-seed',
  'Seed',
  'Series A',
  'Series B',
  'Growth',
];

const List<String> kGeos = [
  'Egypt',
  'UAE',
  'Saudi Arabia',
  'Jordan',
  'Qatar',
  'Bahrain',
  'Kuwait',
  'Global',
];

const List<String> kDealTypes = [
  'Equity',
  'SAFE',
  'Convertible Note',
  'Revenue Share',
];

const List<String> kTicketPresets = [
  '\$10K',
  '\$50K',
  '\$100K',
  '\$250K',
  '\$500K',
  '\$1M+',
];

class InvestorPreferencesPage extends StatefulWidget {
  const InvestorPreferencesPage({super.key});

  @override
  State<InvestorPreferencesPage> createState() =>
      _InvestorPreferencesPageState();
}

class _InvestorPreferencesPageState extends State<InvestorPreferencesPage> {
  late List<String> _sectors;
  late List<String> _stages;
  late List<String> _geos;
  late List<String> _dealTypes;

  late TextEditingController _ticketMinController;
  late TextEditingController _ticketMaxController;
  late TextEditingController _thesisController;

  late bool _coInvesting;
  late bool _advisory;
  late bool _boardSeats;
  late bool _notifyMatches;
  late bool _notifyMessages;

  bool _initialized = false;
  bool _savedBannerVisible = false;

  @override
  void initState() {
    super.initState();
    _ticketMinController = TextEditingController();
    _ticketMaxController = TextEditingController();
    _thesisController = TextEditingController();

    // Ensure preferences are loaded from dedicated InvestorPreferencesBloc
    context
        .read<InvestorPreferencesBloc>()
        .add(const LoadInvestorPreferencesEvent());
  }

  void _initFields(InvestorPreferences prefs) {
    if (_initialized) return;
    _sectors = List.from(prefs.sectors);
    _stages = List.from(prefs.stages);
    _geos = List.from(prefs.countries);
    _dealTypes = List.from(prefs.dealTypes);

    _ticketMinController.text = prefs.ticketMin;
    _ticketMaxController.text = prefs.ticketMax;
    _thesisController.text = prefs.investmentThesis;

    _coInvesting = prefs.openToCoInvesting;
    _advisory = prefs.advisoryRoles;
    _boardSeats = prefs.boardSeats;
    _notifyMatches = prefs.notifyMatches;
    _notifyMessages = prefs.notifyMessages;
    _initialized = true;
  }

  @override
  void dispose() {
    _ticketMinController.dispose();
    _ticketMaxController.dispose();
    _thesisController.dispose();
    super.dispose();
  }

  void _toggleItem(List<String> list, String item) {
    setState(() {
      if (list.contains(item)) {
        if (list.length > 1) list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  void _applyPreset(String preset) {
    setState(() {
      if (_ticketMinController.text.isEmpty ||
          _ticketMinController.text == preset) {
        _ticketMinController.text = preset;
      } else if (_ticketMaxController.text.isEmpty ||
          _ticketMaxController.text == preset) {
        _ticketMaxController.text = preset;
      } else {
        _ticketMinController.text = preset;
        _ticketMaxController.text = '';
      }
    });
  }

  void _onSave() {
    final updatedPrefs = InvestorPreferences(
      sectors: _sectors,
      stages: _stages,
      countries: _geos,
      ticketMin: _ticketMinController.text.trim(),
      ticketMax: _ticketMaxController.text.trim(),
      dealTypes: _dealTypes,
      investmentThesis: _thesisController.text.trim(),
      openToCoInvesting: _coInvesting,
      advisoryRoles: _advisory,
      boardSeats: _boardSeats,
      notifyMatches: _notifyMatches,
      notifyMessages: _notifyMessages,
      isCompleted: true,
    );

    context
        .read<InvestorPreferencesBloc>()
        .add(UpdateInvestorPreferencesEvent(updatedPrefs));

    setState(() => _savedBannerVisible = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _savedBannerVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestorPreferencesBloc, InvestorPreferencesState>(
      listener: (context, state) {
        if (state is InvestorPreferencesLoaded &&
            state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is InvestorPreferencesLoading ||
            state is InvestorPreferencesInitial) {
          return const Scaffold(
            backgroundColor: AppColors.grayBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is InvestorPreferencesLoaded) {
          _initFields(state.preferences);
          final isSaving = state.isSaving;

          return Scaffold(
            backgroundColor: AppColors.grayBackground,
            appBar: AppBar(
              title: const Text('Investment Preferences'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : _onSave,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saved Success Banner
                  if (_savedBannerVisible) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.successDark,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Preferences saved — your matches will update',
                              style: TextStyle(
                                color: AppColors.successDark,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Preferred Sectors Card
                  _CardContainer(
                    title: 'PREFERRED SECTORS',
                    child: _ChipWrap(
                      items: kSectors,
                      selectedList: _sectors,
                      onToggle: (item) => _toggleItem(_sectors, item),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Stage Preferences Card
                  _CardContainer(
                    title: 'STAGE PREFERENCES',
                    child: _ChipWrap(
                      items: kStages,
                      selectedList: _stages,
                      onToggle: (item) => _toggleItem(_stages, item),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Ticket Size Card with Inputs and Presets
                  _CardContainer(
                    title: 'TICKET SIZE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Min',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _ticketMinController,
                                    decoration: InputDecoration(
                                      prefixText: '\$ ',
                                      hintText: '50K',
                                      filled: true,
                                      fillColor: AppColors.grayBackground,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.cardBorder,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.cardBorder,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Max',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _ticketMaxController,
                                    decoration: InputDecoration(
                                      prefixText: '\$ ',
                                      hintText: '500K',
                                      filled: true,
                                      fillColor: AppColors.grayBackground,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.cardBorder,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.cardBorder,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: kTicketPresets.map((preset) {
                            final isActive =
                                _ticketMinController.text == preset ||
                                    _ticketMaxController.text == preset;
                            return InkWell(
                              onTap: () => _applyPreset(preset),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryLight
                                      : AppColors.grayBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.cardBorder,
                                  ),
                                ),
                                child: Text(
                                  preset,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Geographic Focus Card
                  _CardContainer(
                    title: 'GEOGRAPHIC FOCUS',
                    child: _ChipWrap(
                      items: kGeos,
                      selectedList: _geos,
                      onToggle: (item) => _toggleItem(_geos, item),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Deal Type Card
                  _CardContainer(
                    title: 'DEAL TYPE',
                    child: _ChipWrap(
                      items: kDealTypes,
                      selectedList: _dealTypes,
                      onToggle: (item) => _toggleItem(_dealTypes, item),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Investment Thesis Box
                  _CardContainer(
                    title: 'INVESTMENT THESIS (OPTIONAL)',
                    child: TextField(
                      controller: _thesisController,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            '"I back founders who deeply understand their market..."',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.grayBackground,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Collaboration & Involvement
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Text(
                            'COLLABORATION & INVOLVEMENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        _ToggleTile(
                          label: 'Open to co-investing',
                          desc: 'Share deals with trusted investor network',
                          value: _coInvesting,
                          onChanged: (val) =>
                              setState(() => _coInvesting = val),
                        ),
                        _ToggleTile(
                          label: 'Advisory roles',
                          desc: 'Available for advisory board seats',
                          value: _advisory,
                          onChanged: (val) => setState(() => _advisory = val),
                        ),
                        _ToggleTile(
                          label: 'Board seats',
                          desc: 'Interested in formal board representation',
                          value: _boardSeats,
                          onChanged: (val) =>
                              setState(() => _boardSeats = val),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Notifications
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Text(
                            'NOTIFICATIONS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        _ToggleTile(
                          label: 'New matches',
                          desc: 'Notify when a startup matches your thesis',
                          value: _notifyMatches,
                          onChanged: (val) =>
                              setState(() => _notifyMatches = val),
                        ),
                        _ToggleTile(
                          label: 'Messages',
                          desc: 'Notify on new founder messages',
                          value: _notifyMessages,
                          onChanged: (val) =>
                              setState(() => _notifyMessages = val),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Save Preferences',
                    width: double.infinity,
                    height: 52,
                    isLoading: isSaving,
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}

class _CardContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  final List<String> items;
  final List<String> selectedList;
  final ValueChanged<String> onToggle;

  const _ChipWrap({
    required this.items,
    required this.selectedList,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedList.contains(item);
        return InkWell(
          onTap: () => onToggle(item),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleTile({
    required this.label,
    required this.desc,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.cardBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
