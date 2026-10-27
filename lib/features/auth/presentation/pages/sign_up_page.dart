import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/auth.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

enum _SignUpStep { role, details }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  _SignUpStep _currentStep = _SignUpStep.role;
  UserRole _selectedRole = UserRole.entrepreneur;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _passwordController = TextEditingController();

  // Role-specific: Entrepreneur
  final _professionalTitleController = TextEditingController();
  final _bioController = TextEditingController();
  final Set<String> _selectedExpertise = {'Product', 'Engineering'};
  late final List<String> _expertiseOptions = List.of(Validators.defaultExpertiseOptions);

  // Role-specific: Investor
  final Set<String> _selectedSectors = {'FinTech', 'AI / ML'};
  late final List<String> _sectorOptions = List.of(Validators.defaultSectorOptions);
  final Set<String> _selectedCountries = {'Egypt', 'UAE', 'Saudi Arabia'};
  late final List<String> _countryOptions = List.of(Validators.defaultCountryOptions);
  final Set<String> _selectedStages = {'Seed', 'Series A'};
  late final List<String> _stageOptions = List.of(Validators.defaultStageOptions);
  String _selectedTicketSize = r'$50K – $250K';
  late final List<String> _ticketOptions = List.of(Validators.defaultTicketOptions);
  String _selectedCurrency = Validators.defaultCurrencyOptions.first;
  late final List<String> _currencyOptions = List.of(Validators.defaultCurrencyOptions);
  String _selectedRiskPreference = 'Medium';
  late final List<String> _riskPreferenceOptions = List.of(Validators.defaultRiskPreferenceOptions);

  // Government ID upload (optional during registration)
  String? _idDocumentName;
  int? _idDocumentSizeBytes;
  String? _idDocumentPath;
  bool _showPassword = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedInController.dispose();
    _passwordController.dispose();
    _professionalTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  UserRole? _activeFormRole;

  void _resetAllFormFields() {
    _formKey.currentState?.reset();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _locationController.clear();
    _linkedInController.clear();
    _passwordController.clear();
    _professionalTitleController.clear();
    _bioController.clear();

    _selectedExpertise
      ..clear()
      ..addAll(['Product', 'Engineering']);

    _selectedSectors
      ..clear()
      ..addAll(['FinTech', 'AI / ML']);

    _selectedCountries
      ..clear()
      ..addAll(['Egypt', 'UAE', 'Saudi Arabia']);

    _selectedStages
      ..clear()
      ..addAll(['Seed', 'Series A']);

    _selectedTicketSize = r'$50K – $250K';
    _selectedCurrency = Validators.defaultCurrencyOptions.first;
    _selectedRiskPreference = 'Medium';

    _idDocumentName = null;
    _idDocumentSizeBytes = null;
    _idDocumentPath = null;
    _showPassword = false;
    _localError = null;
  }

  void _onRoleSelected(UserRole role) {
    if (_selectedRole != role) {
      setState(() {
        _selectedRole = role;
        _resetAllFormFields();
      });
    }
  }

  void _onContinueFromRole() {
    setState(() {
      if (_activeFormRole != null && _activeFormRole != _selectedRole) {
        _resetAllFormFields();
      }
      _activeFormRole = _selectedRole;
      _currentStep = _SignUpStep.details;
      _localError = null;
    });
  }

  void _onBack() {
    if (_currentStep == _SignUpStep.details) {
      setState(() {
        _currentStep = _SignUpStep.role;
        _localError = null;
      });
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  Future<void> _pickIdDocument() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Government ID',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your ID card, passport or national identity document',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.selectionTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.file_present_rounded, color: AppColors.primaryPurple),
                ),
                title: const Text('Choose File from Device (PDF, DOC, Images)', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select a PDF document or scan from device storage'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final files = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
                    );
                    if (files.isNotEmpty) {
                      final f = files.first;
                      final sizeBytes = await f.length() ?? 0;
                      setState(() {
                        _idDocumentName = f.name;
                        _idDocumentSizeBytes = sizeBytes;
                        _idDocumentPath = f.path;
                        _localError = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID Document attached: ${f.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open file picker: $e')),
                      );
                    }
                  }
                },
              ),
              const Divider(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.selectionTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryPurple),
                ),
                title: const Text('Select from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Choose photo from image gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(source: ImageSource.gallery);
                    if (file != null) {
                      final sizeBytes = await file.length();
                      setState(() {
                        _idDocumentName = file.name;
                        _idDocumentSizeBytes = sizeBytes;
                        _idDocumentPath = file.path;
                        _localError = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID Photo attached: ${file.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open gallery: $e')),
                      );
                    }
                  }
                },
              ),
              const Divider(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.selectionTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryPurple),
                ),
                title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Take a clear picture of your ID'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(source: ImageSource.camera);
                    if (file != null) {
                      final sizeBytes = await file.length();
                      setState(() {
                        _idDocumentName = file.name;
                        _idDocumentSizeBytes = sizeBytes;
                        _idDocumentPath = file.path;
                        _localError = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID Photo captured: ${file.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open camera: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRegistration() {
    FocusScope.of(context).unfocus();
    setState(() => _localError = null);

    // 1. Text Field Validations (Name, Email, Egyptian Phone, Location, LinkedIn, Password)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Strong Password check
    final passwordError = Validators.strongPassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _localError = passwordError);
      return;
    }

    // 3. Role-specific constraints & predefined tag validation
    if (_selectedRole == UserRole.entrepreneur) {
      final expertiseError = Validators.founderExpertise(
        _selectedExpertise,
        _expertiseOptions,
        false,
      );
      if (expertiseError != null) {
        setState(() => _localError = expertiseError);
        return;
      }
    } else {
      final sectorsError = Validators.investorSectors(
        _selectedSectors,
        _sectorOptions,
      );
      if (sectorsError != null) {
        setState(() => _localError = sectorsError);
        return;
      }
      final countriesError = Validators.investorCountries(
        _selectedCountries,
        _countryOptions,
      );
      if (countriesError != null) {
        setState(() => _localError = countriesError);
        return;
      }
      final stagesError = Validators.investorStages(
        _selectedStages,
        _stageOptions,
      );
      if (stagesError != null) {
        setState(() => _localError = stagesError);
        return;
      }
      final ticketError = Validators.ticketSize(
        _selectedTicketSize,
        _ticketOptions,
      );
      if (ticketError != null) {
        setState(() => _localError = ticketError);
        return;
      }
      final currencyError = Validators.currency(
        _selectedCurrency,
        _currencyOptions,
      );
      if (currencyError != null) {
        setState(() => _localError = currencyError);
        return;
      }
      final riskError = Validators.riskPreference(
        _selectedRiskPreference,
        _riskPreferenceOptions,
      );
      if (riskError != null) {
        setState(() => _localError = riskError);
        return;
      }
    }

    // 4. Government ID Photo upload validation (optional for identity verification)
    if (_idDocumentName != null && _idDocumentName!.trim().isNotEmpty) {
      final idError = Validators.governmentIdDocument(
        _idDocumentName,
        fileSizeBytes: _idDocumentSizeBytes,
        isRequired: false,
      );
      if (idError != null) {
        setState(() => _localError = idError);
        return;
      }
    }

    // Build models matching ERD
    final profile = UserProfileData(
      fullName: _fullNameController.text.trim(),
      professionalTitle: _selectedRole == UserRole.entrepreneur
          ? (_professionalTitleController.text.trim().isEmpty
              ? null
              : _professionalTitleController.text.trim())
          : 'Investor',
      bio: _selectedRole == UserRole.entrepreneur
          ? (_bioController.text.trim().isEmpty ? null : _bioController.text.trim())
          : null,
      location: _locationController.text.trim(),
      cityCode: _locationController.text.trim(),
      linkedinUrl: _linkedInController.text.trim(),
      expertise: _selectedRole == UserRole.entrepreneur ? _selectedExpertise.toList() : const [],
      idDocumentName: _idDocumentName,
      idDocumentUrl: _idDocumentPath,
    );

    InvestorRegistrationData? investorData;
    if (_selectedRole == UserRole.investor) {
      InvestorRiskPreference? riskPref;
      switch (_selectedRiskPreference.toLowerCase()) {
        case 'low':
          riskPref = InvestorRiskPreference.low;
          break;
        case 'high':
          riskPref = InvestorRiskPreference.high;
          break;
        case 'medium':
        default:
          riskPref = InvestorRiskPreference.medium;
          break;
      }

      final currencyCode = _selectedCurrency.split(' ').first;

      investorData = InvestorRegistrationData(
        thesis: 'Targeting: ${_selectedSectors.join(', ')} across ${_selectedCountries.join(', ')}',
        ticketSize: _selectedTicketSize,
        currency: LookupSelection(code: currencyCode, label: _selectedCurrency),
        riskPreference: riskPref,
        preferredIndustries: _selectedSectors
            .map((s) => LookupSelection(code: s.toLowerCase().replaceAll(' ', '-'), label: s))
            .toList(),
        preferredCountries: _selectedCountries
            .map((c) => LookupSelection(code: c, label: c))
            .toList(),
        preferredStages: _selectedStages
            .map((st) => LookupSelection(code: st, label: st))
            .toList(),
      );
    }

    // Normalize phone number (strip whitespace / dashes / prefix to standard 11-digit local)
    final cleanPhone = Validators.normalizePhone(_phoneController.text.trim());

    final registration = RegistrationData(
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
      role: _selectedRole,
      phone: cleanPhone,
      profile: profile,
      investor: investorData,
    );

    context.read<AuthBloc>().add(AuthSignUpRequested(data: registration));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
            } else if (state.status == AuthStatus.failure && state.message != null) {
              setState(() => _localError = state.message);
            }
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _onBack,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.mutedText),
                        label: const Text(
                          'Back',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logo & Brand
                    const AppLogo(size: 38, showText: true),
                    const SizedBox(height: 16),

                    // 2-Step Progress Indicator Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: _currentStep == _SignUpStep.details
                                  ? colors.primary
                                  : AppColors.track,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Render Step 1 (Role) or Step 2 (Details)
                    if (_currentStep == _SignUpStep.role)
                      _buildRoleSelectionStep(colors)
                    else
                      _buildDetailsFormStep(colors),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // STEP 1: ROLE SELECTION
  // =========================================================================
  Widget _buildRoleSelectionStep(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'How will you use Fikraty?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose your primary role to personalize your account.',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 24),

        // Entrepreneur Card
        _buildRoleOptionCard(
          role: UserRole.entrepreneur,
          title: 'Entrepreneur / Founder',
          description:
              'Build your professional network, create a startup profile later, and connect with investors.',
          icon: Icons.rocket_launch_rounded,
          colors: colors,
        ),
        const SizedBox(height: 14),

        // Investor Card
        _buildRoleOptionCard(
          role: UserRole.investor,
          title: 'Investor',
          description:
              'Set your investment thesis, discover relevant startups, and manage your deal pipeline.',
          icon: Icons.trending_up_rounded,
          colors: colors,
        ),
        const SizedBox(height: 32),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _onContinueFromRole,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 3,
              shadowColor: colors.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Footer
        Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signIn),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.subtleText,
                  fontFamily: 'Inter',
                ),
                children: [
                  const TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOptionCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required ColorScheme colors,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () => _onRoleSelected(role),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectionTint : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.primary : AppColors.border,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? AppColors.white : colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? colors.primary : AppColors.darkText,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                    ),
                    child: const Icon(Icons.check, size: 14, color: AppColors.white),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.subtleText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // STEP 2: PROFILE & ROLE DETAILS
  // =========================================================================
  Widget _buildDetailsFormStep(ColorScheme colors) {
    final isEntrepreneur = _selectedRole == UserRole.entrepreneur;
    final pwdReqs = Validators.checkPassword(_passwordController.text);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create your account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEntrepreneur
                ? 'Your personal founder profile only. Startup details come later.'
                : 'Your account and investment thesis in one streamlined form.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 22),

          // Common Fields
          _buildFieldLabel('FULL NAME (FIRST & LAST NAME)'),
          _buildTextField(
            controller: _fullNameController,
            hint: 'Sarah Al-Mansouri',
            colors: colors,
            validator: Validators.fullName,
          ),
          const SizedBox(height: 14),

          _buildFieldLabel('PROFESSIONAL EMAIL'),
          _buildTextField(
            controller: _emailController,
            hint: 'you@company.com',
            colors: colors,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 14),

          _buildFieldLabel('PHONE NUMBER (INTERNATIONAL OR LOCAL)'),
          _buildTextField(
            controller: _phoneController,
            hint: '+20 10 1234 5678 or +1 415 555 2671',
            colors: colors,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
          const SizedBox(height: 14),

          _buildFieldLabel('COUNTRY / CITY OF RESIDENCE'),
          _buildTextField(
            controller: _locationController,
            hint: 'Cairo, Egypt',
            colors: colors,
            validator: Validators.location,
          ),
          const SizedBox(height: 14),

          _buildFieldLabel('LINKEDIN PROFILE URL'),
          _buildTextField(
            controller: _linkedInController,
            hint: 'https://linkedin.com/in/yourname',
            colors: colors,
            keyboardType: TextInputType.url,
            validator: Validators.linkedInUrl,
          ),
          const SizedBox(height: 14),

          _buildFieldLabel('PASSWORD (STRONG SECURITY)'),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            validator: Validators.strongPassword,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
            decoration: _inputDecoration(
              hint: 'Must be strong (e.g. Pass@1234)',
              colors: colors,
              suffix: TextButton(
                onPressed: () => setState(() => _showPassword = !_showPassword),
                child: Text(
                  _showPassword ? 'Hide' : 'Show',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Live Password Strength Checklist
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password Requirements:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                _buildRequirementRow('8 to 128 characters', pwdReqs.hasMinLength && pwdReqs.hasMaxLength, colors),
                _buildRequirementRow('Uppercase letter (A-Z)', pwdReqs.hasUppercase, colors),
                _buildRequirementRow('Lowercase letter (a-z)', pwdReqs.hasLowercase, colors),
                _buildRequirementRow('Number (0-9)', pwdReqs.hasDigit, colors),
                _buildRequirementRow(r'Special character (!@#$%^&*(),.?":{}|<>)', pwdReqs.hasSpecialChar, colors),
                _buildRequirementRow('No leading or trailing spaces', pwdReqs.hasNoSurroundingWhitespace, colors),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Divider Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEntrepreneur ? 'PROFESSIONAL BACKGROUND (OPTIONAL)' : 'INVESTMENT THESIS',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEntrepreneur
                      ? 'Optional background details. You can join Fikraty without professional experience.'
                      : 'Only the essentials used to personalize your deal flow.',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.tertiaryText),
                ),
              ],
            ),
          ),

          // Role-specific sections
          if (isEntrepreneur) ...[
            _buildFieldLabel('CURRENT PROFESSIONAL TITLE (OPTIONAL)'),
            _buildTextField(
              controller: _professionalTitleController,
              hint: 'Product Lead, Engineer, Founder (Optional)',
              colors: colors,
              validator: (v) => Validators.professionalTitle(v, isRequired: false),
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('AREAS OF EXPERTISE (OPTIONAL)'),
            _buildChipGroup(
              options: _expertiseOptions,
              selected: _selectedExpertise,
              colors: colors,
              onToggle: (opt) {
                setState(() {
                  if (_selectedExpertise.contains(opt)) {
                    _selectedExpertise.remove(opt);
                  } else {
                    _selectedExpertise.add(opt);
                  }
                });
              },
              onAddCustom: () {
                _showAddCustomOptionDialog(
                  title: 'Add Custom Expertise',
                  fieldLabel: 'Expertise',
                  hintText: 'e.g. Legal, Data Science, AI Research',
                  currentOptions: _expertiseOptions,
                  onAdded: (customVal) {
                    setState(() {
                      if (!_expertiseOptions.contains(customVal)) {
                        _expertiseOptions.add(customVal);
                      }
                      _selectedExpertise.add(customVal);
                      _localError = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('SHORT PERSONAL BIO (OPTIONAL, 15 - 240 CHARS)'),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 240,
              validator: (v) => Validators.bio(v, isRequired: false),
              style: const TextStyle(fontSize: 14, color: AppColors.darkText),
              decoration: _inputDecoration(
                hint: 'Share your professional background and startup interests (Optional).',
                colors: colors,
              ),
            ),
          ] else ...[
            _buildFieldLabel('TARGET SECTORS / INDUSTRIES (SELECT AT LEAST 1)'),
            _buildChipGroup(
              options: _sectorOptions,
              selected: _selectedSectors,
              colors: colors,
              onToggle: (opt) {
                setState(() {
                  if (_selectedSectors.contains(opt)) {
                    _selectedSectors.remove(opt);
                  } else {
                    _selectedSectors.add(opt);
                  }
                });
              },
              onAddCustom: () {
                _showAddCustomOptionDialog(
                  title: 'Add Target Sector',
                  fieldLabel: 'Sector',
                  hintText: 'e.g. PropTech, BioTech, AgTech',
                  currentOptions: _sectorOptions,
                  onAdded: (customVal) {
                    setState(() {
                      if (!_sectorOptions.contains(customVal)) {
                        _sectorOptions.add(customVal);
                      }
                      _selectedSectors.add(customVal);
                      _localError = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('PREFERRED COUNTRIES (SELECT AT LEAST 1)'),
            _buildChipGroup(
              options: _countryOptions,
              selected: _selectedCountries,
              colors: colors,
              onToggle: (opt) {
                setState(() {
                  if (_selectedCountries.contains(opt)) {
                    _selectedCountries.remove(opt);
                  } else {
                    _selectedCountries.add(opt);
                  }
                });
              },
              onAddCustom: () {
                _showAddCustomOptionDialog(
                  title: 'Add Preferred Country',
                  fieldLabel: 'Country',
                  hintText: 'e.g. Oman, Morocco, United Kingdom',
                  currentOptions: _countryOptions,
                  onAdded: (customVal) {
                    setState(() {
                      if (!_countryOptions.contains(customVal)) {
                        _countryOptions.add(customVal);
                      }
                      _selectedCountries.add(customVal);
                      _localError = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('PREFERRED STARTUP STAGES (SELECT AT LEAST 1)'),
            _buildChipGroup(
              options: _stageOptions,
              selected: _selectedStages,
              colors: colors,
              onToggle: (opt) {
                setState(() {
                  if (_selectedStages.contains(opt)) {
                    _selectedStages.remove(opt);
                  } else {
                    _selectedStages.add(opt);
                  }
                });
              },
              onAddCustom: () {
                _showAddCustomOptionDialog(
                  title: 'Add Preferred Stage',
                  fieldLabel: 'Stage',
                  hintText: 'e.g. Pre-revenue, Series C, Bridge',
                  currentOptions: _stageOptions,
                  onAdded: (customVal) {
                    setState(() {
                      if (!_stageOptions.contains(customVal)) {
                        _stageOptions.add(customVal);
                      }
                      _selectedStages.add(customVal);
                      _localError = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('TYPICAL TICKET SIZE'),
            _buildSingleSelectChipGroup(
              options: _ticketOptions,
              selected: _selectedTicketSize,
              colors: colors,
              onSelect: (opt) => setState(() => _selectedTicketSize = opt),
              onAddCustom: () {
                _showAddCustomOptionDialog(
                  title: 'Add Custom Ticket Size',
                  fieldLabel: 'Ticket size',
                  hintText: r'e.g. $25K – $75K or $10M+',
                  currentOptions: _ticketOptions,
                  onAdded: (customVal) {
                    setState(() {
                      if (!_ticketOptions.contains(customVal)) {
                        _ticketOptions.add(customVal);
                      }
                      _selectedTicketSize = customVal;
                      _localError = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('PREFERRED INVESTMENT CURRENCY'),
            _buildSingleSelectChipGroup(
              options: _currencyOptions,
              selected: _selectedCurrency,
              colors: colors,
              onSelect: (opt) => setState(() => _selectedCurrency = opt),
              onAddCustom: () {
                _showAddCustomOptionDialog(
                  title: 'Add Custom Currency',
                  fieldLabel: 'Currency',
                  hintText: 'e.g. BHD (د.ب) - Bahraini Dinar',
                  currentOptions: _currencyOptions,
                  onAdded: (customVal) {
                    setState(() {
                      if (!_currencyOptions.contains(customVal)) {
                        _currencyOptions.add(customVal);
                      }
                      _selectedCurrency = customVal;
                      _localError = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('RISK PREFERENCE'),
            _buildSingleSelectChipGroup(
              options: _riskPreferenceOptions,
              selected: _selectedRiskPreference,
              colors: colors,
              onSelect: (opt) => setState(() => _selectedRiskPreference = opt),
            ),
          ],
          const SizedBox(height: 20),

          // Government ID Upload Simulator (Optional)
          _buildFieldLabel('GOVERNMENT ID PHOTO (OPTIONAL)'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.selectionTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _idDocumentName ?? 'No document selected',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _idDocumentName != null ? AppColors.darkText : AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _idDocumentSizeBytes != null
                            ? (_idDocumentSizeBytes! > 1024 * 1024
                                ? '${(_idDocumentSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB'
                                : '${(_idDocumentSizeBytes! / 1024).toStringAsFixed(0)} KB')
                            : 'JPG, PNG or PDF (Max 5MB)',
                        style: const TextStyle(fontSize: 11, color: AppColors.tertiaryText),
                      ),
                    ],
                  ),
                ),
                if (_idDocumentName != null) ...[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _idDocumentName = null;
                        _idDocumentSizeBytes = null;
                      });
                    },
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.mutedText),
                    tooltip: 'Remove document',
                  ),
                ],
                OutlinedButton(
                  onPressed: _pickIdDocument,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    _idDocumentName == null ? 'Browse' : 'Change',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Optional for identity verification. Submitting an ID does not imply immediate verification until approved by an admin. Stored privately and securely.',
            style: TextStyle(fontSize: 10.5, color: AppColors.tertiaryText, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Error Banner
          if (_localError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _localError!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Legal Text
          const Text(
            'By creating an account you agree to our Terms of Service and Privacy Policy.',
            style: TextStyle(fontSize: 11, color: AppColors.subtleText, height: 1.5),
          ),
          const SizedBox(height: 18),

          // Submit Button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state.status == AuthStatus.loading;
              return SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 3,
                    shadowColor: colors.primary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Create account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Footer
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signIn),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.subtleText,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 13,
            color: isMet ? AppColors.success : AppColors.tertiaryText,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
                color: isMet ? AppColors.darkText : AppColors.tertiaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.mutedText,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ColorScheme colors,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.darkText),
      decoration: _inputDecoration(hint: hint, colors: colors),
    );
  }

  InputDecoration _inputDecoration({required String hint, required ColorScheme colors, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.inputHint, fontSize: 14),
      fillColor: AppColors.surface,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required Set<String> selected,
    required ColorScheme colors,
    required ValueChanged<String> onToggle,
    VoidCallback? onAddCustom,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...options.map((opt) {
          final active = selected.contains(opt);
          return InkWell(
            onTap: () => onToggle(opt),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active ? colors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? colors.primary : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (active) ...[
                    const Icon(Icons.check, size: 12, color: AppColors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    opt,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.white : AppColors.chipText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (onAddCustom != null)
          InkWell(
            onTap: onAddCustom,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 15, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Other...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSingleSelectChipGroup({
    required List<String> options,
    required String selected,
    required ColorScheme colors,
    required ValueChanged<String> onSelect,
    VoidCallback? onAddCustom,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...options.map((opt) {
          final active = opt == selected;
          return InkWell(
            onTap: () => onSelect(opt),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? colors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? colors.primary : AppColors.border,
                ),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.white : AppColors.chipText,
                ),
              ),
            ),
          );
        }),
        if (onAddCustom != null)
          InkWell(
            onTap: onAddCustom,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 15, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Other...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddCustomOptionDialog({
    required String title,
    required String fieldLabel,
    required String hintText,
    required List<String> currentOptions,
    required ValueChanged<String> onAdded,
    int minLength = 2,
    int maxLength = 50,
  }) async {
    final controller = TextEditingController();
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your custom value ($minLength–$maxLength characters, letters and numbers only):',
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                    decoration: InputDecoration(
                      hintText: hintText,
                      errorText: dialogError,
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.inputHint),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (val) {
                      final err = Validators.customTag(
                        val,
                        fieldName: fieldLabel,
                        minLength: minLength,
                        maxLength: maxLength,
                        existingOptions: currentOptions,
                      );
                      if (err != null) {
                        setDialogState(() => dialogError = err);
                      } else {
                        Navigator.of(dialogCtx).pop();
                        onAdded(val.trim());
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.mutedText)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final err = Validators.customTag(
                      controller.text,
                      fieldName: fieldLabel,
                      minLength: minLength,
                      maxLength: maxLength,
                      existingOptions: currentOptions,
                    );
                    if (err != null) {
                      setDialogState(() => dialogError = err);
                    } else {
                      Navigator.of(dialogCtx).pop();
                      onAdded(controller.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
