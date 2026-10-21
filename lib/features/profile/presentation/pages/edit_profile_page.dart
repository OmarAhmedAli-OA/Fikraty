import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/location_picker_bottom_sheet.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _bioController;
  late TextEditingController _backgroundController;
  late TextEditingController _newSkillController;

  // Investor specific
  late TextEditingController _firmNameController;
  late TextEditingController _investorTitleController;
  late TextEditingController _fundSizeController;
  late TextEditingController _yearsInvestingController;
  late TextEditingController _thesisQuoteController;

  // Social
  late TextEditingController _twitterController;
  late TextEditingController _linkedInController;

  late Country _selectedCountry;
  String? _noticeMessage;
  static const int bioLimit = 250;
  late List<String> _expertise;

  // Field validation error messages
  String? _nameError;
  String? _headlineError;
  String? _locationError;
  String? _websiteError;
  String? _linkedInError;
  String? _twitterError;

  String? _pickedPhotoPath;
  String? _pickedCoverPath;
  late List<ProfileDocument> _documents;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile =
        (context.read<ProfileBloc>().state as ProfileLoadedState).profile;

    _nameController = TextEditingController(text: profile.fullName);
    _headlineController = TextEditingController(text: profile.title);
    _locationController = TextEditingController(text: profile.location);
    _websiteController = TextEditingController(text: profile.website);
    _bioController = TextEditingController(text: profile.bio);
    _backgroundController = TextEditingController(text: profile.background);
    _newSkillController = TextEditingController();
    _expertise = List.from(profile.expertise);

    _firmNameController = TextEditingController(
        text: profile.firmName.isNotEmpty
            ? profile.firmName
            : 'Wamda Capital');
    _investorTitleController = TextEditingController(
        text: profile.title.isNotEmpty ? profile.title : 'Principal');
    _fundSizeController = TextEditingController(
        text: profile.fundSize.isNotEmpty ? profile.fundSize : '50M');
    _yearsInvestingController = TextEditingController(
        text: profile.yearsInvesting.isNotEmpty
            ? profile.yearsInvesting
            : '10');
    _thesisQuoteController = TextEditingController(
        text: profile.thesisQuote.isNotEmpty
            ? profile.thesisQuote
            : 'I back founders who deeply understand their market and build with capital efficiency.');

    _twitterController = TextEditingController(text: profile.twitter);
    _linkedInController = TextEditingController(text: profile.linkedIn);

    _selectedCountry = profile.country;
    _pickedPhotoPath = profile.photoUrl;
    _pickedCoverPath = profile.coverUrl;
    // Enforce strictly 1 National ID document as requested
    _documents = profile.documents.isNotEmpty
        ? [profile.documents.first]
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    _backgroundController.dispose();
    _newSkillController.dispose();
    _firmNameController.dispose();
    _investorTitleController.dispose();
    _fundSizeController.dispose();
    _yearsInvestingController.dispose();
    _thesisQuoteController.dispose();
    _twitterController.dispose();
    _linkedInController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isCover}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCover ? 'Update Cover Banner' : 'Update Profile Photo',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final XFile? file =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    setState(() {
                      if (isCover) {
                        _pickedCoverPath = file.path;
                      } else {
                        _pickedPhotoPath = file.path;
                      }
                    });
                    _showNotice(
                        '${isCover ? 'Cover' : 'Photo'} updated! Tap Save to apply.');
                  }
                } catch (e) {
                  _showNotice('Could not open gallery.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final XFile? file =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (file != null) {
                    setState(() {
                      if (isCover) {
                        _pickedCoverPath = file.path;
                      } else {
                        _pickedPhotoPath = file.path;
                      }
                    });
                    _showNotice(
                        '${isCover ? 'Cover' : 'Photo'} updated! Tap Save to apply.');
                  }
                } catch (e) {
                  _showNotice('Camera not available.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIdDocument() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload National ID / Passport',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload your personal National ID or Passport document to verify your account identity. Only 1 document is required.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.file_present_outlined,
                  color: AppColors.primary),
              title: const Text('Choose ID Document from Device Files'),
              subtitle: const Text('Pick PDF, DOC, or image file from your device storage'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final PlatformFile? picked = await FilePicker.pickFile(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
                  );
                  if (picked != null) {
                    final size = await picked.length() ?? 0;
                    _handlePickedPlatformFile(
                      path: picked.path ?? '',
                      name: picked.name,
                      sizeBytes: size,
                    );
                  }
                } catch (e) {
                  // Fallback to gallery image picker
                  try {
                    final XFile? file =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (file != null) {
                      await _handlePickedIdFile(file);
                    }
                  } catch (_) {
                    _showNotice('Could not open file picker.');
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take a Photo of ID Card'),
              subtitle: const Text('Capture front or back with your camera'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final XFile? file =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (file != null) {
                    await _handlePickedIdFile(file);
                  }
                } catch (e) {
                  _showNotice('Camera not available.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handlePickedPlatformFile({
    required String path,
    required String name,
    required int sizeBytes,
  }) {
    String sizeStr;
    if (sizeBytes > 1024 * 1024) {
      sizeStr = '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      sizeStr = '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }

    final idDoc = ProfileDocument(
      id: 'national_id_doc',
      name: name.isNotEmpty ? name : 'National_ID.pdf',
      size: sizeStr,
      uploadDate: 'Just now',
      path: path,
      type: 'id_verification',
    );

    setState(() {
      _documents.clear();
      _documents.add(idDoc);
    });

    _showNotice('National ID document ($name) uploaded! Tap Save to persist.');
  }

  Future<void> _handlePickedIdFile(XFile file) async {
    String sizeStr = '1.8 MB';
    try {
      final f = File(file.path);
      if (await f.exists()) {
        final bytes = await f.length();
        if (bytes > 1024 * 1024) {
          sizeStr = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else {
          sizeStr = '${(bytes / 1024).toStringAsFixed(0)} KB';
        }
      }
    } catch (_) {}

    final rawName = file.name.isNotEmpty ? file.name : 'National_ID.jpg';
    final idDoc = ProfileDocument(
      id: 'national_id_doc',
      name: rawName,
      size: sizeStr,
      uploadDate: 'Just now',
      path: file.path,
      type: 'id_verification',
    );

    setState(() {
      _documents.clear();
      _documents.add(idDoc);
    });

    _showNotice('National ID uploaded from device! Tap Save to persist.');
  }

  void _onSave(UserProfile currentProfile) {
    setState(() {
      _nameError = null;
      _headlineError = null;
      _locationError = null;
      _websiteError = null;
      _linkedInError = null;
      _twitterError = null;
    });

    bool hasError = false;

    // 1. Full name validation (min 3 chars)
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameError = 'Please enter your full name.';
      hasError = true;
    } else if (name.length < 3) {
      _nameError = 'Name must be at least 3 characters.';
      hasError = true;
    }

    // 2. Headline validation
    final headline = _headlineController.text.trim();
    if (headline.isEmpty) {
      _headlineError = 'Please enter your professional headline.';
      hasError = true;
    }

    // 3. Location validation
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      _locationError = 'Please select your country and governorate/city.';
      hasError = true;
    }

    // 4. Portfolio / Website URL validation
    final website = _websiteController.text.trim();
    if (website.isNotEmpty) {
      final webRegex = RegExp(
        r'^(https?:\/\/)?([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(\/.*)?$',
        caseSensitive: false,
      );
      if (!webRegex.hasMatch(website)) {
        _websiteError = 'Please enter a valid website URL (e.g. https://example.com)';
        hasError = true;
      }
    }

    // 5. LinkedIn URL validation (must be valid LinkedIn profile link)
    final linkedin = _linkedInController.text.trim();
    if (linkedin.isNotEmpty) {
      final liRegex = RegExp(
        r'^(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9_\-]+\/?$',
        caseSensitive: false,
      );
      if (!liRegex.hasMatch(linkedin)) {
        _linkedInError = 'Please enter a valid LinkedIn URL (e.g. linkedin.com/in/username)';
        hasError = true;
      }
    }

    // 6. X (Twitter) handle/link validation
    final twitter = _twitterController.text.trim();
    if (twitter.isNotEmpty) {
      final xRegex = RegExp(
        r'^(@[a-zA-Z0-9_]{1,15}|(https?:\/\/)?(www\.)?(twitter|x)\.com\/[a-zA-Z0-9_]{1,15}\/?)$',
        caseSensitive: false,
      );
      if (!xRegex.hasMatch(twitter)) {
        _twitterError = 'Please enter a valid X handle (@user) or link (x.com/user)';
        hasError = true;
      }
    }

    if (hasError) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted errors before saving.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updated = currentProfile.copyWith(
      fullName: name,
      title: headline,
      location: location,
      country: _selectedCountry,
      website: website,
      bio: _bioController.text.trim(),
      background: _backgroundController.text.trim(),
      expertise: _expertise,
      photoUrl: _pickedPhotoPath ?? currentProfile.photoUrl,
      coverUrl: _pickedCoverPath ?? currentProfile.coverUrl,
      // Founder does NOT edit startup details (managed exclusively by Member 3)
      companyName: currentProfile.companyName,
      industry: currentProfile.industry,
      companyStage: currentProfile.companyStage,
      firmName: _firmNameController.text.trim(),
      fundSize: _fundSizeController.text.trim(),
      yearsInvesting: _yearsInvestingController.text.trim(),
      thesisQuote: _thesisQuoteController.text.trim(),
      twitter: twitter,
      linkedIn: linkedin,
      angelList: '', // Removed from social links as requested
      documents: _documents,
    );

    context.read<ProfileBloc>().add(UpdateProfileEvent(updated));
    Navigator.pop(context);
  }

  void _showNotice(String message) {
    setState(() => _noticeMessage = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _noticeMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoadedState) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final profile = state.profile;
        final isEntrepreneur = profile.role == UserRole.entrepreneur;
        final isSaving = state.isSaving;

        return Scaffold(
          backgroundColor: AppColors.grayBackground,
          appBar: AppBar(
            title: const Text('Edit Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => _onSave(profile),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image Header with Real Image Pick Action
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isEntrepreneur
                                ? [
                                    const Color(0xFFEEF0FF),
                                    const Color(0xFFDCD8FF)
                                  ]
                                : [
                                    const Color(0xFFE0E7FF),
                                    const Color(0xFFC7D2FE)
                                  ],
                          ),
                        ),
                        child: _pickedCoverPath != null &&
                                _pickedCoverPath!.isNotEmpty
                            ? (!kIsWeb && File(_pickedCoverPath!).existsSync()
                                ? Image.file(
                                    File(_pickedCoverPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const SizedBox.shrink(),
                                  )
                                : Image.network(
                                    _pickedCoverPath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const SizedBox.shrink(),
                                  ))
                            : null,
                      ),
                      Positioned(
                        right: 14,
                        bottom: 10,
                        child: InkWell(
                          onTap: () => _pickImage(isCover: true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt_outlined,
                                    size: 13, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Change Cover',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Avatar & Change Photo
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _pickedPhotoPath != null &&
                                    _pickedPhotoPath!.isNotEmpty
                                ? (!kIsWeb && File(_pickedPhotoPath!).existsSync()
                                    ? Image.file(
                                        File(_pickedPhotoPath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(
                                          Icons.person,
                                          size: 38,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : Image.network(
                                        _pickedPhotoPath!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(
                                          Icons.person,
                                          size: 38,
                                          color: AppColors.primary,
                                        ),
                                      ))
                                : const Icon(
                                    Icons.person,
                                    size: 38,
                                    color: AppColors.primary,
                                  ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _pickImage(isCover: false),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 13, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Change Photo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_noticeMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _noticeMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Basic Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BASIC INFO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),

                        AppTextField(
                          label: 'Full Name',
                          hintText: 'Your full name',
                          controller: _nameController,
                          errorText: _nameError,
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Headline',
                          hintText: isEntrepreneur
                              ? 'e.g. Founder & CEO @ NovaMed AI'
                              : 'e.g. Principal · Wamda Capital',
                          controller: _headlineController,
                          errorText: _headlineError,
                          onChanged: (_) {
                            if (_headlineError != null) {
                              setState(() => _headlineError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Two-step Location Selector Card (Country -> Governorate/City)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location (Country & Governorate/City)',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final currentGov = _locationController.text.contains(',')
                                    ? _locationController.text.split(',').first.trim()
                                    : null;
                                final selection =
                                    await LocationPickerBottomSheet.show(
                                  context,
                                  initialCountry: _selectedCountry,
                                  initialGovernorate: currentGov,
                                );
                                if (selection != null) {
                                  setState(() {
                                    _selectedCountry = selection.country;
                                    _locationController.text = selection.formatted;
                                    _locationError = null;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _locationError != null
                                        ? AppColors.error
                                        : AppColors.cardBorder,
                                    width: _locationError != null ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedCountry.flagEmoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _locationController.text.isNotEmpty
                                                ? _locationController.text
                                                : 'Tap to select country & governorate',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _locationController.text.isNotEmpty
                                                  ? AppColors.textPrimary
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_selectedCountry.name} · Default Currency: ${_selectedCountry.currencyCode} (${_selectedCountry.currencySymbol})',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_locationError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 12),
                                child: Text(
                                  _locationError!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Website / Portfolio URL',
                          hintText: 'https://...',
                          controller: _websiteController,
                          errorText: _websiteError,
                          prefixIcon: const Icon(
                            Icons.language,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          onChanged: (_) {
                            if (_websiteError != null) {
                              setState(() => _websiteError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        // About / Bio with 250 character limit
                        const Text(
                          'ABOUT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),

                        AppTextField(
                          hintText: 'Tell your story...',
                          controller: _bioController,
                          maxLines: 4,
                          maxLength: bioLimit,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Previous Experience / Background',
                          hintText: isEntrepreneur
                              ? 'e.g. Stanford Medicine Research Fellow, Ex-McKinsey'
                              : 'e.g. Former founder (exited 2018), 10+ years VC',
                          controller: _backgroundController,
                          prefixIcon: const Icon(
                            Icons.history_edu_outlined,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Skills & Expertise
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SKILLS & EXPERTISE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              '${_expertise.length} tags',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_expertise.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _expertise.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _expertise.remove(skill);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newSkillController,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Add skill (e.g. HealthTech, AI/ML)...',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.cardSurface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: AppColors.cardBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: AppColors.cardBorder),
                                  ),
                                ),
                                onSubmitted: (val) {
                                  final text = val.trim();
                                  if (text.isNotEmpty &&
                                      !_expertise.contains(text)) {
                                    setState(() {
                                      _expertise.add(text);
                                      _newSkillController.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final text = _newSkillController.text.trim();
                                if (text.isNotEmpty &&
                                    !_expertise.contains(text)) {
                                  setState(() {
                                    _expertise.add(text);
                                    _newSkillController.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '+ Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Upload National ID Section (Strictly 1 Document: National ID / Passport)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'NATIONAL ID VERIFICATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickIdDocument,
                              icon: const Icon(Icons.upload_file,
                                  size: 15, color: AppColors.primary),
                              label: Text(
                                _documents.isEmpty ? '+ Upload ID' : 'Replace ID',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_documents.isEmpty)
                          InkWell(
                            onTap: _pickIdDocument,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Upload National ID or Passport from device',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Pick image or document file from your device files / camera',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _documents.map((doc) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF0FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.badge_outlined,
                                        size: 22,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  doc.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.successLight,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'ID File',
                                                  style: TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.successDark,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${doc.size} · Uploaded ${doc.uploadDate}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20, color: AppColors.error),
                                      onPressed: () {
                                        setState(() {
                                          _documents.removeWhere(
                                              (d) => d.id == doc.id);
                                        });
                                        _showNotice('ID document removed.');
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 24),

                        // Investor-only details (Founder startup affiliation removed per Member 3 separation)
                        if (!isEntrepreneur) ...[
                          const Text(
                            'INVESTOR DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),

                          AppTextField(
                            label: 'Firm Name',
                            hintText: 'e.g. Wamda Capital',
                            controller: _firmNameController,
                          ),
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'Role / Title',
                            hintText: 'e.g. General Partner',
                            controller: _investorTitleController,
                          ),
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'Fund Size',
                            hintText: '50M',
                            prefixText: '\$',
                            controller: _fundSizeController,
                          ),
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'Years Investing',
                            hintText: '8',
                            keyboardType: TextInputType.number,
                            controller: _yearsInvestingController,
                          ),
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'Investment Thesis Quote',
                            hintText: 'e.g. I back founders who deeply understand their market...',
                            controller: _thesisQuoteController,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Social Links (LinkedIn & X with strict validations, AngelList removed)
                        const Text(
                          'SOCIAL LINKS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _SocialInputRow(
                          label: 'Twitter / X',
                          hint: '@username or x.com/username',
                          badgeLetter: 'X',
                          badgeColor: Colors.black87,
                          controller: _twitterController,
                          errorText: _twitterError,
                          onChanged: (_) {
                            if (_twitterError != null) {
                              setState(() => _twitterError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        _SocialInputRow(
                          label: 'LinkedIn',
                          hint: 'linkedin.com/in/username',
                          badgeLetter: 'in',
                          badgeColor: const Color(0xFF0077B5),
                          controller: _linkedInController,
                          errorText: _linkedInError,
                          onChanged: (_) {
                            if (_linkedInError != null) {
                              setState(() => _linkedInError = null);
                            }
                          },
                        ),

                        const SizedBox(height: 28),

                        AppButton(
                          text: 'Save Changes',
                          width: double.infinity,
                          height: 50,
                          isLoading: isSaving,
                          onPressed: () => _onSave(profile),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SocialInputRow extends StatelessWidget {
  final String label;
  final String hint;
  final String badgeLetter;
  final Color badgeColor;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _SocialInputRow({
    required this.label,
    required this.hint,
    required this.badgeLetter,
    required this.badgeColor,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badgeLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  errorText: errorText,
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: errorText != null
                          ? AppColors.error
                          : AppColors.cardBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: errorText != null
                          ? AppColors.error
                          : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
