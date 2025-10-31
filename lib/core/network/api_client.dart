import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:maidxpress/utils/constant/const_data.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  final String baseUrl = ApiConstants.baseUrl;
  final GetStorage _storage = GetStorage();

  // Get token from storage with fallback to 'token' key for compatibility
  String? get token {
    // First try the main token key
    String? authToken = _storage.read('token');
    if (authToken != null && authToken.isNotEmpty) {
      return authToken;
    }

    // Fallback to auth_token key
    authToken = _storage.read('auth_token');
    if (authToken != null && authToken.isNotEmpty) {
      return authToken;
    }

    return null;
  }

  // Set token to storage and update headers
  set token(String? value) {
    if (value != null && value.isNotEmpty) {
      _storage.write('token', value);
      _storage.write('auth_token', value); // Keep both for compatibility
      _dio.options.headers['Authorization'] = 'Bearer $value';
    } else {
      _storage.remove('token');
      _storage.remove('auth_token');
      _dio.options.headers.remove('Authorization');
    }
  }

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Set initial token if available
    final initialToken = token;
    if (initialToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $initialToken';
    }

    // Add interceptors
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );

    // Add token refresh interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Always ensure we have the latest token
          final currentToken = token;
          if (currentToken != null) {
            options.headers['Authorization'] = 'Bearer $currentToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 errors
          if (error.response?.statusCode == 401) {
            // Token might be expired, clear it
            token = null;
            // You could also trigger a logout here if needed
          }
          handler.next(error);
        },
      ),
    );
  }

  // Get auth headers for requests
  Map<String, String> getAuthHeaders([Map<String, String>? additionalHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add token if available
    final authToken = token;
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options:
            Options(headers: getAuthHeaders(headers?.cast<String, String>())),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ??
            Options(headers: getAuthHeaders(headers?.cast<String, String>())),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options:
            Options(headers: getAuthHeaders(headers?.cast<String, String>())),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options:
            Options(headers: getAuthHeaders(headers?.cast<String, String>())),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  dynamic _handleError(DioException error) {
    // Try to get error message from response
    if (error.response?.data != null) {
      if (error.response?.data is Map) {
        final errorData = error.response!.data as Map;
        if (errorData.containsKey('message')) {
          throw errorData['message'].toString();
        }
      } else if (error.response?.data is String) {
        throw error.response!.data as String;
      }
    }

    // Fallback to status code based messages
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        throw 'Connection timeout. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        throw 'Request timed out. Please try again.';
      case DioExceptionType.receiveTimeout:
        throw 'Server took too long to respond. Please try again.';
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            throw 'Bad request. Please check your input and try again.';
          case 401:
            throw 'Session expired. Please log in again.';
          case 403:
            throw 'You do not have permission to perform this action.';
          case 404:
            throw 'The requested resource was not found.';
          case 422:
            throw 'Validation failed. Please check your input.';
          case 429:
            throw 'Too many requests. Please try again later.';
          case 500:
            throw 'Server error. Please try again later.';
          default:
            throw 'An error occurred. Please try again.';
        }
      case DioExceptionType.cancel:
        throw 'Request was cancelled.';
      case DioExceptionType.unknown:
        throw 'No internet connection. Please check your network settings.';
      default:
        throw 'An unexpected error occurred. Please try again.';
    }
  }
}
