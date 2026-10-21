import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/startups.dart';
import '../bloc/startups_bloc.dart';
import '../bloc/startups_event.dart';
import '../widgets/custom_startup_image.dart';
import '../widgets/startup_member_tile.dart';

class StartupWizardPage extends StatefulWidget {
  const StartupWizardPage({
    super.key,
    this.initialStartup,
    this.initialStep = 0,
  });

  final StartupEntity? initialStartup;
  final int initialStep;

  @override
  State<StartupWizardPage> createState() => _StartupWizardPageState();
}

class _StartupWizardPageState extends State<StartupWizardPage> {
  late int _currentStep;

  // Controllers - Step 1: Basic Info & Branding
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;
  late final TextEditingController _websiteController;
  late final TextEditingController _customIndustryController;
  late final TextEditingController _cityController;

  String _selectedIndustry = 'FinTech';
  String _selectedStage = 'MVP Ready';
  int _foundedYear = 2026;
  String? _logoUrl;
  String? _coverImageUrl;

  // Controllers - Step 2: Pitch & Global Investment Round
  late final TextEditingController _problemController;
  late final TextEditingController _solutionController;
  late final TextEditingController _businessModelController;
  late final TextEditingController _targetMarketController;
  late final TextEditingController _targetRaiseController;
  late final TextEditingController _minTicketController;
  late final TextEditingController _activeUsersController;
  late final TextEditingController _monthlyRevenueController;
  late final TextEditingController _valuationCapController;
  late final TextEditingController _growthRateController;
  late final TextEditingController _useOfFundsController;
  String _selectedFundingRound = 'Seed Round';

