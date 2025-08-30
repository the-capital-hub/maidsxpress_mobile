import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'package:get_storage/get_storage.dart';

import '../models/user_model.dart';
import '../utils/constant/const_data.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final GetStorage _storage = GetStorage();
  UserModel? _currentUser;

  factory AuthService() => _instance;

  AuthService._internal();

  UserModel? get currentUser {
    final userData = _storage.read(AppConstants.userDataKey);
    return userData != null ? UserModel.fromJson(userData) : null;
  }

  String? get token {
    // First check in-memory user
    if (_currentUser?.token != null && _currentUser!.token!.isNotEmpty) {
      debugPrint('Using token from current user');
      return _currentUser!.token;
    }
    
    // Then check storage for token
    final storedToken = _storage.read('token');
    if (storedToken != null && storedToken is String && storedToken.isNotEmpty) {
      debugPrint('Using token from storage');
      return storedToken;
    }
    
    // If we have user data but no token, try to load from user data
    final userData = _storage.read(AppConstants.userDataKey);
    if (userData != null && userData is Map<String, dynamic>) {
      try {
        final user = UserModel.fromJson(userData);
        if (user.token != null && user.token!.isNotEmpty) {
          debugPrint('Found token in user data');
          _currentUser = user;
          return user.token;
        }
      } catch (e) {
        debugPrint('Error parsing user data: $e');
      }
    }
    
    debugPrint('No valid token found');
    return null;
  }

  // Alias for token getter for backward compatibility
  String? get getToken => token;

  Future<void> saveUserData(UserModel user) async {
    debugPrint('Saving user data: ${user.toJson()}');
    _currentUser = user;
    // Save both the full user data and the token separately for quick access
    await _storage.write(AppConstants.userDataKey, user.toJson());
    if (user.token != null) {
      await _storage.write('token', user.token);
      debugPrint('Token saved successfully');
    } else {
      debugPrint('Warning: Attempted to save null token');
    }
  }

  Future<void> _clearAuthData() async {
    debugPrint('Clearing auth data');
    _currentUser = null;
    await _storage.remove(AppConstants.userDataKey);
    await _storage.remove('token');
  }
  
  Future<void> clearUserData() async {
    await _clearAuthData();
  }

  Future<bool> get isLoggedIn async {
    // Check token directly using the token getter which has all the fallback logic
    final currentToken = token;
    final isLoggedIn = currentToken != null && currentToken.isNotEmpty;
    
    debugPrint('isLoggedIn check - Token valid: $isLoggedIn');
    if (!isLoggedIn) {
      // Clear any partial/invalid data
      await _clearAuthData();
    }
    return isLoggedIn;
  }
}

final authService = AuthService();
