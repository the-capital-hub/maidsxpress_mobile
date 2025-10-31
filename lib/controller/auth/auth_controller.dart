import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';

import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constant/const_data.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  // Load user data from storage
  Future<void> _loadUserData() async {
    user.value = _authService.currentUser;
    if (user.value != null) {
      _dio.options.headers['Authorization'] = 'Bearer ${user.value!.token}';
    }
  }

  // Save user data to storage
  Future<void> _saveUserData(UserModel userData) async {
    await _authService.saveUserData(userData);
    user.value = userData;
    _dio.options.headers['Authorization'] = 'Bearer ${userData.token}';
  }

  // Clear user data from storage
  Future<void> _clearUserData() async {
    await _authService.clearUserData();
    user.value = null;
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
  Future<bool> sendLoginOtp({required String phoneOrEmail}) async {
    try {
      if (phoneOrEmail.isEmpty) {
        Get.snackbar('Error', 'Please enter email or phone number');
        return false;
      }

      isLoading.value = true;
      final data = {};
      if (phoneOrEmail.isNotEmpty) {
        data['phoneOrEmail'] = phoneOrEmail;
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
  Future<bool> verifyLoginOtp({
    required String otp,
    required String phoneOrEmail,
  }) async {
    try {
      isLoading.value = true;
      final data = {'otp': otp, 'phoneOrEmail': phoneOrEmail};
      final response = await _dio.post(
        ApiConstants.verifyLoginOtp,
        data: data,
      );

      debugPrint('Verify OTP Response: ${response.data}');

      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data['data']);
        if (userData.token == null || userData.token!.isEmpty) {
          throw Exception('No token received from server');
        }
        // Save user data and token to local storage
        await _saveUserData(userData);
        final storage = GetStorage();
        await storage.write('token', userData.token);
        await storage.write('user', userData.toJson());

        // Update auth state
        user.value = userData;
        _dio.options.headers['Authorization'] = 'Bearer ${userData.token}';

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

  // Send OTP for registration (supports sending both phone and email)
  Future<bool> sendRegisterOtp({String? phone, String? email}) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> data = {};
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (email != null && email.isNotEmpty) data['email'] = email;

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.registerSendOtp}',
        data: data,
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

  // Verify OTP for registration (requires phone and otp)
  Future<bool> verifyRegisterOtp({
    required String otp,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.registerVerifyOtp}',
        data: {'otp': otp, 'phone': phone},
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
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.register}',
        data: data,
      );

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
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.profile}',
      );

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
      final response = await _dio.put(
        '${ApiConstants.baseUrl}${ApiConstants.updateProfile}',
        data: data,
      );

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

    HelperSnackBar.error(errorMessage);
  }
}
