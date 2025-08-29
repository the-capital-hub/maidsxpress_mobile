class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://maidxpress.vercel.app/api';

  // ================== Auth Endpoints ==================
  static const String loginSendOtp = '/auth/login/send-otp';
  static const String verifyLoginOtp = '/auth/login/verify-otp';
  static const String logout = '/auth/logout';

  static const String registerSendOtp = '/auth/register/send-otp';
  static const String registerVerifyOtp = '/auth/register/verify-otp';
  static const String register = '/auth/register';

  // Profile
  static const String profile = '/auth/me';
  static const String updateProfile = '/auth/update-profile';

  // ================== Service Endpoints ==================
  static const String getServices = '/services/getServices';
  static String getServiceById(String serviceId) =>
      '/services/getServiceById/$serviceId';
}

class AppConstants {
  // App Info
  static const String appName = 'MaidsXpress';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Status
  static const String success = 'success';
  static const String error = 'error';
  static const String loading = 'loading';
}

class ValidationMessages {
  static const String emailRequired = 'Please enter your email';
  static const String invalidEmail = 'Please enter a valid email';
  static const String phoneRequired = 'Please enter your phone number';
  static const String invalidPhone =
      'Please enter a valid 10-digit phone number';
  static const String nameRequired = 'Please enter your name';
  static const String otpRequired = 'Please enter OTP';
  static const String invalidOtp = 'OTP must be 6 digits';
  static const String passwordRequired = 'Please enter password';
  static const String passwordLength = 'Password must be at least 6 characters';
}

final List<String> statesInIndia = [
  "Andhra Pradesh",
  "Arunachal Pradesh",
  "Assam",
  "Bihar",
  "Chhattisgarh",
  "Goa",
  "Gujarat",
  "New delhi",
  "Haryana",
  "Himachal Pradesh",
  "Jharkhand",
  "Karnataka",
  "Kerala",
  "Madhya Pradesh",
  "Maharashtra",
  "Manipur",
  "Meghalaya",
  "Mizoram",
  "Nagaland",
  "Odisha",
  "Punjab",
  "Rajasthan",
  "Sikkim",
  "Tamil Nadu",
  "Telangana",
  "Tripura",
  "Uttar Pradesh",
  "Uttarakhand",
  "West Bengal"
];
