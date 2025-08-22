import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/otp_text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../utils/appcolors/app_colors.dart';
import '../../../utils/constant/asset_constant.dart';
import '../moreInfoScreen/more_info_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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
            const TextWidget(
                text: "Enter the code that sent to your mobile phone.",
                textSize: 15,
                maxLine: 2,
                align: TextAlign.center,
                fontWeight: FontWeight.w500),
            sizedTextfield,
            const TextWidget(
                text:
                    "To finish registering. please enter the verification code we gave you. it might take few minutes to receive your code.",
                maxLine: 3,
                align: TextAlign.center,
                textSize: 12),
            const SizedBox(height: 18),
            OtpTextField(
                controller: TextEditingController(),
                onCompleted: (v) {
                  print(v);
                }),
            const SizedBox(height: 18),
            const TextWidget(text: "Didn't receive the code?", textSize: 14),
            sizedTextfield,
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextWidget(
                  text: "Resend code by SMS",
                  textSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(width: 20),
                TextWidget(
                  text: "Change phone number",
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
        padding: EdgeInsets.all(12),
        child: AppButton.primaryButton(
            onButtonPressed: () {
              Get.to(() => const MoreInfoScreen());
            },
            title: "Verify"),
      ),
    );
  }
}