  // Step 3: Team & Media
  late final TextEditingController _demoUrlController;
  late List<StartupMemberEntity> _members;

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  String? _validateUrl(String? value, String fieldName, {bool isRequired = false}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (isRequired) return '$fieldName is required';
      return null;
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/[^\s]*)?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(trimmed)) {
      return 'Please enter a valid link (e.g. https://example.com)';
    }

    if (trimmed.contains('://') &&
        !trimmed.toLowerCase().startsWith('http://') &&
        !trimmed.toLowerCase().startsWith('https://')) {
      return 'Link must start with http:// or https://';
    }

    return null;
  }

  final List<String> _industryOptions = [
    'FinTech',
    'Artificial Intelligence (AI)',
    'HealthTech',
    'EdTech',
    'E-Commerce',
    'Logistics & Supply Chain',
    'CleanTech & Energy',
    'AgriTech',
    'CyberSecurity',
    'PropTech & Real Estate',
    'Gaming & Entertainment',
    'Other (Specify Custom)',
  ];

  final List<String> _stageOptions = [
    'Ideation',
    'MVP Ready',
    'Early Traction',
    'Scaling & Growth',
  ];

  final List<String> _fundingRoundOptions = [
    'Pre-Seed',
    'Seed Round',
    'Series A',
    'Series B',
    'Bridge Round',
  ];

  final List<String> _popularCities = [
    'Cairo, Egypt',
    'Alexandria, Egypt',
    'Giza, Egypt',
    'Mansoura, Egypt',
    'Tanta, Egypt',
    'Assiut, Egypt',
    'Riyadh, Saudi Arabia',
    'Jeddah, Saudi Arabia',
    'Dubai, UAE',
    'Abu Dhabi, UAE',
    'Amman, Jordan',
    'Casablanca, Morocco',
    'Doha, Qatar',
    'Manama, Bahrain',
    'Kuwait City, Kuwait',
  ];

  final List<int> _yearOptions =
      List.generate(47, (index) => 2026 - index);

  final List<Map<String, String>> _sampleLogos = [
    {
      'title': 'AI Tech',
      'url': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200',
    },
    {
      'title': 'FinTech',
      'url': 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=200',
    },
    {
      'title': 'SaaS Cloud',
      'url': 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=200',
    },
    {
      'title': 'Venture',
      'url': 'https://images.unsplash.com/photo-1542744094-3a31f272c490?w=200',
    },
    {
      'title': 'Bio & Health',
      'url': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=200',
    },
  ];

  final List<Map<String, String>> _sampleCovers = [
    {
      'title': 'Venture Violet',
      'url': 'https://images.unsplash.com/photo-1557683316-973673baf926?w=1000',
    },
    {
      'title': 'Silicon Gradient',
      'url': 'https://images.unsplash.com/photo-1579546929662-711aa81148cf?w=1000',
    },
    {
      'title': 'Global Tech Hub',
      'url': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1000',
    },
    {
      'title': 'Modern HQ',
      'url': 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1000',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    final init = widget.initialStartup;
    _nameController = TextEditingController(text: init?.name ?? '');
    _taglineController = TextEditingController(text: init?.tagline ?? '');
    _websiteController = TextEditingController(text: init?.websiteUrl ?? '');
    _demoUrlController = TextEditingController(text: init?.demoUrl ?? '');
    _customIndustryController = TextEditingController();
    _cityController =
        TextEditingController(text: init?.cityName ?? 'Cairo, Egypt');

    if (init != null) {
      if (_industryOptions.contains(init.industryName)) {
        _selectedIndustry = init.industryName;
      } else {
        _selectedIndustry = 'Other (Specify Custom)';
        _customIndustryController.text = init.industryName;
      }

      if (_stageOptions.contains(init.stageName)) {
        _selectedStage = init.stageName;
      }
      if (_fundingRoundOptions.contains(init.fundingRound)) {
        _selectedFundingRound = init.fundingRound;
      }
      _foundedYear = init.foundedYear;
      _logoUrl = init.logoUrl;
      _coverImageUrl = init.coverImageUrl;
    }

    _problemController = TextEditingController(text: init?.problem ?? '');
    _solutionController = TextEditingController(text: init?.solution ?? '');
    _businessModelController =
        TextEditingController(text: init?.businessModel ?? '');
    _targetMarketController =
        TextEditingController(text: init?.targetMarket ?? '');

    _targetRaiseController =
        TextEditingController(text: _extractDigits(init?.targetRaise, '250000'));
    _minTicketController =
        TextEditingController(text: _extractDigits(init?.minTicket, '5000'));
    _valuationCapController =
        TextEditingController(text: _extractDigits(init?.valuationCap, '2500000'));
    _growthRateController =
        TextEditingController(text: _extractDigits(init?.growthRate, '18'));
    _useOfFundsController = TextEditingController(
        text: init?.useOfFunds ??
            '45% Product & Tech, 35% Marketing, 20% Operations');
    _activeUsersController =
        TextEditingController(text: init?.activeUsers ?? '15,000+');
    _monthlyRevenueController =
        TextEditingController(text: _extractDigits(init?.monthlyRevenue, '12000'));

    _members = init != null ? List.from(init.members) : [];
  }

  static String _extractDigits(String? value, String fallback) {
    if (value == null || value.isEmpty) return fallback;
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isNotEmpty ? digits : fallback;
  }

  static String _formatCurrency(String digits, String fallback) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return fallback;
    final numVal = int.tryParse(clean);
    if (numVal == null) return fallback;
    final formatted = numVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$formatted';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _websiteController.dispose();
    _demoUrlController.dispose();
    _customIndustryController.dispose();
    _cityController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _businessModelController.dispose();
    _targetMarketController.dispose();
    _targetRaiseController.dispose();
    _minTicketController.dispose();
    _valuationCapController.dispose();
    _growthRateController.dispose();
    _useOfFundsController.dispose();
    _activeUsersController.dispose();
    _monthlyRevenueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          if (isLogo) {
            _logoUrl = image.path;
          } else {
            _coverImageUrl = image.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _onNextStep() {
    if (_currentStep == 0) {
      if (!_step1FormKey.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_step2FormKey.currentState!.validate()) return;
    } else if (_currentStep == 2) {
      if (!_step3FormKey.currentState!.validate()) return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _saveStartup();
    }
  }

  void _onPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _saveStartup() {
    final existing = widget.initialStartup;
    final finalIndustry = _selectedIndustry == 'Other (Specify Custom)'
        ? (_customIndustryController.text.trim().isNotEmpty
            ? _customIndustryController.text.trim()
            : 'Tech Innovation')
        : _selectedIndustry;

    final finalCity = _cityController.text.trim().isNotEmpty
        ? _cityController.text.trim()
        : 'Cairo, Egypt';

    final startupToSave = StartupEntity(
      id: existing?.id ?? 'startup-${DateTime.now().millisecondsSinceEpoch}',
      ownerUserId: existing?.ownerUserId ?? 'user-current',
      name: _nameController.text.trim(),
      tagline: _taglineController.text.trim(),
      description: _solutionController.text.trim(),
      problem: _problemController.text.trim(),
      solution: _solutionController.text.trim(),
      businessModel: _businessModelController.text.trim(),
      targetMarket: _targetMarketController.text.trim(),
      industryName: finalIndustry,
      stageName: _selectedStage,
      cityName: finalCity,
      foundedYear: _foundedYear,
      logoUrl: _logoUrl,
      coverImageUrl: _coverImageUrl,
      targetRaise: _formatCurrency(_targetRaiseController.text.trim(), r'$250,000'),
      fundingRound: _selectedFundingRound,
      minTicket: _formatCurrency(_minTicketController.text.trim(), r'$5,000'),
      valuationCap: _formatCurrency(_valuationCapController.text.trim(), r'$2,500,000'),
      securityType: 'SAFE (Post-Money)',
      growthRate: _growthRateController.text.trim().isNotEmpty
          ? '${_growthRateController.text.trim()}% MoM'
          : '18% MoM',
      useOfFunds: _useOfFundsController.text.trim().isNotEmpty
          ? _useOfFundsController.text.trim()
          : '45% Product & Tech, 35% Marketing, 20% Operations',
      activeUsers: _activeUsersController.text.trim().isNotEmpty
          ? _activeUsersController.text.trim()
          : '15,000+',
      monthlyRevenue: _monthlyRevenueController.text.trim().isNotEmpty
          ? '${_formatCurrency(_monthlyRevenueController.text.trim(), r'$12,000')}/mo'
          : r'$12,000/mo',
      websiteUrl: _websiteController.text.trim().isNotEmpty
          ? _websiteController.text.trim()
          : null,
      demoUrl: _demoUrlController.text.trim().isNotEmpty
          ? _demoUrlController.text.trim()
          : null,
      verificationStatus: existing?.verificationStatus ?? 'unverified',
      isPublished: true,
      profileCompletion: _calculateCompletion(),
      members: _members,
    );

    final isEditing = widget.initialStartup != null;
    try {
      context
          .read<StartupsBloc>()
          .add(SaveStartupEvent(startupToSave, isEditing: isEditing));
    } catch (e) {
      debugPrint('StartupsBloc error or not in context: ');
    }
    Navigator.pop(context, startupToSave);
  }

  int _calculateCompletion() {
    int score = 40;
    if (_problemController.text.isNotEmpty) score += 15;
    if (_solutionController.text.isNotEmpty) score += 15;
    if (_members.isNotEmpty) score += 15;
    if (_websiteController.text.isNotEmpty) score += 15;
    return score.clamp(0, 100);
  }

  Widget _buildMediaOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.28), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoPicker() {
    final urlController = TextEditingController(
      text: (_logoUrl != null && _logoUrl!.startsWith('http')) ? _logoUrl! : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Company Logo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Square format recommended (Min 400×400px)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Upload Action Cards (Gallery, Device Files, Camera)
              Row(
                children: [
                  Expanded(
                    child: _buildMediaOptionCard(
                      icon: Icons.photo_library_rounded,
                      title: 'Gallery',
                      subtitle: 'Photos app',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(true, ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMediaOptionCard(
                      icon: Icons.folder_open_rounded,
                      title: 'Files',
                      subtitle: 'Device storage',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(true, ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMediaOptionCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      subtitle: 'Take photo',
                      color: AppColors.linkedInBlue,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(true, ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 8),

              // Curated Presets
              const Text(
                'Or choose from curated startup logos:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleLogos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _sampleLogos[index];
                    final isSelected = _logoUrl == item['url'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _logoUrl = item['url']);
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2.5 : 1,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(item['url']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: isSelected
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_rounded, color: AppColors.white, size: 22),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['title']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),

              // Web URL Option
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'Or enter direct image web URL',
                  hintText: 'https://example.com/logo.png',
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  if (urlController.text.trim().isNotEmpty) {
                    setState(() => _logoUrl = urlController.text.trim());
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Apply Web URL', style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              // Remove Option
              if (_logoUrl != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _logoUrl = null);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                  label: const Text(
                    'Remove Current Logo',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCoverPicker() {
    final urlController = TextEditingController(
      text: (_coverImageUrl != null && _coverImageUrl!.startsWith('http'))
          ? _coverImageUrl!
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Cover Banner Photo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Panoramic format recommended (Min 1200×400px)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Upload Action Cards (Gallery, Device Files, Camera)
              Row(
                children: [
                  Expanded(
                    child: _buildMediaOptionCard(
                      icon: Icons.photo_library_rounded,
                      title: 'Gallery',
                      subtitle: 'Photos app',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(false, ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMediaOptionCard(
                      icon: Icons.folder_open_rounded,
                      title: 'Files',
                      subtitle: 'Device storage',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(false, ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMediaOptionCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      subtitle: 'Take photo',
                      color: AppColors.linkedInBlue,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(false, ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 8),

              // Curated Presets
              const Text(
                'Or choose from curated startup banners:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleCovers.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _sampleCovers[index];
                    final isSelected = _coverImageUrl == item['url'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _coverImageUrl = item['url']);
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2.5 : 1,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(item['url']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: isSelected
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_rounded, color: AppColors.white, size: 24),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['title']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),

              // Web URL Option
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'Or enter direct banner web URL',
                  hintText: 'https://example.com/banner.jpg',
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  if (urlController.text.trim().isNotEmpty) {
                    setState(() => _coverImageUrl = urlController.text.trim());
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Apply Web URL', style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              // Remove Option
              if (_coverImageUrl != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _coverImageUrl = null);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                  label: const Text(
                    'Remove Cover Banner',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    bool isCofounder = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Team Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role Title (e.g. CTO, CFO, Lead AI) *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Brief Experience / Background',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Co-founder Role'),
                    value: isCofounder,
                    activeThumbColor: AppColors.blue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => isCofounder = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          roleCtrl.text.trim().isEmpty) {
                        return;
                      }
                      setState(() {
                        _members.add(
                          StartupMemberEntity(
                            id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
                            fullName: nameCtrl.text.trim(),
                            roleTitle: roleCtrl.text.trim(),
                            isCofounder: isCofounder,
                            bio: bioCtrl.text.trim().isNotEmpty
                                ? bioCtrl.text.trim()
                                : null,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Member',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditMemberDialog(int index, StartupMemberEntity member) {
    final nameCtrl = TextEditingController(text: member.fullName);
    final roleCtrl = TextEditingController(text: member.roleTitle);
    final bioCtrl = TextEditingController(text: member.bio ?? '');
    bool isCofounder = member.isCofounder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Team Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role Title (e.g. CTO, CFO, Lead AI) *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Brief Experience / Background',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Co-founder Role'),
                    value: isCofounder,
                    activeThumbColor: AppColors.blue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => isCofounder = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          roleCtrl.text.trim().isEmpty) {
                        return;
                      }
                      setState(() {
                        _members[index] = member.copyWith(
                          fullName: nameCtrl.text.trim(),
                          roleTitle: roleCtrl.text.trim(),
                          isCofounder: isCofounder,
                          bio: bioCtrl.text.trim().isNotEmpty
                              ? bioCtrl.text.trim()
                              : null,
                        );
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Member Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialStartup != null;

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Startup Profile' : 'Register New Startup',
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Step Progress Bar
          _buildStepProgress(),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStepContent(),
            ),
          ),

          // Bottom Navigation Buttons
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _buildStepIndicator(
            stepIndex: 0,
            title: 'Basic Info',
            isActive: _currentStep >= 0,
            isCompleted: _currentStep > 0,
          ),
          _buildStepConnector(isCompleted: _currentStep > 0),
          _buildStepIndicator(
            stepIndex: 1,
            title: 'The Pitch & Deal',
            isActive: _currentStep >= 1,
            isCompleted: _currentStep > 1,
          ),
          _buildStepConnector(isCompleted: _currentStep > 1),
          _buildStepIndicator(
            stepIndex: 2,
            title: 'Team & Media',
            isActive: _currentStep >= 2,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepIndex,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: isCompleted
                ? AppColors.success
                : (isActive ? AppColors.navy : AppColors.tint),
            child: isCompleted
                ? const Icon(Icons.check, size: 15, color: AppColors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.white : AppColors.textMuted,
                    ),
                  ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Container(
      width: 14,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? AppColors.success : AppColors.tint,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2PitchAndBusiness();
      case 2:
        return _buildStep3TeamAndMedia();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Basic Info & Visual Branding
  Widget _buildStep1BasicInfo() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 1: Identity & Visual Branding',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add company branding, sector, location, and key identity info.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),

          // Visual Branding Section (Cover Photo + Logo with 100% Reliable Hit-Testing)
          SizedBox(
            height: 195,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Cover Banner
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 140,
                  child: InkWell(
                    onTap: _showCoverPicker,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _coverImageUrl != null
                            ? null
                            : const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CustomStartupImage(
                                imagePath: _coverImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withValues(alpha: 0.22),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: AppColors.white,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Add Startup Cover Banner',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap to choose: Gallery • Files • Presets • Camera',
                                    style: TextStyle(
                                      color: AppColors.white.withValues(alpha: 0.85),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),

                // Cover Banner edit/change pill button (Top Right)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: _showCoverPicker,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded,
                                color: AppColors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              _coverImageUrl != null ? 'Change Cover' : 'Add Cover',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Logo Container & Dedicated Pencil Edit Button (Both directly open Logo Picker)
                Positioned(
                  left: 16,
                  bottom: 6,
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Briefcase / Logo box: click directly opens logo picker
                        Positioned(
                          left: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: _showLogoPicker,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.white, width: 3.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withValues(alpha: 0.16),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _logoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: CustomStartupImage(
                                        imagePath: _logoUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.business_center_rounded,
                                        size: 38,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Edit Pencil Button: explicit, isolated touch target with ripple & dedicated onTap
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: AppColors.primary,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              onTap: _showLogoPicker,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.white, width: 2.5),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 17,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Startup Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Startup Company Name *',
              hintText: 'e.g. Fikraty Tech',
              prefixIcon: Icon(Icons.business_rounded, color: AppColors.navy),
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Company name is required'
                : null,
          ),
          const SizedBox(height: 16),

          // Tagline
          TextFormField(
            controller: _taglineController,
            decoration: const InputDecoration(
              labelText: 'Company Tagline / One-liner *',
              hintText:
                  'A compelling sentence summarizing what your startup does',
              prefixIcon: Icon(Icons.flash_on_rounded, color: AppColors.navy),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Tagline is required' : null,
          ),
          const SizedBox(height: 16),

          // Row: Founded Year & Stage
          Row(
            children: [
              // Founded Year Dropdown
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _foundedYear,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Founded Year *',
                    prefixIcon: Icon(Icons.calendar_today_rounded,
                        color: AppColors.navy),
                    border: OutlineInputBorder(),
                  ),
                  items: _yearOptions
                      .map((y) =>
                          DropdownMenuItem(value: y, child: Text(y.toString())))
                      .toList(),
                  onChanged: (v) => setState(() => _foundedYear = v!),
                ),
              ),
              const SizedBox(width: 12),
              // Stage Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStage,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Growth Stage *',
                    prefixIcon:
                        Icon(Icons.timeline_rounded, color: AppColors.navy),
                    border: OutlineInputBorder(),
                  ),
                  items: _stageOptions
                      .map((stg) =>
                          DropdownMenuItem(
                            value: stg,
                            child: Text(
                              stg,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStage = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Industry Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedIndustry,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Industry Sector *',
              prefixIcon: Icon(Icons.category_rounded, color: AppColors.navy),
              border: OutlineInputBorder(),
            ),
            items: _industryOptions
                .map((ind) => DropdownMenuItem(
                      value: ind,
                      child: Text(
                        ind,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedIndustry = v!),
          ),

          // Dynamic Custom Industry Field if "Other (Specify Custom)" is selected
          if (_selectedIndustry == 'Other (Specify Custom)') ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _customIndustryController,
              decoration: const InputDecoration(
                labelText: 'Specify Custom Industry Sector *',
                hintText: 'e.g. CyberSecurity, PropTech, DeepTech, BioTech...',
                prefixIcon:
                    Icon(Icons.edit_note_rounded, color: AppColors.navy),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (_selectedIndustry ==
                          'Other (Specify Custom)' &&
                      (v == null || v.trim().isEmpty))
                  ? 'Please specify your industry sector'
                  : null,
            ),
          ],
          const SizedBox(height: 16),

          // Headquarters City with Autocomplete & Custom Input
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _cityController.text),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return _popularCities;
              }
              return _popularCities.where((city) => city
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String selection) {
              _cityController.text = selection;
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              controller.addListener(() {
                _cityController.text = controller.text;
              });
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Headquarters City & Location *',
                  hintText: 'Type any city, e.g. Cairo, Alexandria, Dubai...',
                  prefixIcon:
                      Icon(Icons.location_city_rounded, color: AppColors.navy),
                  border: OutlineInputBorder(),
                  helperText:
                      'Select from suggestions or type any city/governorate',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'City location is required'
                    : null,
              );
            },
          ),
          const SizedBox(height: 16),

          // Website
          TextFormField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Official Website URL (Optional)',
              hintText: 'https://example.com',
              prefixIcon: Icon(Icons.language_rounded, color: AppColors.navy),
              border: OutlineInputBorder(),
            ),
            validator: (v) => _validateUrl(v, 'Official Website URL'),
          ),
        ],
      ),
    );
  }

  // STEP 2: Pitch & Global Investment Deal
  Widget _buildStep2PitchAndBusiness() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 2: The Pitch & Investment Deal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Standards 2 & 3: Deal Terms, Valuation & Traction',
                      style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined, size: 14, color: AppColors.badgeReviewText),
                    SizedBox(width: 4),
                    Text(
                      'Global Standard',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.badgeReviewText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CARD 1: Core Pitch Narrative
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'The Pitch Narrative & Model',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Problem
                TextFormField(
                  controller: _problemController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'The Problem *',
                    hintText: 'What critical pain point does your customer face today?',
                    prefixIcon: Icon(Icons.warning_amber_rounded, color: AppColors.navy),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Problem description is required' : null,
                ),
                const SizedBox(height: 14),

                // Solution
                TextFormField(
                  controller: _solutionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'The Innovative Solution *',
                    hintText: 'How does your product solve this problem better than competitors?',
                    prefixIcon: Icon(Icons.check_circle_outline_rounded, color: AppColors.navy),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Solution description is required' : null,
                ),
                const SizedBox(height: 14),

                // Business Model
                TextFormField(
                  controller: _businessModelController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Business & Revenue Model *',
                    hintText: 'e.g. B2B SaaS subscriptions, 2.5% transaction commission',
                    prefixIcon: Icon(Icons.monetization_on_outlined, color: AppColors.navy),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Business model is required'
                      : null,
                ),
                const SizedBox(height: 14),

                // Target Market
                TextFormField(
                  controller: _targetMarketController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Target Market & Audience *',
                    hintText: 'Who are your ideal customers? (e.g. 50K+ SMEs in MENA)',
                    prefixIcon: Icon(Icons.groups_rounded, color: AppColors.navy),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Target market is required'
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // CARD 2: Investment Deal Terms
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Fundraising Ask & Deal Terms',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Specify your round target, valuation ceiling, and minimum ticket',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Row: Target Raise & Round Type
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetRaiseController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Target Raise Goal *',
                          hintText: '250000',
                          prefixText: r'$ ',
                          prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.navy),
                          border: OutlineInputBorder(),
                          helperText: 'Numbers only',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Target raise is required'
                            : (int.tryParse(v.trim()) == null ? 'Digits only' : null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFundingRound,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Funding Round *',
                          prefixIcon: Icon(Icons.stars_rounded, color: AppColors.navy),
                          border: OutlineInputBorder(),
                        ),
                        items: _fundingRoundOptions
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedFundingRound = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row: Valuation Cap & Min Ticket
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valuationCapController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Valuation Cap *',
                          hintText: '2500000',
                          prefixText: r'$ ',
                          prefixIcon: Icon(Icons.pie_chart_outline_rounded, color: AppColors.navy),
                          border: OutlineInputBorder(),
                          helperText: 'Numbers only',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Valuation cap is required'
                            : (int.tryParse(v.trim()) == null ? 'Digits only' : null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minTicketController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Min Check / Ticket *',
                          hintText: '5000',
                          prefixText: r'$ ',
                          prefixIcon: Icon(Icons.confirmation_number_outlined, color: AppColors.navy),
                          border: OutlineInputBorder(),
                          helperText: 'Numbers only',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Min ticket is required'
                            : (int.tryParse(v.trim()) == null ? 'Digits only' : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Planned Use of Funds
                TextFormField(
                  controller: _useOfFundsController,
                  decoration: const InputDecoration(
                    labelText: 'Planned Use of Funds *',
                    hintText: 'e.g. 45% Tech & AI, 35% Customer Acquisition, 20% Team',
                    prefixIcon: Icon(Icons.pie_chart_rounded, color: AppColors.navy),
                    border: OutlineInputBorder(),
                    helperText: 'Transparent breakdown builds trust with accredited investors',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // CARD 3: Key Metrics & Traction
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppColors.success, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Traction & Key Growth Metrics',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Verified quantitative proof that customers want your solution',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Row: Monthly Revenue & MoM Growth
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _monthlyRevenueController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Monthly Revenue (MRR) *',
                          hintText: '12000',
                          prefixText: r'$ ',
                          suffixText: ' /mo',
                          prefixIcon: Icon(Icons.paid_outlined, color: AppColors.success),
                          border: OutlineInputBorder(),
                          helperText: 'Numbers only',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Monthly revenue is required'
                            : (int.tryParse(v.trim()) == null ? 'Digits only' : null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _growthRateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'MoM Growth Rate *',
                          hintText: '18',
                          suffixText: ' % MoM',
                          prefixIcon: Icon(Icons.auto_graph_rounded, color: AppColors.success),
                          border: OutlineInputBorder(),
                          helperText: 'Numbers only',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Growth rate is required'
                            : (int.tryParse(v.trim()) == null ? 'Digits only' : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Active Users / Clients
                TextFormField(
                  controller: _activeUsersController,
                  decoration: const InputDecoration(
                    labelText: 'Active Users / Clients Traction *',
                    hintText: 'e.g. 15,000+ Monthly Active Users or 32 Paid Enterprise Clients',
                    prefixIcon: Icon(Icons.people_alt_outlined, color: AppColors.success),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 3: Team, Demo & Pitch Deck
  Widget _buildStep3TeamAndMedia() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 3: Team, Demo & Pitch Deck',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Investors bet on teams and verified traction. Add key co-founders and demo materials.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Team Members List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Co-Founders & Core Team (${_members.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddMemberDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Member'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_members.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.tint),
              ),
              child: const Center(
                child: Text(
                  'No team members added yet. Add co-founders to increase your credibility with investors.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ..._members.asMap().entries.map((entry) {
              final idx = entry.key;
              final m = entry.value;
              return StartupMemberTile(
                member: m,
                onEditPressed: () => _showEditMemberDialog(idx, m),
                onDeletePressed: () {
                  setState(() => _members.removeAt(idx));
                },
              );
            }),

          const SizedBox(height: 22),

          // Demo URL
          TextFormField(
            controller: _demoUrlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Product Demo URL (Loom, YouTube, Figma prototype)',
              hintText: 'https://...',
              prefixIcon:
                  Icon(Icons.play_circle_outline_rounded, color: AppColors.navy),
              border: OutlineInputBorder(),
            ),
            validator: (v) => _validateUrl(v, 'Product Demo URL'),
          ),
          const SizedBox(height: 18),

          // Pitch Deck Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.navy),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pitch Deck (PDF)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'pitch_deck_v1.pdf (Attached & Ready)',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pitch deck document updated!')),
                    );
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    final isLastStep = _currentStep == 2;
    final isEditing = widget.initialStartup != null;

    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _onPreviousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.navy),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _onNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastStep
                      ? (isEditing ? AppColors.blue : AppColors.success)
                      : AppColors.navy,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isLastStep
                        ? (isEditing
                            ? 'Update Startup Profile'
                            : 'Complete & Launch Startup')
                        : 'Next: ${(_currentStep == 0) ? "The Pitch & Deal" : "Team & Media"} ->',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
