import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/bindings/app_bindings.dart';
import 'package:maidxpress/controller/auth/auth_controller.dart';
import 'package:maidxpress/services/auth_service.dart';
import 'package:maidxpress/screen/authScreen/loginScreen/login_screen.dart';
import 'package:maidxpress/screen/homeScreen/home_screen.dart';
import 'package:maidxpress/screen/landingScreen/landing_screen.dart';
import 'package:maidxpress/screen/onboardingScreen/onboarding_screens.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await GetStorage.init();

  // Initialize services and bindings
  Get.put(AuthService(), permanent: true);
  Get.put(AuthController(), permanent: true);

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
        GetPage(name: '/onboarding', page: () => OnboardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/landing', page: () => const LandingScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
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
