import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/screen/authScreen/otpScreen/otp_screen..dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../services/auth_service.dart';
import '../registerScreen/register_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final RxBool isLoading = false.obs;

  String? returnRoute;
  dynamic routeArgs;

  void _initLoginCheck() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      returnRoute = (args['returnRoute'] as String?)?.toString();
      routeArgs = args['args'];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await authService.isLoggedIn;
    if (isLoggedIn) {
      await _handlePendingBooking();
      _redirectAfterLogin();
    }
  }

  Future<void> _handlePendingBooking() async {
    final prefs = GetStorage();
    final pendingBooking = await prefs.read('pending_booking');

    if (pendingBooking != null && pendingBooking is Map) {
      await prefs.remove('pending_booking');

      if (pendingBooking['route'] != null) {
        final returnRoute = pendingBooking['route'] as String;
        final args = pendingBooking['args'];

        if (returnRoute.isNotEmpty) {
          Get.offAllNamed(returnRoute, arguments: args);
        } else {
          Get.offAllNamed('/home');
        }
      }
    }
  }

  void _redirectAfterLogin() {
    if (returnRoute != null) {
      Get.offAllNamed(returnRoute!, arguments: routeArgs);
    } else {
      Get.offAllNamed('/landing');
    }
  }

  Future<void> _sendOtp() async {
    final input = loginController.text.trim();

    if (input.isEmpty) {
      HelperSnackBar.error('Please enter phone or email to continue');
      return;
    }

    final isEmail = GetUtils.isEmail(input);
    final isPhone =
        GetUtils.isPhoneNumber(input) || GetUtils.isNumericOnly(input);

    if (!isEmail && !isPhone) {
      HelperSnackBar.error('Please enter a valid phone number or email');
      return;
    }

    try {
      isLoading.value = true;
      final success = await AuthController.to.sendLoginOtp(
        phoneOrEmail: input,
      );

      if (success) {
        HelperSnackBar.success('OTP sent successfully');
        Get.to(
          () => OtpScreen(
            email: isEmail ? input : null,
            phone: isPhone ? input : null,
            onVerificationSuccess: _redirectAfterLogin,
          ),
        );
      }
    } catch (e) {
      HelperSnackBar.error('Failed to send OTP. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initLoginCheck();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                FadeInDown(
                  child: const TextWidget(
                    text: "MAIDSXPRESS",
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    textSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                ZoomIn(
                  child: const Row(
                    children: [
                      TextWidget(
                        text: "India’s #1 ",
                        textSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                      TextWidget(
                        text: "House",
                        textSize: 28,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
                FadeInLeft(
                  child: const Row(
                    children: [
                      TextWidget(
                        text: "Cleaning",
                        textSize: 28,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      TextWidget(
                        text: "App!",
                        textSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const TextWidget(
                  text: "Enter your mobile number or email to get OTP",
                  textSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 12),

                /// 📱 Input field
                FadeIn(
                  child: MyCustomTextField.textField(
                    hintText: "Enter mobile number or email",
                    lableText: "Mobile/Email",
                    textInputType: TextInputType.text,
                    controller: loginController,
                  ),
                ),
                sizedTextfield,
                sizedTextfield,

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => AppButton.primaryButton(
                  onButtonPressed: isLoading.value ? null : _sendOtp,
                  title: isLoading.value ? 'Sending OTP...' : 'Get OTP',
                  isLoading: isLoading.value,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextWidget(
                    text: "New to MaidsXpress?",
                    textSize: 14,
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const RegisterScreen());
                    },
                    child: const TextWidget(
                      text: "Register",
                      textSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
