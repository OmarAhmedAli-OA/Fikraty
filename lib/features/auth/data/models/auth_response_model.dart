import '../../domain/entities/auth.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // If the response is wrapped in ApiResponse<T>, unwrap 'data'
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final userJson = data['user'] as Map<String, dynamic>;

    return AuthResponseModel(
      accessToken: data['accessToken'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
      expiresIn: (data['expiresIn'] as num?)?.toInt() ?? 3600,
      tokenType: data['tokenType'] as String? ?? 'Bearer',
      user: parseUserFromJson(userJson),
    );
  }

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final AuthUser user;

  static AuthUser parseUserFromJson(Map<String, dynamic> json) {
    // Robust ID parsing: handles both numeric int and string representations
    final rawId = json['id'];
    final id = rawId != null ? rawId.toString() : '';

    final roleId = json['roleId'] as int?;
    final role = roleId != null
        ? UserRoleX.fromId(roleId)
        : UserRoleX.fromString(json['role'] as String?);

    final status = AccountStatusX.fromString(json['status'] as String?);

    final fullName = json['fullName'] as String? ?? '';
    final email = json['email'] as String? ?? '';
    final phone = json['phone'] as String?;
    final emailConfirmed = json['emailConfirmed'] as bool? ?? false;

    return AuthUser(
      id: id,
      email: email,
      role: role,
      phone: phone,
      accountStatus: status,
      emailConfirmed: emailConfirmed,
      profile: UserProfileData(fullName: fullName),
    );
  }
}
