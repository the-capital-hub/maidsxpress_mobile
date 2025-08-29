class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;

  BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic) fromJsonT
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
        'success': success,
        'message': message,
        'data': data != null ? toJsonT(data as T) : null,
        'error': error,
      };
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
