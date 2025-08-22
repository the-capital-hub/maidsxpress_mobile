import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/authScreen/otpScreen/otp_screen..dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                    text: "Enter your mobile number to get OTP",
                    textSize: 16,
                    fontWeight: FontWeight.w500),
                const SizedBox(height: 12),
                FadeIn(
                  child: MyCustomTextField.textField(
                      hintText: "Enter mobile number",
                      lableText: "Mobile number",
                      textInputType: TextInputType.phone,
                      prefixIcon: const TextWidget(
                          text: "  + 91   ",
                          fontWeight: FontWeight.w500,
                          textSize: 15),
                      controller: TextEditingController()),
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
          child: AppButton.primaryButton(
              onButtonPressed: () {
                Get.to(() => const OtpScreen());
              },
              title: "Get OTP"),
        ),
      ),
    );
  }
}
