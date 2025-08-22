import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/dropdownWidget/drop_down_widget.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../widget/buttons/button.dart';
import '../pickupAndTimeScreen/pickup_and_time_Screen.dart';

class SelectAreaScreen extends StatefulWidget {
  const SelectAreaScreen({super.key});

  @override
  State<SelectAreaScreen> createState() => _SelectAreaScreenState();
}

class _SelectAreaScreenState extends State<SelectAreaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Clean Xpress"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                text: "Enter the number of items to be cleaned.",
                textSize: 12,
                fontWeight: FontWeight.w500,
              ),
              sizedTextfield,
              DropDownWidget(
                  hintText: "Select Room",
                  value: "1 RK",
                  statusList: const ["1 RK", "1 BHK", "2 BHK", "3 BHK"],
                  lable:
                      "Brooming&Mopping : Comprehensive floor cleaning and sanitization (optional)",
                  onChanged: (v) {}),
              sizedTextfield,
              DropDownWidget(
                  hintText: "Select Person",
                  value: "1 Person",
                  statusList: const [
                    "1 Person",
                    "2 Person",
                    "3 Person",
                    "4 Person",
                    "5 Perswon"
                  ],
                  lable: "Dish Washing (optional)",
                  onChanged: (v) {}),
              sizedTextfield,
              DropDownWidget(
                  hintText: "Select Bathroom",
                  value: "1 Bathroom",
                  statusList: const [
                    "1 Bathroom",
                    "2 Bathroom",
                    "3 Bathroom",
                    "4 Bathroom",
                    "5 Bathroom"
                  ],
                  lable: "Bathroom Cleaning (optional)",
                  onChanged: (v) {}),
              sizedTextfield,
              DropDownWidget(
                  hintText: "Select Room",
                  value: "1 RK",
                  statusList: const ["1 RK", "1 BHK", "2 BHK", "3 BHK"],
                  lable: "Dusting (optional)",
                  onChanged: (v) {}),
              sizedTextfield,
              DropDownWidget(
                  hintText: "Select Service",
                  value: "Holding",
                  statusList: const ["Holding", "Folding", "Holding & Folding"],
                  lable: "Clothes organization: hanging and folding (optional)",
                  onChanged: (v) {}),
              sizedTextfield,
             
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: AppButton.primaryButton(
            onButtonPressed: () {
              Get.to(() => const PickupAndTimeScreen());
            },
            title: "Book Now"),
      ),
    );
  }
}
