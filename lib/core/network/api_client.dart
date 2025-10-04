import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // SSL 인증서 검증 우회 (개발 환경용)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add session cookie support
          options.extra['withCredentials'] = true;

          _logger.d('Request: ${options.method} ${options.path}');
          _logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('Body: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('Response: ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.message}');
          _logger.e('Response: ${error.response?.data}');

          if (error.response?.statusCode == 401) {
            // Token expired - redirect to login
            _handleUnauthorized();
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _handleUnauthorized() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_data');
    // Navigate to login screen - will be handled by the app
  }

  // GET Request
  Future<Response> get(
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
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
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
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
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
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
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
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  Exception _handleError(DioException error) {
    String message = '알 수 없는 오류가 발생했습니다';

    print('❌ [API] DioException caught!');
    print('❌ [API] Error type: ${error.type}');
    print('❌ [API] Error message: ${error.message}');
    print('❌ [API] Request URL: ${error.requestOptions.uri}');
    print('❌ [API] Request method: ${error.requestOptions.method}');
    print('❌ [API] Request data: ${error.requestOptions.data}');
    print('❌ [API] Response: ${error.response?.data}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '서버 연결 시간이 초과되었습니다';
        print('❌ [API] Timeout error - Server: ${error.requestOptions.uri.host}:${error.requestOptions.uri.port}');
        break;
      case DioExceptionType.badResponse:
        message = error.response?.data['error'] ??
            error.response?.data['message'] ??
            '서버 오류가 발생했습니다';
        print('❌ [API] Bad response - Status: ${error.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다';
        break;
      case DioExceptionType.unknown:
        print('❌ [API] Unknown error - Full message: ${error.message}');
        if (error.message?.contains('SocketException') ?? false) {
          message = '인터넷 연결을 확인해주세요';
          print('❌ [API] Socket Exception detected - Network connectivity issue');
        } else if (error.message?.contains('Connection refused') ?? false) {
          message = '서버에 연결할 수 없습니다';
          print('❌ [API] Connection refused - Server may be down or unreachable');
        } else if (error.message?.contains('Failed host lookup') ?? false) {
          message = 'DNS 조회 실패 - 네트워크 확인 필요';
          print('❌ [API] DNS lookup failed - Check network or server address');
        }
        break;
      default:
        message = '네트워크 오류가 발생했습니다';
        print('❌ [API] Default error case triggered');
    }

    print('❌ [API] Final error message: $message');
    return Exception(message);
  }

  // Set Token
  Future<void> setToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // Clear Token
  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_data');
  }
}
