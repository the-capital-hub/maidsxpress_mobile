import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
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
  final VoidCallback? onVerificationSuccess;
  final bool isRegisterFlow;

  const OtpScreen({
    super.key,
    this.phone,
    this.email,
    this.onVerificationSuccess,
    this.isRegisterFlow = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _resendCode() async {
    try {
      isResending.value = true;
      final phone = widget.phone;
      final email = widget.email;

      bool success = false;
      if (widget.isRegisterFlow) {
        // Prefer SMS via phone if available, but also send email if provided
        success = await AuthController.to.sendRegisterOtp(
          phone: phone,
          email: email,
        );
      } else {
        final phoneOrEmail = phone ?? email;
        if (phoneOrEmail == null || phoneOrEmail.isEmpty) {
          HelperSnackBar.error('Phone or email required to resend code');
          return;
        }
        success = await AuthController.to.sendLoginOtp(
          phoneOrEmail: phoneOrEmail,
        );
      }

      if (success) {
        HelperSnackBar.success('Code resent successfully');
      }
    } catch (e) {
      HelperSnackBar.error('Failed to resend code');
    } finally {
      isResending.value = false;
    }
  }

  void _changeContact() {
    // Go back to the previous screen (login or register input)
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      // Fallback navigation
      Get.offAllNamed(widget.isRegisterFlow ? '/register' : '/login');
    }
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
      HelperSnackBar.error('Please enter the OTP');
      return;
    }

    try {
      isLoading.value = true;
      // Use either phone or email for verification
      final phoneOrEmail = widget.phone ?? widget.email;
      if (phoneOrEmail == null) {
        HelperSnackBar.error('Phone or email is required for verification');
        return;
      }

      // No local bypass. Backend will validate demo OTP (e.g., 000000) if configured.

      bool success;
      if (widget.isRegisterFlow) {
        // For register flow, backend expects phone + otp
        final phone = widget.phone;
        if (phone == null || phone.isEmpty) {
          HelperSnackBar.error('Phone is required for verification');
          return;
        }
        success = await AuthController.to.verifyRegisterOtp(
          otp: otp,
          phone: phone,
        );
      } else {
        success = await AuthController.to.verifyLoginOtp(
          otp: otp,
          phoneOrEmail: phoneOrEmail,
        );
      }

      if (success) {
        if (widget.isRegisterFlow) {
          // Proceed to registration details screen
          Get.toNamed('/register-details', arguments: {
            'phone': widget.phone,
            'email': widget.email,
          });
        } else {
          // Call the success callback if provided, otherwise go to landing
          if (widget.onVerificationSuccess != null) {
            widget.onVerificationSuccess!();
          } else {
            Get.offAllNamed('/landing');
          }
        }
      } else {
        HelperSnackBar.error('Invalid OTP. Please try again.');
      }
    } catch (e) {
      HelperSnackBar.error('Failed to verify OTP. Please try again.');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => GestureDetector(
                      onTap: isResending.value ? null : _resendCode,
                      child: TextWidget(
                        text: isResending.value ? "Resending..." : "Resend code by SMS",
                        textSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _changeContact,
                  child: const TextWidget(
                    text: "Change phone/email",
                    textSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
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
