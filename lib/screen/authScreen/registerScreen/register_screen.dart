import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/authScreen/otpScreen/otp_screen..dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../controller/auth/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> _sendRegisterOtp() async {
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (phone.isEmpty || email.isEmpty) {
      HelperSnackBar.error('Please enter both phone and email');
      return;
    }

    final isEmail = GetUtils.isEmail(email);
    final isPhone = GetUtils.isPhoneNumber(phone) || GetUtils.isNumericOnly(phone);
    if (!isEmail || !isPhone) {
      HelperSnackBar.error('Please enter a valid phone and email');
      return;
    }

    try {
      isLoading.value = true;
      final success = await AuthController.to.sendRegisterOtp(phone: phone, email: email);
      if (success) {
        HelperSnackBar.success('OTP sent successfully');
        Get.to(
          () => OtpScreen(
            email: email,
            phone: phone,
            isRegisterFlow: true,
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
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(text: 'Create your account', textSize: 16, fontWeight: FontWeight.w700),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                FadeInDown(
                  child: const TextWidget(
                    text: "Enter your mobile number or email",
                    textSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                FadeIn(
                  child: Column(
                    children: [
                      MyCustomTextField.textField(
                        hintText: "10-digit phone",
                        lableText: "Phone",
                        textInputType: TextInputType.phone,
                        controller: phoneController,
                      ),
                      const SizedBox(height: 12),
                      MyCustomTextField.textField(
                        hintText: "name@example.com",
                        lableText: "Email",
                        textInputType: TextInputType.emailAddress,
                        controller: emailController,
                      ),
                    ],
                  ),
                ),
                sizedTextfield,
                const TextWidget(
                  text: "We'll send an OTP to your phone to verify.",
                  textSize: 12,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() => AppButton.primaryButton(
              onButtonPressed: isLoading.value ? null : _sendRegisterOtp,
              title: isLoading.value ? 'Sending OTP...' : 'Get OTP',
              isLoading: isLoading.value,
            )),
      ),
    );
  }
}


