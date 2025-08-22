import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../widget/buttons/button.dart';

class LocationNotFindScreen extends StatefulWidget {
  const LocationNotFindScreen({super.key});

  @override
  State<LocationNotFindScreen> createState() => _LocationNotFindScreenState();
}

class _LocationNotFindScreenState extends State<LocationNotFindScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(PngAssetPath.nolocationImg, height: 180),
                sizedTextfield,
                const TextWidget(
                    text: "Sorry, we are not in that location",
                    textSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary),
                sizedTextfield,
                const TextWidget(text: "we’re soon to their", textSize: 16)
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: AppButton.primaryButton(
              onButtonPressed: () {
                Get.back();
              },
              title: "Change Location"),
        ));
  }
}
