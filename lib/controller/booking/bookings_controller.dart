import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/booking_model.dart';
import '../../../utils/constant/const_data.dart';
import '../../../models/coupon_model.dart';
import '../../../utils/debug/booking_debug_helper.dart';

class BookingsController extends GetxController {
  static BookingsController get to => Get.find();

  final RxList<Booking> bookings = <Booking>[].obs;
  final Rx<Booking?> selectedBooking = Rx<Booking?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  int _currentPage = 1;
  final int _perPage = 10;
  bool _isLoadingMore = false;

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

  Future<void> downloadReceipt(String receiptId) async {
    try {
      isLoading.value = true;
      developer.log('downloadReceipt: Start for receipt ID: $receiptId');

      final token = _authToken;
      
      // Use the correct endpoint: /api/receipt/[orderId or bookingId]
      // Since baseUrl already includes /api, we just use /receipt/$receiptId
      final url = '/receipt/$receiptId';
      final fullUrl = '${_dio.options.baseUrl}$url';
      
      developer.log('downloadReceipt: Full URL: $fullUrl');
      developer.log('downloadReceipt: Token available: ${token != null}');

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
        ),
      );

      developer.log('downloadReceipt: Response status: ${response.statusCode}');
      developer.log('downloadReceipt: Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200 && response.data is List<int>) {
        final bytes = List<int>.from(response.data as List<int>);
        final Directory dir = await getApplicationDocumentsDirectory();
        final String filePath = '${dir.path}/receipt_$receiptId.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        developer.log('downloadReceipt: Saved to $filePath');
        await OpenFilex.open(filePath);
        HelperSnackBar.success('Receipt downloaded successfully');
      } else {
        developer.log('downloadReceipt: Failed status ${response.statusCode}');
        if (response.statusCode == 404) {
          HelperSnackBar.error('Receipt not found. Please try again later.');
        } else {
          HelperSnackBar.error('Failed to download receipt. Status: ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      developer.log('downloadReceipt: Exception caught: $e');
      developer.log('downloadReceipt: Stack trace: $stackTrace');
      HelperSnackBar.error('Failed to download receipt: $e');
    } finally {
      isLoading.value = false;
    }
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
        final allBookings = [
          ...result.data.bookings.completed,
          ...result.data.bookings.upcoming,
          ...result.data.bookings.cancelled,
        ].map((b) => Booking.fromJson(b.toJson())).toList();
        
        // Expand bookings into separate orders
        final expandedBookings = <Booking>[];
        for (var booking in allBookings) {
          expandedBookings.addAll(booking.expandToOrders());
        }
        
        bookings.assignAll(expandedBookings);
        developer.log(
            'getAllBookings: Successfully loaded ${expandedBookings.length} bookings (expanded from ${allBookings.length} original bookings)');
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

  Future<bool> getBookings({String? status, bool loadMore = false}) async {
    if (_authToken == null) {
      developer.log('getBookings: No auth token, will redirect to login');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        Get.offAllNamed('/login');
      });
      return false;
    }

    // Don't load more if already loading or no more items
    if ((_isLoadingMore || !hasMore.value) && loadMore) return false;

    try {
      if (!loadMore) {
        isLoading.value = true;
        _currentPage = 1;
        hasMore.value = true;
      } else {
        _isLoadingMore = true;
        _currentPage++;
      }

      final queryParams = {
        'page': _currentPage,
        'per_page': _perPage,
        if (status != null) 'status': status,
      };

      developer.log(
          'getBookings: Fetching page $_currentPage with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.getBookings,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final result = AllBookingsResponse.fromJson(response.data);
        final allBookings = [
          ...result.data.bookings.completed,
          ...result.data.bookings.upcoming,
          ...result.data.bookings.cancelled,
        ].map((b) => Booking.fromJson(b.toJson())).toList();

        // Expand bookings into separate orders
        final expandedBookings = <Booking>[];
        for (var booking in allBookings) {
          expandedBookings.addAll(booking.expandToOrders());
        }

        if (loadMore) {
          bookings.addAll(expandedBookings);
        } else {
          bookings.assignAll(expandedBookings);
        }

        // Check if we have more items to load
        hasMore.value = expandedBookings.length >= _perPage;

        errorMessage.value = '';
        return true;
      }

      _handleError(DioException(
        requestOptions: RequestOptions(path: ApiConstants.getBookings),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return false;
    } catch (e) {
      final error = _toDioException(e, ApiConstants.getBookings);
      _handleError(error);
      return false;
    } finally {
      isLoading.value = false;
      _isLoadingMore = false;
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

  // Get all bookings with optional status filter

  // Load more bookings for current filter
  Future<void> loadMoreBookings({String? status}) async {
    if (!_isLoadingMore && hasMore.value) {
      await getBookings(status: status, loadMore: true);
    }
  }

  // Refresh bookings list
  Future<void> refreshBookings({String? status}) async {
    await getBookings(status: status, loadMore: false);
  }

  // Get cancelled bookings with pagination
  Future<List<Booking>> getCancelledBookings({bool loadMore = false}) async {
    final success = await getBookings(status: 'cancelled', loadMore: loadMore);
    return success
        ? bookings.where((b) => b.bookingStatus == 'cancelled').toList()
        : [];
  }

  // Get upcoming bookings with pagination
  Future<List<Booking>> getUpcomingBookings({bool loadMore = false}) async {
    final success = await getBookings(status: 'upcoming', loadMore: loadMore);
    return success
        ? bookings.where((b) => b.bookingStatus == 'upcoming').toList()
        : [];
  }

  // Get completed bookings with pagination
  Future<List<Booking>> getCompletedBookings({bool loadMore = false}) async {
    final success = await getBookings(status: 'completed', loadMore: loadMore);
    return success
        ? bookings.where((b) => b.bookingStatus == 'completed').toList()
        : [];
  }

  // Get in-progress bookings
  Future<List<Booking>> getInProgressBookings() async {
    final success = await getBookings(status: 'in-progress');
    return success
        ? bookings.where((b) => b.bookingStatus == 'in-progress').toList()
        : [];
  }

  // Get booking by ID
  Future<Booking?> getBooking(String bookingId) async {
    try {
      isLoading.value = true;
      developer.log('getBooking: Fetching booking ID: $bookingId');

      // First check in local list
      final localBooking = bookings.firstWhereOrNull((b) => b.id == bookingId);
      if (localBooking != null) {
        return localBooking;
      }

      // If not found locally, fetch from API
      final response = await _dio.get(ApiConstants.getBookingById(bookingId));

      if (response.statusCode == 200) {
        final bookingData = response.data['data'];
        if (bookingData != null) {
          final booking = Booking.fromJson(bookingData);
          // Add to local list if not exists
          if (!bookings.any((b) => b.id == booking.id)) {
            bookings.add(booking);
          }
          return booking;
        }
      }

      return null;
    } catch (e) {
      _handleError(_toDioException(e, 'getBooking'));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    try {
      isLoading.value = true;
      developer.log('cancelBooking: Cancelling booking ID: $bookingId');

      final response = await _dio.patch(
        ApiConstants.cancelBooking(bookingId),
        data: {'cancellationReason': reason},
      );

      if (response.statusCode == 200) {
        // Update local booking status
        final index = bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          final updatedBooking = bookings[index].copyWith(
            bookingStatus: 'cancelled',
            updatedAt: DateTime.now(),
          );
          bookings[index] = updatedBooking;
        } else {
          // If booking not found in local list, refresh the list
          await getAllBookings();
        }

        return true;
      }

      // Handle specific error cases
      if (response.statusCode != 404) {
        _handleError(DioException(
          requestOptions:
              RequestOptions(path: ApiConstants.cancelBooking(bookingId)),
          response: response,
          type: DioExceptionType.badResponse,
        ));
      }

      return false;
    } catch (e) {
      _handleError(_toDioException(e, 'cancelBooking'));
      return false;
    } finally {
      isLoading.value = false;
      developer.log('cancelBooking: Completed, isLoading: ${isLoading.value}');
    }
  }

  Future<ApplyCouponResult?> applyCoupon({
    required String code,
    required num totalAmount,
  }) async {
    try {
      isLoading.value = true;
      developer.log('applyCoupon: Applying $code on total $totalAmount');

      final response = await _dio.post(
        ApiConstants.applyCoupon,
        data: {
          'code': code,
          'totalAmount': totalAmount,
        },
      );

      if (response.statusCode == 200) {
        final result = ApplyCouponResult.fromJson(
            Map<String, dynamic>.from(response.data));
        return result;
      }

      _handleError(DioException(
        requestOptions: RequestOptions(path: ApiConstants.applyCoupon),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return null;
    } catch (e) {
      _handleError(_toDioException(e, ApiConstants.applyCoupon));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createBooking(Booking booking) async {
    if (_authToken == null) {
      developer
          .log('createBooking: No auth token available, redirecting to login');
      Get.offAllNamed('/login');
      return false;
    }

    try {
      isLoading.value = true;
      developer.log('createBooking: Starting booking creation');
      developer
          .log('createBooking: Auth token: ${_authToken?.substring(0, 10)}...');
      developer.log('createBooking: Request payload: ${booking.toJson()}');
      developer
          .log('createBooking: Sending POST to ${ApiConstants.createBooking}');

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
            if (response.data['data'] is Map &&
                response.data['data']['booking'] is Map) {
              bookingData =
                  Map<String, dynamic>.from(response.data['data']['booking']);
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
              developer.log(
                  'createBooking: Successfully added booking ID: ${newBooking.id}');
              return true;
            } catch (parseError) {
              developer.log('Error parsing booking data: $parseError');
              developer.log('Problematic booking data: $bookingData');
            }
          }

          developer.log(
              'createBooking: Unexpected response format: ${response.data}');
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

  Future<Booking?> createBookingReturn(Booking booking) async {
    if (_authToken == null) {
      developer
          .log('createBookingReturn: No auth token available, redirecting to login');
      Get.offAllNamed('/login');
      return null;
    }

    try {
      isLoading.value = true;
      developer.log('═══════════════════════════════════════════════════════');
      developer.log('🔐 API CALL #1: CREATE BOOKING');
      developer.log('═══════════════════════════════════════════════════════');
      developer.log('📡 FULL URL: https://maidsxpress.com/api/booking/createBooking');
      developer.log('📡 METHOD: POST');
      developer.log('📦 FULL REQUEST BODY:');
      developer.log(json.encode(booking.toJson()));
      developer.log('📦 Headers:');
      developer.log('  - Authorization: Bearer ${_authToken!.substring(0, 20)}...');
      developer.log('  - Content-Type: application/json');

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

      developer.log('📥 RESPONSE STATUS: ${response.statusCode}');
      developer.log('📥 FULL RESPONSE DATA:');
      developer.log(json.encode(response.data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Debug the response
        BookingDebugHelper.debugBookingResponse(response.data);
        
        Map<String, dynamic>? bookingData;
        if (response.data is Map) {
          if (response.data['data'] is Map &&
              response.data['data']['booking'] is Map) {
            bookingData =
                Map<String, dynamic>.from(response.data['data']['booking']);
            developer.log('createBookingReturn: Found booking in data.booking');
          } else if (response.data['booking'] is Map) {
            bookingData = Map<String, dynamic>.from(response.data['booking']);
            developer.log('createBookingReturn: Found booking in response.booking');
          } else if (response.data['_id'] != null) {
            bookingData = Map<String, dynamic>.from(response.data);
            developer.log('createBookingReturn: Found booking in response root');
          }
        }

        if (bookingData != null) {
          developer.log('createBookingReturn: Parsing booking data: $bookingData');
          final newBooking = Booking.fromJson(bookingData);
          developer.log('createBookingReturn: Parsed booking - Amount: ${newBooking.amount}');
          developer.log('createBookingReturn: Parsed booking - Service: ${newBooking.service.name}');
          developer.log('createBookingReturn: Parsed booking - Selected SubServices: ${newBooking.service.selectedSubServices.length}');
          
          if (!bookings.any((b) => b.id == newBooking.id)) {
            bookings.add(newBooking);
          }
          return newBooking;
        }

        // Fallback: refresh and try to find last booking by createdAt
        developer.log('createBookingReturn: No booking data found, refreshing bookings');
        await getAllBookings();
        return bookings.isNotEmpty ? bookings.last : null;
      }

      _handleError(DioException(
        requestOptions: RequestOptions(path: ApiConstants.createBooking),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return null;
    } catch (e) {
      developer.log('Error in createBookingReturn: $e');
      _handleError(_toDioException(e, ApiConstants.createBooking));
      return null;
    } finally {
      isLoading.value = false;
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
    HelperSnackBar.error(errorMessage);
  }
}
