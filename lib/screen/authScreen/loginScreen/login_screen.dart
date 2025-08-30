import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/screen/authScreen/otpScreen/otp_screen..dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final RxBool isLoading = false.obs;

  final dynamic args = Get.arguments;
  String? returnRoute;
  dynamic routeArgs;

  @override
  void initState() {
    super.initState();
    // Extract return route from arguments if provided
    if (args is Map<String, dynamic>) {
      returnRoute = (args['returnRoute'] as String?)?.toString();
      routeArgs = args['args'];
    }

    // Check if user is already logged in
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
      // Clear the pending booking
      await prefs.remove('pending_booking');

      // Navigate back to the order summary screen with the stored data
      if (pendingBooking['route'] != null) {
        final returnRoute = pendingBooking['route'] as String;
        final args = pendingBooking['args'];
        
        if (returnRoute.isNotEmpty) {
          // Use the stored route and args to navigate back
          Get.offAllNamed(
            returnRoute,
            arguments: args,
          );
        } else {
          // Fallback to home if no route is specified
          Get.offAllNamed('/home');
        }
        //     'selectedOptions': selectedOptions,
        //     'selectedDate': selectedDate,
        //     'selectedTime': selectedTime,
        //     'addressId': addressId,
        //   },
        // );
      }
    }
  }

  void _redirectAfterLogin() {
    if (returnRoute != null) {
      // If we have a return route, navigate back to it with the original arguments
      Get.offAllNamed(returnRoute!, arguments: routeArgs);
    } else {
      // Otherwise, go to the default landing page
      Get.offAllNamed('/landing');
    }
  }

  Future<void> _sendOtp() async {
    final input = loginController.text.trim();

    if (input.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter phone or email to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if input is email or phone
    final isEmail = GetUtils.isEmail(input);
    final isPhone =
        GetUtils.isPhoneNumber(input) || GetUtils.isNumericOnly(input);

    if (!isEmail && !isPhone) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number or email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final success = await AuthController.to.sendLoginOtp(
        phoneOrEmail: input,
      );

      if (success) {
        Get.snackbar(
          'Success',
          'OTP sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.to(
          () => OtpScreen(
            email: isEmail ? input : null,
            phone: isPhone ? input : null,
            onVerificationSuccess: _redirectAfterLogin,
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      textSize: 20),
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
                    fontWeight: FontWeight.w500),
                const SizedBox(height: 12),

                // 📱 Single input for both email and phone
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

                const Row(children: [
                  Expanded(
                      child: Divider(
                    color: AppColors.grey,
                    endIndent: 5,
                  )),
                  TextWidget(
                    text: "Or",
                    textSize: 12,
                    color: AppColors.grey,
                  ),
                  Expanded(
                      child: Divider(
                    indent: 5,
                    color: AppColors.grey,
                  ))
                ]),
                sizedTextfield,
                sizedTextfield,

                FadeInUp(
                  child: AppButton.outlineButton(
                      onButtonPressed: () {},
                      title: "  Continue with Google",
                      borderColor: AppColors.blackCard,
                      icon: Image.asset(PngAssetPath.googleImg, height: 25)),
                ),
                const SizedBox(height: 18),
                FadeInUp(
                  child: AppButton.outlineButton(
                      onButtonPressed: () {},
                      title: "  Continue with Apple",
                      borderColor: AppColors.blackCard,
                      icon: Image.asset(PngAssetPath.appleImg, height: 25)),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Obx(
            () => AppButton.primaryButton(
              onButtonPressed: isLoading.value ? null : _sendOtp,
              title: isLoading.value ? 'Sending OTP...' : 'Get OTP',
              isLoading: isLoading.value,
            ),
          ),
        ),
      ),
    );
  }
}
