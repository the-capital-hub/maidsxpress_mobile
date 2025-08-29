import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  final String baseUrl =
      'https://maidsxpress.com/api'; // Replace with your API base URL

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
      ),
    );

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
        options: Options(headers: headers),
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
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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
        options: Options(headers: headers),
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
        options: Options(headers: headers),
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
