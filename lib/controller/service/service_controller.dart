import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../models/service_model.dart';
import '../../../utils/constant/const_data.dart';

class ServicesController extends GetxController {
  static ServicesController get to => Get.find();

  final RxList<Service> services = <Service>[].obs; // All services
  final Rx<Service?> selectedService = Rx<Service?>(null); // Selected service
  final RxBool isLoading = false.obs;

  final _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  @override
  void onInit() {
    super.onInit();
    getAllServices();
  }

  // Get all services
  Future<bool> getAllServices() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(ApiConstants.getServices);

      if (response.statusCode == 200) {
        final result = ServiceResponse.fromJson(response.data);
        services.assignAll(result.data);
        return true;
      }
      _handleError(DioException(
        requestOptions: RequestOptions(path: ApiConstants.getServices),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return false;
    } catch (e) {
      if (e is DioException) {
        _handleError(e);
      } else {
        _handleError(DioException(
          requestOptions: RequestOptions(path: ApiConstants.getServices),
          error: e,
          type: DioExceptionType.unknown,
        ));
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get single service by ID
  Future<bool> getServiceById(String id) async {
    try {
      isLoading.value = true;
      final response = await _dio.get('${ApiConstants.getServiceById}/$id');

      if (response.statusCode == 200) {
        final result = response.data['data'];
        if (result != null && result is Map<String, dynamic>) {
          selectedService.value = Service.fromJson(result);
          return true;
        }
        _handleError(DioException(
          requestOptions:
              RequestOptions(path: '${ApiConstants.getServiceById}/$id'),
          error: 'Invalid response format',
          type: DioExceptionType.badResponse,
        ));
        return false;
      }
      _handleError(DioException(
        requestOptions:
            RequestOptions(path: '${ApiConstants.getServiceById}/$id'),
        response: response,
        type: DioExceptionType.badResponse,
      ));
      return false;
    } catch (e) {
      if (e is DioException) {
        _handleError(e);
      } else {
        _handleError(DioException(
          requestOptions:
              RequestOptions(path: '${ApiConstants.getServiceById}/$id'),
          error: e,
          type: DioExceptionType.unknown,
        ));
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Set selected service (for direct selection without API call)
  void setSelectedService(Service service) {
    selectedService.value = service;
  }

  // Handle API errors
  void _handleError(DioException e) {
    String errorMessage = 'An error occurred. Please try again.';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Request receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = e.response?.data['message']?.toString() ??
            'Server error: ${e.response?.statusCode ?? 'Unknown'}';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error. Please check your network.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Invalid certificate. Please contact support.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Unexpected error: ${e.message ?? e.toString()}';
        break;
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
