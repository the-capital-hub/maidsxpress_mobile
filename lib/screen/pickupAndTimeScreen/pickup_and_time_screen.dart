import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';

import '../../widget/buttons/button.dart';
import '../../widget/textwidget/text_widget.dart';
import '../addressScreen/address_screen.dart';

class PickupAndTimeScreen extends StatefulWidget {
  const PickupAndTimeScreen({super.key});

  @override
  State<PickupAndTimeScreen> createState() => _PickupAndTimeScreenState();
}

class _PickupAndTimeScreenState extends State<PickupAndTimeScreen> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = 1;
  int selectedGenderIndex = 1;
  final instructionController = TextEditingController();

  List<String> dates = [];
  List<int> days = [];
  List<DateTime> fullDates = [];
  final List<String> times = [
    "08:00 am",
    "09:00 am",
    "09:30 am",
    "10:30 am",
    "11:00 am",
    "12:00 pm",
    "01:30 pm",
    "04:00 pm",
    "05:00 pm",
    "05:30 pm",
    "06:00 pm",
    "07:00 pm"
  ];

  final List<String> genders = ["Male", "Female"];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      dates.add(_getDayAbbreviation(date.weekday));
      days.add(date.day);
      fullDates.add(date);
    }

    selectedDateIndex = 0; // Today is default selected
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      case DateTime.sunday:
        return "Sun";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Image and Title Section (Stack)
          Stack(
            children: [
              ClipRRect(
                child: Image.network(
                  "https://hottouchkitchen.com/wp-content/uploads/2024/01/side-view-female-chef-kitchen-slicing-vegetables-compressed-scaled.jpg",
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: AppColors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const Positioned(
                bottom: 20,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: "House Full Cleaning",
                      textSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    SizedBox(height: 4),
                    TextWidget(
                      text: "Electronic City Phase 1, Doddathogur Cross...",
                      textSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Scrollable Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: "Start Date",
                    textSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FlipInX(
                    child: SizedBox(
                      height: 70,
                      child: ListView.builder(
                        itemCount: dates.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          bool isSelected = index == selectedDateIndex;
                          return GestureDetector(
                            onTap: () => setState(() {
                              selectedDateIndex = index;
                            }),
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  TextWidget(
                                    text: dates[index],
                                    textSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.black54,
                                  ),
                                  TextWidget(
                                    text: days[index].toString(),
                                    textSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  sizedTextfield,
                  const TextWidget(
                    text: "Time",
                    textSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  sizedTextfield,
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: times.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) {
                      bool isSelected = index == selectedTimeIndex;
                      return FadeIn(
                        delay: Duration(milliseconds: 50 * index),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedTimeIndex = index;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextWidget(
                                text: times[index],
                                textSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const TextWidget(
                    text: "Select the Gender",
                    textSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  FadeInLeft(
                    child: Row(
                      children: List.generate(genders.length, (index) {
                        bool isSelected = selectedGenderIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGenderIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey200,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextWidget(
                              text: genders[index],
                              textSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextWidget(
                    text: "Cleaning Instructions",
                    textSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  MyCustomTextField.textField(
                      hintText: "Type here ...",
                      controller: instructionController)
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: AppButton.primaryButton(
            onButtonPressed: () {
              Get.to(() => const AddressSelectionScreen());
            },
            title: "Continue - ₹2,085.00"),
      ),
    );
  }
}
