import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'screen/landingScreen/landing_screen.dart';
import 'screen/onboardingScreen/onboarding_screens.dart';
import 'utils/getStore/get_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  GetStoreData.loadUserData();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Maidxpress',
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
      theme: ThemeData(
        useMaterial3: true,
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              return Colors.transparent;
            },
          ),
          trackOutlineWidth: WidgetStateProperty.resolveWith<double?>(
            (states) {
              return 0.0;
            },
          ),
        ),
      ),
    );
  }
}
