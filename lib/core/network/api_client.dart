import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../session/session_manager.dart';
import 'auth_interceptor.dart';
import 'network_exceptions.dart';

class ApiClient {
  ApiClient({required SessionManager sessionManager}) {
    final baseOptions = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(baseOptions);

    // Dedicated clean Dio instance for token refresh to avoid interceptor deadlock
    final refreshDio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      AuthInterceptor(
        sessionManager: sessionManager,
        refreshDio: refreshDio,
      ),
    );
  }

  late final Dio _dio;

  Dio get rawDio => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException e) {
    final response = e.response;
    if (response != null && response.data != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // Extract validation errors if present (RFC 7807 ValidationProblemDetails)
        Map<String, List<String>>? fieldErrors;
        String? combinedErrors;

        if (data['errors'] is Map) {
          final errorsMap = data['errors'] as Map;
          fieldErrors = {};
          final errorList = <String>[];

          errorsMap.forEach((key, val) {
            final keyStr = key.toString();
            if (val is List) {
              final msgs = val.map((item) => item.toString()).toList();
              fieldErrors![keyStr] = msgs;
              errorList.addAll(msgs);
            } else if (val is String) {
              fieldErrors![keyStr] = [val];
              errorList.add(val);
            }
          });

          if (errorList.isNotEmpty) {
            combinedErrors = errorList.join('\n');
          }
        }

        DateTime? lockedUntil;
        if (data['lockedUntil'] != null) {
          lockedUntil = DateTime.tryParse(data['lockedUntil'].toString());
        }

        final message = combinedErrors ??
            data['detail'] as String? ??
            data['message'] as String? ??
            data['title'] as String? ??
            (response.statusCode == 429
                ? 'Too many requests. Please wait a minute and try again.'
                : 'An error occurred (${response.statusCode}).');

        final code = data['code'] as String?;

        return ApiException(
          message,
          statusCode: response.statusCode,
          code: code,
          fieldErrors: fieldErrors,
          lockedUntil: lockedUntil,
        );
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException('Connection timed out. Please check your internet connection.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const ApiException('Unable to connect to the server. Please check your connection.');
    }

    return ApiException(e.message ?? 'An unexpected network error occurred.');
  }
}
