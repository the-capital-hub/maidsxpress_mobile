import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/otp_text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../utils/appcolors/app_colors.dart';
import '../../../utils/constant/asset_constant.dart';

class OtpScreen extends StatefulWidget {
  final String? phone;
  final String? email;

  const OtpScreen({super.key, this.phone, this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final RxBool isLoading = false.obs;
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = _storage.read('token');
    if (token != null && token.toString().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/landing');
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final success = await AuthController.to.verifyLoginOtp(
        otp: otp,
        email: widget.email,
        phone: widget.phone,
      );

      if (success) {
        // Navigate to home screen after successful verification
        Get.offAllNamed('/landing');
      } else {
        Get.snackbar(
          'Error',
          'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to verify OTP. Please try again.',
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
      appBar: HelperAppBar.appbarHelper(title: "Enter the OTP to continue"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(PngAssetPath.otpImg, height: 120),
            sizedTextfield,
            sizedTextfield,
            TextWidget(
              text: widget.phone != null
                  ? "Enter the code sent to ${widget.phone}"
                  : "Enter the code sent to ${widget.email}",
              textSize: 15,
              maxLine: 2,
              align: TextAlign.center,
              fontWeight: FontWeight.w500,
            ),
            sizedTextfield,
            const TextWidget(
              text:
                  "Please enter the verification code we sent. It might take a few minutes to receive your code.",
              maxLine: 3,
              align: TextAlign.center,
              textSize: 12,
            ),
            const SizedBox(height: 18),
            OtpTextField(
              controller: otpController,
              onCompleted: (v) {
                otpController.text = v;
              },
            ),
            const SizedBox(height: 18),
            const TextWidget(text: "Didn't receive the code?", textSize: 14),
            sizedTextfield,
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text: "Resend code by SMS",
                  textSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(width: 20),
                TextWidget(
                  text: "Change phone/email",
                  textSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() => AppButton.primaryButton(
          onButtonPressed: _verifyOtp,
          title: "Verify",
          isLoading: isLoading.value,
        )),
      ),
    );
  }
}
