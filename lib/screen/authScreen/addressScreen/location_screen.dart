import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/landingScreen/landing_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import 'enter_address_screen.dart';
import 'location_not_find_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Image.asset(PngAssetPath.locationImg, height: 90)),
              const SizedBox(height: 18),
              const TextWidget(
                text: "Where is your location ?",
                textSize: 20,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 18),
              AppButton.primaryButton(
                  onButtonPressed: () {
                    Get.to(() => const LocationNotFindScreen());
                  },
                  title: "Enable Device Location"),
              const SizedBox(height: 18),
              InkWell(
                onTap: () {
                  Get.to(() => const EnterAddressScreen());
                },
                child: const TextWidget(
                  text: "Enter Your Location Manually",
                  textSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Get.to(() => const LandingScreen());
                },
                child: const TextWidget(
                  text: "Skip",
                  textSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
