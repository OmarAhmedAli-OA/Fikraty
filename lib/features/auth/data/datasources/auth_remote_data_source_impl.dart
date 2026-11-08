import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/auth.dart';
import '../models/auth_model.dart';
import '../models/auth_response_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.sessionManager,
  });

  final ApiClient apiClient;
  final SessionManager sessionManager;

  @override
  Future<AuthUser> signIn(String email, String password) async {
    try {
      final response = await apiClient.post(
        ApiConstants.authLogin,
        data: {
          'email': email.trim(),
          'password': password,
          'deviceInfo': 'Flutter Client',
        },
      );

      final authResponse = AuthResponseModel.fromJson(
        response as Map<String, dynamic>,
      );

      await sessionManager.saveSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        user: authResponse.user,
      );

      return authResponse.user;
    } on ApiException catch (e) {
      throw AuthDataException(
        e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
        lockedUntil: e.lockedUntil,
      );
    } catch (e) {
      throw AuthDataException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<AuthUser> signUp(RegistrationData data) async {
    try {
      final roleNumber = data.role == UserRole.entrepreneur ? 1 : 2;

      final response = await apiClient.post(
        ApiConstants.authRegister,
        data: {
          'email': data.email.trim(),
          'password': data.password,
          'confirmPassword': data.password,
          'fullName': data.profile.fullName.trim(),
          'phone': data.phone?.trim(),
          'role': roleNumber,
        },
      );

      final authResponse = AuthResponseModel.fromJson(
        response as Map<String, dynamic>,
      );

      final fullUser = AuthUser(
        id: authResponse.user.id,
        email: authResponse.user.email,
        role: authResponse.user.role,
        phone: authResponse.user.phone,
        accountStatus: authResponse.user.accountStatus,
        emailConfirmed: authResponse.user.emailConfirmed,
        profile: data.profile,
        startup: data.startup,
        investor: data.investor,
      );

      await sessionManager.saveSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        user: fullUser,
      );

      // Cache pending business profile for Dev 2 onboarding
      final apiJson = RegistrationRequestModel(data).toApiJson();
      final startupMap = apiJson['startup'] as Map<String, dynamic>?;
      final investorMap = apiJson['investor_profile'] as Map<String, dynamic>?;
      if (startupMap != null || investorMap != null) {
        await sessionManager.savePendingProfileData(
          startupJson: startupMap != null ? jsonEncode(startupMap) : null,
          investorJson: investorMap != null ? jsonEncode(investorMap) : null,
        );
      }

      return fullUser;
    } on ApiException catch (e) {
      throw AuthDataException(
        e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
        lockedUntil: e.lockedUntil,
      );
    } catch (e) {
      throw AuthDataException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await apiClient.post(
        ApiConstants.authForgotPassword,
        data: {'email': email.trim()},
      );
    } on ApiException catch (e) {
      throw AuthDataException(
        e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
        lockedUntil: e.lockedUntil,
      );
    } catch (e) {
      throw AuthDataException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await apiClient.post(
        ApiConstants.authResetPassword,
        data: {
          'email': email.trim(),
          'code': code.trim(),
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
      );
    } on ApiException catch (e) {
      throw AuthDataException(
        e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
        lockedUntil: e.lockedUntil,
      );
    } catch (e) {
      throw AuthDataException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      await apiClient.post(
        ApiConstants.authVerifyEmail,
        data: {
          'email': email.trim(),
          'code': code.trim(),
        },
      );
    } on ApiException catch (e) {
      throw AuthDataException(
        e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
        lockedUntil: e.lockedUntil,
      );
    } catch (e) {
      throw AuthDataException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    try {
      await apiClient.post(
        ApiConstants.authResendVerification,
        data: {'email': email.trim()},
      );
    } on ApiException catch (e) {
      throw AuthDataException(
        e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
        lockedUntil: e.lockedUntil,
      );
    } catch (e) {
      throw AuthDataException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final refreshToken = sessionManager.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await apiClient.post(
          ApiConstants.authLogout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await sessionManager.clearSession();
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiConstants.authMe);
      if (response is Map<String, dynamic>) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        return AuthResponseModel.parseUserFromJson(data);
      }
      return sessionManager.cachedUser;
    } catch (_) {
      return sessionManager.cachedUser;
    }
  }
}
