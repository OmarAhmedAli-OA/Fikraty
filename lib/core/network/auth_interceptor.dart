import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../session/session_manager.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.sessionManager,
    required this.refreshDio,
  });

  final SessionManager sessionManager;
  final Dio refreshDio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip token for unauthenticated endpoints
    final path = options.path;
    final isAnonymousAuthEndpoint = path.contains(ApiConstants.authLogin) ||
        path.contains(ApiConstants.authRegister) ||
        path.contains(ApiConstants.authRefresh) ||
        path.contains(ApiConstants.authForgotPassword) ||
        path.contains(ApiConstants.authResetPassword);

    if (!isAnonymousAuthEndpoint) {
      final token = sessionManager.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Only attempt refresh on 401 and when not already calling auth endpoints
    final isAuthEndpoint = path.contains(ApiConstants.authLogin) ||
        path.contains(ApiConstants.authRegister) ||
        path.contains(ApiConstants.authRefresh);

    if (statusCode == 401 && !isAuthEndpoint) {
      final currentRefreshToken = sessionManager.refreshToken;
      if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
        try {
          final refreshResponse = await refreshDio.post(
            ApiConstants.authRefresh,
            data: {
              'refreshToken': currentRefreshToken,
              'deviceInfo': 'Flutter Mobile Client',
            },
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final data = refreshResponse.data['data'] as Map<String, dynamic>;
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = data['refreshToken'] as String;

            await sessionManager.updateTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry the original request with the new access token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await refreshDio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Token refresh failed or revoked; clear local session
          await sessionManager.clearSession();
        }
      } else {
        await sessionManager.clearSession();
      }
    }

    handler.next(err);
  }
}
