import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;
import '../../../models/booking_model.dart';
import '../../../utils/constant/const_data.dart';

class BookingsController extends GetxController {
  static BookingsController get to => Get.find();

  final RxList<Booking> bookings = <Booking>[].obs;
  final Rx<Booking?> selectedBooking = Rx<Booking?>(null);
  final RxBool isLoading = false.obs;

  final _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
  ));

  final _storage = GetStorage();

  String? get _authToken => _storage.read('token');

  @override
  void onInit() {
    super.onInit();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authToken;
        developer.log('Interceptor: Preparing request to ${options.path}');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          developer.log(
              'Interceptor: Added Bearer token: ${token.substring(0, 10)}...');
        } else {
          developer.log('Interceptor: No token found in storage');
        }
        options.headers['Content-Type'] = 'application/json';
        developer.log('Interceptor: Request headers: ${options.headers}');
        handler.next(options);
      },
      onError: (error, handler) {
        developer.log(
            'Interceptor: Error occurred: ${error.message}, Status: ${error.response?.statusCode}');
        if (error.response?.statusCode == 401) {
          developer.log(
              'Interceptor: 401 Unauthorized, removing token and redirecting to login');
          _storage.remove('token');
          Get.offAllNamed('/login');
          handler.reject(error);
          return;
        }
        handler.next(error);
      },
    ));
    getAllBookings();
  }

  Future<bool> getAllBookings() async {
    if (_authToken == null) {
      developer.log('getAllBookings: No auth token, will redirect to login');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        Get.offAllNamed('/login');
      });
      return false;
    }

    try {
      isLoading.value = true;
      developer.log(
          'getAllBookings: Fetching bookings from ${ApiConstants.getBookings}');
      final response = await _dio.get(ApiConstants.getBookings);
      developer.log(
          'getAllBookings: Response status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        final result = AllBookingsResponse.fromJson(response.data);
        bookings.assignAll([
          ...result.data.bookings.completed,
          ...result.data.bookings.upcoming,
          ...result.data.bookings.cancelled,
        ].map((b) => Booking.fromJson(b.toJson())).toList());
        developer.log(
            'getAllBookings: Successfully loaded ${bookings.length} bookings');
        return true;
      }
      _handleError(DioException(
        requestOptions: RequestOptions(path: ApiConstants.getBookings),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return false;
    } catch (e) {
      _handleError(_toDioException(e, ApiConstants.getBookings));
      return false;
    } finally {
      isLoading.value = false;
      developer.log('getAllBookings: Completed, isLoading: ${isLoading.value}');
    }
  }

  Future<bool> getBookingById(String id) async {
    try {
      isLoading.value = true;
      developer.log(
          'getBookingById: Fetching booking ID: $id from ${ApiConstants.getBookingById(id)}');
      final response = await _dio.get(ApiConstants.getBookingById(id));
      developer.log(
          'getBookingById: Response status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200 &&
          response.data['data'] is Map<String, dynamic>) {
        selectedBooking.value = Booking.fromJson(response.data['data']);
        developer.log(
            'getBookingById: Successfully set selectedBooking: ${selectedBooking.value?.id}');
        return true;
      }
      _handleError(DioException(
        requestOptions: RequestOptions(path: ApiConstants.getBookingById(id)),
        error: 'Invalid response format',
        type: DioExceptionType.badResponse,
      ));
      return false;
    } catch (e) {
      _handleError(_toDioException(e, ApiConstants.getBookingById(id)));
      return false;
    } finally {
      isLoading.value = false;
      developer.log('getBookingById: Completed, isLoading: ${isLoading.value}');
    }
  }

  Future<bool> createBooking(Booking booking) async {
    if (_authToken == null) {
      developer.log('createBooking: No auth token available, redirecting to login');
      Get.offAllNamed('/login');
      return false;
    }

    try {
      isLoading.value = true;
      developer.log('createBooking: Starting booking creation');
      developer.log('createBooking: Auth token: ${_authToken?.substring(0, 10)}...');
      developer.log('createBooking: Request payload: ${booking.toJson()}');
      developer.log('createBooking: Sending POST to ${ApiConstants.createBooking}');

      final response = await _dio.post(
        ApiConstants.createBooking,
        data: booking.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      developer.log('createBooking: Response status: ${response.statusCode}');
      developer.log('createBooking: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Handle different possible response formats
          Map<String, dynamic>? bookingData;
          
          if (response.data is Map) {
            // Case 1: Data is directly in response.data
            if (response.data['data'] is Map && response.data['data']['booking'] is Map) {
              bookingData = Map<String, dynamic>.from(response.data['data']['booking']);
            } 
            // Case 2: Data is directly in response.data.booking (without 'data' wrapper)
            else if (response.data['booking'] is Map) {
              bookingData = Map<String, dynamic>.from(response.data['booking']);
            }
            // Case 3: Response data is the booking itself
            else if (response.data['_id'] != null) {
              bookingData = Map<String, dynamic>.from(response.data);
            }
          }

          if (bookingData != null) {
            try {
              final newBooking = Booking.fromJson(bookingData);
              bookings.add(newBooking);
              developer.log('createBooking: Successfully added booking ID: ${newBooking.id}');
              return true;
            } catch (parseError) {
              developer.log('Error parsing booking data: $parseError');
              developer.log('Problematic booking data: $bookingData');
            }
          }
          
          developer.log('createBooking: Unexpected response format: ${response.data}');
          return true; // Still return true if the response indicates success
          
        } catch (e) {
          developer.log('Error processing booking response: $e');
          return true; // Still return true if the response status is 200/201
        }
      }
      
      _handleError(DioException(
        requestOptions: RequestOptions(path: ApiConstants.createBooking),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return false;
      
    } catch (e, stackTrace) {
      developer.log('Error in createBooking: $e');
      developer.log('Stack trace: $stackTrace');
      _handleError(_toDioException(e, ApiConstants.createBooking));
      return false;
    } finally {
      isLoading.value = false;
      developer.log('createBooking: Completed, isLoading: ${isLoading.value}');
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      isLoading.value = true;
      developer.log('cancelBooking: Cancelling booking ID: $bookingId');
      final response = await _dio.post(ApiConstants.cancelBooking(bookingId));
      developer.log(
          'cancelBooking: Response status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        bookings.removeWhere((booking) => booking.id == bookingId);
        if (selectedBooking.value?.id == bookingId) {
          selectedBooking.value = null;
        }
        developer
            .log('cancelBooking: Successfully removed booking ID: $bookingId');
        return true;
      }
      _handleError(DioException(
        requestOptions:
            RequestOptions(path: ApiConstants.cancelBooking(bookingId)),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return false;
    } catch (e) {
      _handleError(_toDioException(e, ApiConstants.cancelBooking(bookingId)));
      return false;
    } finally {
      isLoading.value = false;
      developer.log('cancelBooking: Completed, isLoading: ${isLoading.value}');
    }
  }

  void setSelectedBooking(Booking booking) {
    selectedBooking.value = booking;
    developer.log('setSelectedBooking: Set booking ID: ${booking.id}');
  }

  DioException _toDioException(dynamic e, String path) {
    return e is DioException
        ? e
        : DioException(
            requestOptions: RequestOptions(path: path),
            error: e,
            type: DioExceptionType.unknown,
          );
  }

  void _handleError(DioException e) {
    String errorMessage = 'An error occurred. Please try again.';
    developer.log('handleError: Processing error for ${e.requestOptions.path}');
    developer.log('handleError: Error type: ${e.type}, Message: ${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout. Check your internet.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request send timeout. Try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Request receive timeout. Try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage =
            e.response?.data is Map && e.response?.data['message'] != null
                ? e.response!.data['message'].toString()
                : 'Server error: ${e.response?.statusCode ?? 'Unknown'}';
        developer.log('handleError: Bad response details: ${e.response?.data}');
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error. Check your network.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Invalid certificate. Contact support.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
        break;
    }

    developer.log('handleError: Displaying error message: $errorMessage');
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }
}
