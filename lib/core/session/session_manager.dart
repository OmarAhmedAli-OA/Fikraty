import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/auth.dart';

class SessionManager {
  SessionManager(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyAccessToken = 'fikraty_access_token';
  static const String _keyRefreshToken = 'fikraty_refresh_token';
  static const String _keyUserId = 'fikraty_user_id';
  static const String _keyUserEmail = 'fikraty_user_email';
  static const String _keyUserName = 'fikraty_user_name';
  static const String _keyUserRole = 'fikraty_user_role';
  static const String _keyUserPhone = 'fikraty_user_phone';
  static const String _keyEmailConfirmed = 'fikraty_email_confirmed';
  static const String _keyPendingStartup = 'fikraty_pending_startup';
  static const String _keyPendingInvestor = 'fikraty_pending_investor';

  String? get accessToken => _prefs.getString(_keyAccessToken);
  String? get refreshToken => _prefs.getString(_keyRefreshToken);
  String? get pendingStartupJson => _prefs.getString(_keyPendingStartup);
  String? get pendingInvestorJson => _prefs.getString(_keyPendingInvestor);

  bool get isAuthenticated {
    final token = accessToken;
    return token != null && token.isNotEmpty;
  }

  AuthUser? get cachedUser {
    final id = _prefs.getString(_keyUserId);
    final email = _prefs.getString(_keyUserEmail);
    final name = _prefs.getString(_keyUserName);
    final roleStr = _prefs.getString(_keyUserRole);

    if (id == null || email == null || name == null || roleStr == null) {
      return null;
    }

    final role = UserRoleX.fromString(roleStr);

    final phone = _prefs.getString(_keyUserPhone);
    final emailConfirmed = _prefs.getBool(_keyEmailConfirmed) ?? false;

    return AuthUser(
      id: id,
      email: email,
      role: role,
      phone: phone,
      emailConfirmed: emailConfirmed,
      profile: UserProfileData(fullName: name),
    );
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required AuthUser user,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    await _prefs.setString(_keyRefreshToken, refreshToken);
    await _prefs.setString(_keyUserId, user.id);
    await _prefs.setString(_keyUserEmail, user.email);
    await _prefs.setString(_keyUserName, user.profile.fullName);
    await _prefs.setString(_keyUserRole, user.role.name);

    if (user.phone != null) {
      await _prefs.setString(_keyUserPhone, user.phone!);
    } else {
      await _prefs.remove(_keyUserPhone);
    }

    await _prefs.setBool(_keyEmailConfirmed, user.emailConfirmed);
  }

  Future<void> setEmailConfirmed(bool confirmed) async {
    await _prefs.setBool(_keyEmailConfirmed, confirmed);
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    await _prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<void> savePendingProfileData({
    String? startupJson,
    String? investorJson,
  }) async {
    if (startupJson != null) {
      await _prefs.setString(_keyPendingStartup, startupJson);
    } else {
      await _prefs.remove(_keyPendingStartup);
    }

    if (investorJson != null) {
      await _prefs.setString(_keyPendingInvestor, investorJson);
    } else {
      await _prefs.remove(_keyPendingInvestor);
    }
  }

  Future<void> clearPendingProfileData() async {
    await _prefs.remove(_keyPendingStartup);
    await _prefs.remove(_keyPendingInvestor);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserPhone);
    await _prefs.remove(_keyEmailConfirmed);
    await clearPendingProfileData();
  }
}
