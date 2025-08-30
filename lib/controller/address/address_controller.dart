import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/services/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../models/address_model.dart';
import '../../utils/constant/const_data.dart';

class AddressController extends GetxController {
  static AddressController get to => Get.find();

  final RxList<Address> addresses = <Address>[].obs;
  final Rx<Address?> selectedAddress = Rx<Address?>(null);
  final RxBool isLoading = false.obs;

  late final ApiClient _apiClient;
  final AuthService _authService = AuthService();
  bool _isDisposed = false;

  // Using API endpoints from ApiConstants

  @override
  void onInit() {
    super.onInit();
    _apiClient = ApiClient();

    // Load addresses when controller initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAddresses();
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }

  void _checkAuthAndRedirect() {
    if (_isDisposed) return;

    final box = GetStorage();
    final token = box.read('token');
    final hasToken = token != null && token.toString().isNotEmpty;

    debugPrint('=== AUTH STATUS ===');
    debugPrint('Token exists: $hasToken');
    debugPrint('Token: ${token ?? 'null'}');
    debugPrint('==================');

    if (!hasToken) {
      debugPrint('No valid token, redirecting to login...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          Get.offAllNamed('/login');
        }
      });
    }
  }

  /// Fetch Addresses
  Future<void> loadAddresses() async {
    if (_isDisposed) return;

    final isLoggedIn = await _authService.isLoggedIn;
    if (!isLoggedIn) {
      debugPrint('User not authenticated');
      _checkAuthAndRedirect();
      return;
    }

    debugPrint('=== LOAD ADDRESSES REQUEST ===');
    debugPrint('Token: ${_authService.token}');
    debugPrint('Is logged in: ${_authService.isLoggedIn}');

    try {
      if (isLoading.value) return; // Prevent multiple simultaneous loads

      isLoading.value = true;

      final headers = {
        'Authorization': 'Bearer ${_authService.token}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      debugPrint('Sending request to: ${ApiConstants.getAddress}');
      debugPrint('Headers: $headers');

      final response =
          await _apiClient.get(ApiConstants.getAddress, headers: headers);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final addressResponse = AddressResponse.fromJson(response.data);
        addresses.assignAll(addressResponse.addresses);
        if (addresses.isNotEmpty && selectedAddress.value == null) {
          selectedAddress.value = addresses.first;
        }
      } else {
        Get.snackbar(
            "Error", response.data["message"] ?? "Failed to load addresses",
            duration: const Duration(seconds: 4));
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Add Address
  Future<bool> addAddress({
    required String label,
    required String address,
    required String phone,
    required String pincode,
    String? city,
    String? state,
    String? landmark,
  }) async {
    final isLoggedIn = await _authService.isLoggedIn;
    if (!isLoggedIn) {
      debugPrint('User not authenticated');
      _checkAuthAndRedirect();
      return false;
    }

    try {
      if (_isDisposed) return false;
      if (isLoading.value) return false;

      isLoading.value = true;

      final data = {
        'label': label,
        'address': address,
        'phone': phone,
        'pincode': pincode,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (landmark != null) 'landmark': landmark,
      };

      final response = await _apiClient.post(ApiConstants.addAddress,
          data: data,
          headers: {'Authorization': 'Bearer ${_authService.token}'});

      if (response.statusCode == 201) {
        await loadAddresses();
        return true;
      }

      return false;
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('Error adding address: $e');
        Get.snackbar(
          'Error',
          'Failed to add address. Please try again.',
          duration: const Duration(seconds: 3),
        );
      }
      return false;
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  /// Update Address
  Future<bool> updateAddress(Address address) async {
    final isLoggedIn = await _authService.isLoggedIn;
    if (!isLoggedIn) {
      debugPrint('User not authenticated');
      _checkAuthAndRedirect();
      return false;
    }

    try {
      if (_isDisposed) return false;
      if (isLoading.value) return false;

      isLoading.value = true;

      final response = await _apiClient.put(ApiConstants.updateAddress,
          data: address.toJson(),
          headers: {'Authorization': 'Bearer ${_authService.token}'});

      if (response.statusCode == 200) {
        await loadAddresses();
        return true;
      }

      return false;
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('Error updating address: $e');
        Get.snackbar(
          'Error',
          'Failed to update address. Please try again.',
          duration: const Duration(seconds: 3),
        );
      }
      return false;
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  /// Delete Address
  Future<bool> deleteAddress(String addressId) async {
    final isLoggedIn = await _authService.isLoggedIn;
    if (!isLoggedIn) {
      debugPrint('User not authenticated');
      _checkAuthAndRedirect();
      return false;
    }

    try {
      if (_isDisposed) return false;
      if (isLoading.value) return false;

      isLoading.value = true;

      final response = await _apiClient.delete(
          '${ApiConstants.deleteAddress}/$addressId',
          headers: {'Authorization': 'Bearer ${_authService.token}'});

      if (response.statusCode == 200) {
        addresses.removeWhere((address) => address.id == addressId);
        if (selectedAddress.value?.id == addressId) {
          selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
        }
        Get.snackbar("Success", "Address deleted successfully ✅",
            duration: const Duration(seconds: 4),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        return true;
      }

      return false;
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('Error deleting address: $e');
        Get.snackbar(
          'Error',
          'Failed to delete address. Please try again.',
          duration: const Duration(seconds: 3),
        );
      }
      return false;
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
  }

  /// Error Handler
  void _handleError(dynamic error) {
    String message = 'Something went wrong!';

    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'];
        } else if (error.type == DioExceptionType.connectionError) {
          message = 'No internet connection';
        } else if (error.message != null) {
          message = error.message!;
        }
      } else if (error.message != null) {
        message = error.message!;
      }
    } else if (error is Exception) {
      message = error.toString();
    }

    if (!_isDisposed) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Log the error for debugging
      debugPrint('AddressController Error: $error');
      if (error is DioException && error.response?.data != null) {
        debugPrint('Error response data: ${error.response?.data}');
      }
    }
  }
}
