import 'dart:io';
import 'dart:developer' as developer;

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:maidxpress/core/network/api_client.dart';
import 'package:maidxpress/models/user_model.dart';
import 'package:maidxpress/services/auth_service.dart';
import 'package:maidxpress/utils/constant/const_data.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  late final ApiClient _apiClient;
  late final AuthService _authService;
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final Rx<String> _status = Rx<String>('idle');
  final Rx<String> _error = Rx<String>('');

  UserModel? get user => _user.value;
  String get status => _status.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize dependencies
    _apiClient = Get.find<ApiClient>();
    _authService = Get.find<AuthService>();

    // Sync token from auth service to api client
    final token = _authService.token;
    if (token != null) {
      _apiClient.token = token;
      developer.log('Token synced to ApiClient', name: 'UserController');
    }
  }

  // Get user profile
  Future<void> getUserProfile() async {
    try {
      developer.log('Starting getUserProfile', name: 'UserController');
      _status.value = 'loading';

      // Ensure token is synced
      final authToken = _authService.token;
      if (authToken != null) {
        _apiClient.token = authToken;
        developer.log('Token synced before API call', name: 'UserController');
      } else {
        developer.log('No token available', name: 'UserController');
        _error.value = 'No authentication token found. Please login again.';
        _status.value = 'error';
        return;
      }

      developer.log('Fetching profile from ${ApiConstants.profile}',
          name: 'UserController');
      final response = await _apiClient.get(ApiConstants.profile);

      developer.log('getUserProfile response status: ${response.statusCode}',
          name: 'UserController');

      if (response.statusCode == 200) {
        // Handle both response structures: direct 'user' or nested 'data.user'
        final userData =
            response.data['data']?['user'] ?? response.data['user'];
        if (userData != null) {
          _user.value = UserModel.fromJson(userData);
          _status.value = 'success';
          developer.log('Profile fetched successfully', name: 'UserController');
        } else {
          _error.value = 'Invalid response format';
          _status.value = 'error';
        }
      } else {
        _error.value = response.data['message'] ?? 'Failed to fetch profile';
        _status.value = 'error';
        developer.log('Failed to fetch profile: ${_error.value}',
            name: 'UserController');
      }
    } on dio.DioException catch (e) {
      _error.value =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      _status.value = 'error';
      developer.log('DioException in getUserProfile: ${e.response?.data}',
          name: 'UserController');

      // If unauthorized, clear token and redirect to login
      if (e.response?.statusCode == 401) {
        developer.log('Token expired or invalid, clearing auth data',
            name: 'UserController');
        await _authService.clearUserData();
        _apiClient.token = null;
        // You might want to navigate to login screen here
        Get.offAllNamed('/login');
      }
    } catch (e) {
      _error.value = e.toString();
      _status.value = 'error';
      developer.log('Error in getUserProfile: ${_error.value}',
          name: 'UserController');
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? city,
    String? address,
    String? gender,
    String? profilePicture,
  }) async {
    try {
      developer.log('Starting updateUserProfile', name: 'UserController');
      _status.value = 'loading';

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (city != null) updateData['city'] = city;
      if (address != null) updateData['address'] = address;
      if (gender != null) updateData['gender'] = gender;
      if (profilePicture != null) updateData['profilePicture'] = profilePicture;

      developer.log('Updating profile with data: $updateData',
          name: 'UserController');
      final response = await _apiClient.put(
        ApiConstants.updateProfile,
        data: updateData,
      );

      if (response.statusCode == 200) {
        // Handle both response structures: direct 'user' or nested 'data.user'
        final userData = response.data['data']?['user'] ??
            response.data['user'] ??
            response.data['data'];

        if (userData != null) {
          _user.value = UserModel.fromJson(
            (userData is Map ? Map<String, dynamic>.from(userData) : {})
                as Map<String, dynamic>,
          );
          _status.value = 'success';
          developer.log('Profile updated successfully', name: 'UserController');
          return true;
        }
        // Even if userData is null, still return true if status is 200
        _status.value = 'success';
        return true;
      } else {
        _error.value = response.data['message'] ?? 'Failed to update profile';
        _status.value = 'error';
        await HelperSnackBar.error('Failed to update profile: ${_error.value}');
        return false;
      }
    } catch (e) {
      _error.value = e.toString();
      _status.value = 'error';
      await HelperSnackBar.error('Error in updateUserProfile: ${_error.value}');
      return false;
    }
  }

  // Update profile picture
  Future<bool> updateProfilePicture(String imagePath) async {
    try {
      developer.log('Starting updateProfilePicture with image: $imagePath',
          name: 'UserController');
      _status.value = 'loading';

      // Validate file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        _error.value = 'Image file not found';
        _status.value = 'error';
        developer.log('Image file not found at path: $imagePath',
            name: 'UserController');
        return false;
      }

      // Check file size (max 5MB)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        _error.value = 'Image size should be less than 5MB';
        _status.value = 'error';
        developer.log('Image file too large: ${fileSize / (1024 * 1024)}MB',
            name: 'UserController');
        return false;
      }

      developer.log('Creating FormData for profile picture upload',
          name: 'UserController');
      final formData = dio.FormData.fromMap({
        'profilePicture': await dio.MultipartFile.fromFile(
          imagePath,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      developer.log('Sending profile picture update request',
          name: 'UserController');
      final response = await _apiClient.post(
        '${ApiConstants.updateProfile}/picture',
        data: formData,
        headers: {'Content-Type': 'multipart/form-data'},
      );

      if (response.statusCode == 200) {
        // Handle both response structures: direct 'user' or nested 'data.user'
        final userData =
            response.data['data']?['user'] ?? response.data['user'];
        if (userData != null) {
          _user.value = UserModel.fromJson(userData);
          _status.value = 'success';
          developer.log('Profile picture updated successfully',
              name: 'UserController');
          return true;
        } else {
          _error.value = 'Invalid response format';
          _status.value = 'error';
          return false;
        }
      } else {
        _error.value =
            response.data['message'] ?? 'Failed to update profile picture';
        _status.value = 'error';
        developer.log('Failed to update profile picture: ${_error.value}',
            name: 'UserController');
        return false;
      }
    } on dio.DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      _error.value = errorMessage;
      _status.value = 'error';
      developer.log('DioException in updateProfilePicture: $errorMessage',
          name: 'UserController');
      return false;
    } catch (e) {
      _error.value = 'An unexpected error occurred';
      _status.value = 'error';
      developer.log('Error in updateProfilePicture: $e',
          name: 'UserController');
      return false;
    }
  }

  // Clear user data on logout
  void clearUserData() {
    developer.log('Clearing user data', name: 'UserController');
    _user.value = null;
    _status.value = 'idle';
    _error.value = '';
    developer.log('User data cleared', name: 'UserController');
  }
}
