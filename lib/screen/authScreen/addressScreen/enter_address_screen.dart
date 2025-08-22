import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../widget/buttons/button.dart';
import '../../landingScreen/landing_screen.dart';

class EnterAddressScreen extends StatefulWidget {
  const EnterAddressScreen({super.key});

  @override
  State<EnterAddressScreen> createState() => _EnterAddressScreenState();
}

class _EnterAddressScreenState extends State<EnterAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: HelperAppBar.appbarHelper(title: "Enter Address"),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                  text: "Enter the address",
                  fontWeight: FontWeight.w500,
                  textSize: 16),
              sizedTextfield,
              MyCustomTextField.textField(
                  hintText: "Enter Address",
                  lableText: "Address",
                  controller: TextEditingController())
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: AppButton.primaryButton(
              onButtonPressed: () {
                Get.to(() => const LandingScreen());
              },
              title: "Next"),
        ));
  }
}
