import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../utils/constant/app_var.dart';
import '../../../widget/buttons/button.dart';
import '../../../widget/text_field/text_field.dart';
import '../selectCityScreen/select_city_screen.dart';

class MoreInfoScreen extends StatefulWidget {
  const MoreInfoScreen({super.key});

  @override
  State<MoreInfoScreen> createState() => _MoreInfoScreenState();
}

class _MoreInfoScreenState extends State<MoreInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizedTextfield,
              const TextWidget(
                  text: "Hi What is your name",
                  textSize: 16,
                  fontWeight: FontWeight.w600),
              const SizedBox(height: 10),
              MyCustomTextField.textField(
                  hintText: "Enter name",
                  lableText: "Name",
                  textInputType: TextInputType.phone,
                  controller: TextEditingController()),
              sizedTextfield,
              const TextWidget(
                  text: "Can you share your email id with us",
                  textSize: 16,
                  fontWeight: FontWeight.w600),
              const SizedBox(height: 10),
              MyCustomTextField.textField(
                  hintText: "Enter email",
                  lableText: "Email",
                  textInputType: TextInputType.phone,
                  controller: TextEditingController()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(12),
        child: AppButton.primaryButton(
            onButtonPressed: () {
              Get.to(() => const SelectCityScreen());
            },
            title: "Verify"),
      ),
    );
  }
}
