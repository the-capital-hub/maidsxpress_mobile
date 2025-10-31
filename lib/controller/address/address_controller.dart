import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/services/auth_service.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
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
        // Maintain a valid selection
        if (addresses.isEmpty) {
          selectedAddress.value = null;
        } else if (selectedAddress.value == null) {
          selectedAddress.value = addresses.first;
        } else if (!addresses.any((a) => a.id == selectedAddress.value?.id)) {
          selectedAddress.value = addresses.first;
        }
      } else {
        HelperSnackBar.error(
            response.data["message"] ?? "Failed to load addresses");
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

      final response = await _apiClient.post(
        ApiConstants.addAddress,
        data: data,
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Reload addresses to get fresh list
        await loadAddresses();
        
        // Show snackbar after a small delay to ensure screen transition is complete
        Future.delayed(const Duration(milliseconds: 500), () {
          HelperSnackBar.success('Address added successfully ✓');
        });
        return true;
      }

      HelperSnackBar.error(response.data?['message'] ?? 'Failed to add address. Try again.');
      return false;
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('Error adding address: $e');
        HelperSnackBar.error('Failed to add address. Please try again.');
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

      // Create payload with id for the API
      final updateData = {
        'id': address.id,
        'label': address.label,
        'address': address.address,
        'phone': address.phone,
        'pincode': address.pincode,
        'isServiceable': address.isServiceable,
      };

      // Try PUT first
      try {
        final response = await _apiClient.put(
          ApiConstants.updateAddress,
          data: updateData,
          headers: {
            'Authorization': 'Bearer ${_authService.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          await loadAddresses();
          Future.delayed(const Duration(milliseconds: 500), () {
            HelperSnackBar.success('Address updated successfully ✓');
          });
          return true;
        }
      } catch (putError) {
        debugPrint('PUT failed, trying POST: $putError');
        
        final response = await _apiClient.post(
          ApiConstants.updateAddress,
          data: updateData,
          headers: {
            'Authorization': 'Bearer ${_authService.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          await loadAddresses();
          Future.delayed(const Duration(milliseconds: 500), () {
            HelperSnackBar.success('Address updated successfully ✓');
          });
          return true;
        }
      }

      HelperSnackBar.error('Failed to update address. Try again.');
      return false;
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('Error updating address: $e');
        HelperSnackBar.error('Failed to update address. Please try again.');
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

      // Send ID in the request body
      final deleteData = {
        'id': addressId,
      };

      // Try POST method with body
      try {
        final response = await _apiClient.post(
          ApiConstants.deleteAddress,
          data: deleteData,
          headers: {
            'Authorization': 'Bearer ${_authService.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          addresses.removeWhere((addr) => addr.id == addressId);
          // Fix selection if current was deleted
          if (selectedAddress.value?.id == addressId) {
            selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
          }
          return true;
        }
      } catch (postError) {
        // If POST fails, try DELETE
        debugPrint('POST method failed, trying DELETE: $postError');
        
        final response = await _apiClient.delete(
          ApiConstants.deleteAddress,
          data: deleteData,
          headers: {
            'Authorization': 'Bearer ${_authService.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          addresses.removeWhere((addr) => addr.id == addressId);
          if (selectedAddress.value?.id == addressId) {
            selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
          }
          return true;
        }
      }

      HelperSnackBar.error('Failed to delete address. Try again.');
      return false;
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('Error deleting address: $e');
        HelperSnackBar.error('Failed to delete address. Please try again.');
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
      HelperSnackBar.error(message);

      // Log the error for debugging
      debugPrint('AddressController Error: $error');
      if (error is DioException && error.response?.data != null) {
        debugPrint('Error response data: ${error.response?.data}');
      }
    }
  }
}
