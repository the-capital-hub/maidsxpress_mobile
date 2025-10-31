import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/bindings/app_bindings.dart';

import 'package:maidxpress/core/network/api_client.dart';
import 'package:maidxpress/services/auth_service.dart';
import 'package:maidxpress/screen/authScreen/loginScreen/login_screen.dart';
import 'package:maidxpress/screen/authScreen/registerScreen/register_screen.dart';
import 'package:maidxpress/screen/authScreen/registerScreen/register_details_screen.dart';
import 'package:maidxpress/screen/homeScreen/home_screen.dart';
import 'package:maidxpress/screen/landingScreen/landing_screen.dart';
import 'package:maidxpress/screen/onboardingScreen/onboarding_screens.dart';
import 'package:maidxpress/screen/profileScreen/edit_profile_screen.dart';

import 'screen/paymentOptionScreen/payment_option_screen.dart';
import 'package:maidxpress/screen/paymentScreen/razorpay_payment_screen.dart';
import 'package:maidxpress/bindings/payment_binding.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await GetStorage.init();

  // Initialize core services first
  Get.put(ApiClient(), permanent: true);
  Get.put(AuthService(), permanent: true);

  // Initialize all bindings
  AppBindings().dependencies();

  // Check if it's first time
  final isFirstTime = GetStorage().read('isFirstTime') ?? true;
  final token = GetStorage().read('token');

  // Run the app with initial route
  runApp(MyApp(
    initialRoute: token != null && token.toString().isNotEmpty
        ? '/landing' // Changed from '/home' to '/landing'
        : isFirstTime
            ? '/onboarding'
            : '/login',
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Maidxpress',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/register-details', page: () => const RegisterDetailsScreen()),
        GetPage(name: '/landing', page: () => const LandingScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/paymentOptions', page: () => const PaymentOptionsScreen()),
        GetPage(
          name: '/razorpayPayment', 
          page: () => RazorpayPaymentScreen(
            booking: Get.arguments['booking'],
            amount: Get.arguments['amount'],
            userEmail: Get.arguments['userEmail'],
            userPhone: Get.arguments['userPhone'],
          ),
          binding: PaymentBinding(),
        ),
        
        GetPage(name: '/edit-profile', page: () => const EditProfileScreen()),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => Colors.transparent,
          ),
          trackOutlineWidth: WidgetStateProperty.resolveWith<double?>(
            (states) => 0.0,
          ),
        ),
      ),
    );
  }
}
