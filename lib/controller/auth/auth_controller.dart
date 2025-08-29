import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/user_model.dart';
import '../../../utils/constant/const_data.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  // Load user data from storage
  Future<void> _loadUserData() async {
    final userData = _storage.read(AppConstants.userDataKey);
    if (userData != null) {
      user.value = UserModel.fromJson(userData);
      _dio.options.headers['Authorization'] = 'Bearer ${user.value!.token}';
    }
  }

  // Save user data to storage
  Future<void> _saveUserData(UserModel userData) async {
    await _storage.write(AppConstants.userDataKey, userData.toJson());
    _dio.options.headers['Authorization'] = 'Bearer ${userData.token}';
  }

  // Clear user data from storage
  Future<void> _clearUserData() async {
    await _storage.remove('token');
    await _storage.remove('userData');
    _dio.options.headers.remove('Authorization');
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      isLoading.value = true;
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _clearUserData();
      isLoading.value = false;
      // Navigate to login screen
      Get.offAllNamed('/login');
    }
  }

  // Send OTP for login
  Future<bool> sendLoginOtp({String? email, String? phone}) async {
    try {
      if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
        Get.snackbar('Error', 'Please enter email or phone number');
        return false;
      }

      isLoading.value = true;
      final data = {};
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      final response = await _dio.post(
        ApiConstants.loginSendOtp,
        data: data,
      );

      debugPrint('Login OTP Response: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP for login
  Future<bool> verifyLoginOtp({required String otp, String? email, String? phone}) async {
    try {
      isLoading.value = true;
      final data = {
        'otp': otp,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      };

      final response = await _dio.post(
        ApiConstants.verifyLoginOtp,
        data: data,
      );

      debugPrint('Verify OTP Response: ${response.data}');
      
      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data['data']);
        await _saveUserData(userData);
        // Save token to storage for auto-login
        await _storage.write('token', userData.token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP for registration
  Future<bool> sendRegisterOtp({required String email}) async {
    try {
      isLoading.value = true;
      final response = await _dio.post(
        ApiConstants.registerSendOtp,
        data: {'email': email},
      );

      debugPrint('Register OTP Response: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP for registration
  Future<bool> verifyRegisterOtp({
    required String otp,
    required String email,
  }) async {
    try {
      isLoading.value = true;
      final response = await _dio.post(
        ApiConstants.registerVerifyOtp,
        data: {'otp': otp, 'email': email},
      );

      if (response.statusCode == 200) {
        return true; // Registration continues with /auth/register
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Register user after verifying OTP
  Future<bool> register(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _dio.post(ApiConstants.register, data: data);

      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data['data']);
        user.value = userData;
        await _saveUserData(userData);
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get user profile
  Future<bool> getProfile() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data['data']);
        user.value = userData;
        await _saveUserData(userData);
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _dio.put(ApiConstants.updateProfile, data: data);

      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data['data']);
        user.value = userData;
        await _saveUserData(userData);
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      isLoading.value = true;
      await _dio.post(ApiConstants.logout);
      user.value = null;
      await _clearUserData();
      return true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Handle API errors
  void _handleError(DioException e) {
    String errorMessage = 'An error occurred. Please try again.';

    if (e.response?.data != null && e.response?.data is Map) {
      errorMessage = e.response?.data['message'] ?? errorMessage;
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage =
          'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Request timeout. Please try again.';
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
