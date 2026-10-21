import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_page.dart';

enum SecurityFieldType { password, email, phone }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailDigest = true;
  bool _investorInterest = true;
  bool _weeklyReport = true;
  bool _showOnlineStatus = true;

  void _showNotice(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.successDark : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Selection BottomSheet for Messaging and Profile Visibility
  void _showOptionPicker({
    required String title,
    required String subtitle,
    required List<Map<String, String>> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E6EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            ...options.map((opt) {
              final val = opt['val']!;
              final label = opt['label']!;
              final desc = opt['desc'] ?? '';
              final isChosen = selectedValue.toLowerCase() == val.toLowerCase();

              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onSelected(val);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isChosen
                        ? const Color(0xFFEEF0FF)
                        : const Color(0xFFF9FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isChosen ? AppColors.primary : AppColors.cardBorder,
                      width: isChosen ? 1.5 : 1.0,
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
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isChosen
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (desc.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                desc,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isChosen)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Security Verification Dialog:
  // Step 1: Choose verification method
  // Step 2: Enter OTP code to verify identity first
  // Step 3: Enter and confirm new data with password toggle & validations
  void _showSecurityOtpDialog({
    required SecurityFieldType fieldType,
    required UserProfile profile,
  }) {
    final title = switch (fieldType) {
      SecurityFieldType.password => 'Change Password',
      SecurityFieldType.email => 'Change Email Address',
      SecurityFieldType.phone => 'Change Phone Number',
    };

    int currentStep = 1;
    String selectedMethod = 'email'; // 'email' or 'phone'

    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final otpController = TextEditingController();

    bool showPassword = false;
    bool showConfirmPassword = false;

    String? validationError;
    const simulatedOtp = '4829';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E6EE),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF0FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Step $currentStep of 3',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentStep == 1
                          ? 'For your security, verify your identity first by choosing where to receive your OTP.'
                          : (currentStep == 2
                              ? 'Enter the 4-digit verification code to unlock editing.'
                              : 'Enter and confirm your new details below.'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // STEP 1: CHOOSE OTP METHOD
                    if (currentStep == 1) ...[
                      const Text(
                        'Choose Verification Method:',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Method 1: Email
                      InkWell(
                        onTap: () =>
                            setModalState(() => selectedMethod = 'email'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedMethod == 'email'
                                ? const Color(0xFFEEF0FF)
                                : const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedMethod == 'email'
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              width: selectedMethod == 'email' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 18,
                                color: selectedMethod == 'email'
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Email Verification',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Send 4-digit code to ${profile.email}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                selectedMethod == 'email'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: selectedMethod == 'email'
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Method 2: SMS / Phone
                      InkWell(
                        onTap: () =>
                            setModalState(() => selectedMethod = 'phone'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedMethod == 'phone'
                                ? const Color(0xFFEEF0FF)
                                : const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedMethod == 'phone'
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              width: selectedMethod == 'phone' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_android_outlined,
                                size: 18,
                                color: selectedMethod == 'phone'
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SMS / Phone Verification',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'Send 4-digit code to +971 50 xxx xxxx',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                selectedMethod == 'phone'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: selectedMethod == 'phone'
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              validationError = null;
                              currentStep = 2;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Send Verification Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ]

                    // STEP 2: ENTER OTP
                    else if (currentStep == 2) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.successDark,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'A verification code was simulated to your ${selectedMethod.toUpperCase()}.\nYour code is: $simulatedOtp',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.successDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Enter 4-digit code:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••',
                          counterText: '',
                          errorText: validationError,
                          filled: true,
                          fillColor: const Color(0xFFF9FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            final code = otpController.text.trim();
                            if (code != simulatedOtp) {
                              setModalState(() => validationError =
                                  'Incorrect code. Enter $simulatedOtp');
                              return;
                            }

                            setModalState(() {
                              validationError = null;
                              currentStep = 3;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Verify & Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              currentStep = 1;
                              validationError = null;
                            });
                          },
                          child: const Text(
                            'Back to choose method',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ]

                    // STEP 3: INPUT & VALIDATE NEW VALUES
                    else if (currentStep == 3) ...[
                      if (fieldType == SecurityFieldType.password) ...[
                        // New Password Field with Eye Toggle
                        const Text(
                          'New Password:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: passwordController,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            hintText: 'Enter at least 6 characters',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setModalState(
                                  () => showPassword = !showPassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.cardBorder),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Confirm Password Field with Eye Toggle
                        const Text(
                          'Confirm New Password:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !showConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Re-enter your new password',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setModalState(() =>
                                  showConfirmPassword = !showConfirmPassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.cardBorder),
                            ),
                          ),
                        ),
                      ] else if (fieldType == SecurityFieldType.email) ...[
                        // New Email Field
                        const Text(
                          'New Email Address:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'e.g. name@company.com',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.cardBorder),
                            ),
                          ),
                        ),
                      ] else if (fieldType == SecurityFieldType.phone) ...[
                        // New Phone Field
                        const Text(
                          'New Phone Number:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'e.g. +971 50 123 4567',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.cardBorder),
                            ),
                          ),
                        ),
                      ],

                      if (validationError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          validationError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            if (fieldType == SecurityFieldType.password) {
                              final p1 = passwordController.text.trim();
                              final p2 = confirmPasswordController.text.trim();

                              if (p1.length < 6) {
                                setModalState(() => validationError =
                                    'Password must be at least 6 characters');
                                return;
                              }
                              if (p1 != p2) {
                                setModalState(() => validationError =
                                    'Passwords do not match! Please check again.');
                                return;
                              }

                              Navigator.pop(ctx);
                              _showNotice(
                                'Password updated successfully!',
                                isSuccess: true,
                              );
                            } else if (fieldType == SecurityFieldType.email) {
                              final emailVal = emailController.text.trim();
                              final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                              if (!emailRegex.hasMatch(emailVal)) {
                                setModalState(() => validationError =
                                    'Please enter a valid email address (e.g. user@domain.com)');
                                return;
                              }
                              if (emailVal.toLowerCase() ==
                                  profile.email.toLowerCase()) {
                                setModalState(() => validationError =
                                    'New email cannot be the same as current email');
                                return;
                              }

                              Navigator.pop(ctx);
                              context.read<ProfileBloc>().add(
                                    UpdateProfileEvent(
                                      profile.copyWith(email: emailVal),
                                    ),
                                  );
                              _showNotice(
                                'Email updated to $emailVal successfully!',
                                isSuccess: true,
                              );
                            } else if (fieldType == SecurityFieldType.phone) {
                              final phoneVal = phoneController.text.trim();
                              final phoneRegex = RegExp(r'^\+?[0-9\s-]{8,}$');

                              if (!phoneRegex.hasMatch(phoneVal)) {
                                setModalState(() => validationError =
                                    'Please enter a valid phone number (at least 8 digits)');
                                return;
                              }

                              Navigator.pop(ctx);
                              context.read<ProfileBloc>().add(
                                    UpdateProfileEvent(
                                      profile.copyWith(phone: phoneVal),
                                    ),
                                  );
                              _showNotice(
                                'Phone number updated successfully!',
                                isSuccess: true,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Account?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action is permanent and cannot be undone. All your data will be permanently removed.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.grayBackground,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showNotice('Account deletion request initiated.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Delete My Account',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state is ProfileLoadedState ? state.profile : null;
        final email = profile?.email ?? 'sarah@novamed.ai';
        final visibility = profile?.profileVisibility ?? 'Public';
        final messaging = profile?.messagingFrom ?? 'Everyone';

        return Scaffold(
          backgroundColor: AppColors.grayBackground,
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ACCOUNT SECTION
                _buildSectionHeader('ACCOUNT'),
                _buildTile(
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfileBloc>(),
                          child: const EditProfilePage(),
                        ),
                      ),
                    );
                  },
                ),
                _buildTile(
                  title: 'Password',
                  trailing: const Text(
                    '••••••••',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  onTap: () {
                    if (profile != null) {
                      _showSecurityOtpDialog(
                        fieldType: SecurityFieldType.password,
                        profile: profile,
                      );
                    }
                  },
                ),
                _buildTile(
                  title: 'Email',
                  trailing: Text(
                    email,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    if (profile != null) {
                      _showSecurityOtpDialog(
                        fieldType: SecurityFieldType.email,
                        profile: profile,
                      );
                    }
                  },
                ),
                _buildTile(
                  title: 'Phone',
                  trailing: const Text(
                    '+971 50 xxx xxxx',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    if (profile != null) {
                      _showSecurityOtpDialog(
                        fieldType: SecurityFieldType.phone,
                        profile: profile,
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),

                // NOTIFICATIONS SECTION
                _buildSectionHeader('NOTIFICATIONS'),
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Get alerts on your device',
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                _buildSwitchTile(
                  title: 'Email Digest',
                  subtitle: 'Daily summary of activity',
                  value: _emailDigest,
                  onChanged: (val) => setState(() => _emailDigest = val),
                ),
                _buildSwitchTile(
                  title: 'Investor Interest',
                  subtitle: 'When investors view your profile',
                  value: _investorInterest,
                  onChanged: (val) => setState(() => _investorInterest = val),
                ),
                _buildSwitchTile(
                  title: 'Weekly Report',
                  subtitle: 'Your weekly performance summary',
                  value: _weeklyReport,
                  onChanged: (val) => setState(() => _weeklyReport = val),
                ),

                const SizedBox(height: 16),

                // PRIVACY SECTION
                _buildSectionHeader('PRIVACY'),
                _buildTile(
                  title: 'Profile Visibility',
                  trailing: Text(
                    visibility,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    if (profile == null) return;
                    _showOptionPicker(
                      title: 'Profile Visibility',
                      subtitle:
                          'Control who can discover and view your profile.',
                      options: const [
                        {
                          'val': 'Public',
                          'label': 'Public',
                          'desc':
                              'Discoverable by all investors and founders on Fikraty',
                        },
                        {
                          'val': 'Connections',
                          'label': 'Connections Only',
                          'desc':
                              'Visible only to accepted network contacts and matches',
                        },
                        {
                          'val': 'Private',
                          'label': 'Private / Stealth',
                          'desc':
                              'Hidden from exploration, accessible only via direct pitch',
                        },
                      ],
                      selectedValue: visibility,
                      onSelected: (newVal) {
                        context.read<ProfileBloc>().add(
                              UpdateProfileEvent(
                                profile.copyWith(profileVisibility: newVal),
                              ),
                            );
                        _showNotice('Profile visibility set to $newVal',
                            isSuccess: true);
                      },
                    );
                  },
                ),
                _buildSwitchTile(
                  title: 'Show Online Status',
                  subtitle: 'Let others see when you\'re active',
                  value: _showOnlineStatus,
                  onChanged: (val) => setState(() => _showOnlineStatus = val),
                ),
                _buildTile(
                  title: 'Messaging From',
                  subtitle: messaging,
                  onTap: () {
                    if (profile == null) return;
                    _showOptionPicker(
                      title: 'Messaging From',
                      subtitle:
                          'Choose who can initiate private direct messages with you.',
                      options: const [
                        {
                          'val': 'Everyone',
                          'label': 'Everyone',
                          'desc':
                              'Any registered founder or verified investor can message you',
                        },
                        {
                          'val': 'Connections',
                          'label': 'Connections Only',
                          'desc':
                              'Only your approved connections and mutual matches can message',
                        },
                      ],
                      selectedValue: messaging,
                      onSelected: (newVal) {
                        context.read<ProfileBloc>().add(
                              UpdateProfileEvent(
                                profile.copyWith(messagingFrom: newVal),
                              ),
                            );
                        _showNotice('Messaging permission set to $newVal',
                            isSuccess: true);
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // VERIFICATION SECTION
                _buildSectionHeader('VERIFICATION'),
                _buildTile(
                  title: 'Verify Account',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Unverified',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF57C00),
                      ),
                    ),
                  ),
                  onTap: () => _showNotice(
                      'Account verification submitted to verification module'),
                ),

                const SizedBox(height: 16),

                // DANGER ZONE
                _buildSectionHeader('DANGER ZONE', isDanger: true),
                InkWell(
                  onTap: _showDeleteAccountDialog,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Footer version & Logout
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'v1.0.0 (build 42)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Fikraty © 2026',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 140,
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () {
                            _showNotice('Logged out successfully');
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF0F0),
                            side: const BorderSide(
                              color: Color(0xFFF87171),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDanger ? AppColors.error : AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?trailing,
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        activeThumbColor: AppColors.primary,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
