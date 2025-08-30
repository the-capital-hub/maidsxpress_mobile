import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:maidxpress/screen/addressScreen/address_selection_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import '../../models/service_model.dart';

import '../../widget/buttons/button.dart';
import '../../widget/textwidget/text_widget.dart';

class PickupAndTimeScreen extends StatefulWidget {
  final dynamic service;
  final Map<String, String> selectedOptions;

  const PickupAndTimeScreen({
    super.key,
    required this.service,
    required this.selectedOptions,
  });

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

  // Calculate total price based on selected options
  double _calculateTotalPrice() {
    try {
      double total = 0.0;

      // Debug print to check service structure
      print('Service type: ${widget.service.runtimeType}');

      // If service is already a Service object
      if (widget.service is Service) {
        final service = widget.service as Service;
        for (final subService in service.subServices) {
          final selectedValue = widget.selectedOptions[subService.key];
          if (selectedValue != null && selectedValue.isNotEmpty) {
            try {
              // Find the selected option
              final option = subService.options.firstWhere(
                (opt) => opt.value == selectedValue,
                orElse: () => ServiceOption(
                  label: 'Default',
                  value: selectedValue,
                  price: 0.0,
                ),
              );
              total += option.price;
              print('Added ${option.price} for ${subService.name}');
            } catch (e) {
              print('Error processing option $selectedValue: $e');
            }
          }
        }
      }
      // If service is a Map (from JSON)
      else if (widget.service is Map<String, dynamic>) {
        final service = widget.service;
        final subServices =
            List<Map<String, dynamic>>.from(service['subServices'] ?? []);

        for (final entry in widget.selectedOptions.entries) {
          if (entry.value.isEmpty) continue;

          // Find the sub-service
          final subService = subServices.firstWhere(
            (s) => s['key'] == entry.key,
            orElse: () => <String, dynamic>{},
          );

          if (subService.isNotEmpty) {
            final options =
                List<Map<String, dynamic>>.from(subService['options'] ?? []);
            if (options.isNotEmpty) {
              final selectedOption = options.firstWhere(
                (o) => o['value'] == entry.value,
                orElse: () => <String, dynamic>{'price': 0.0},
              );
              final price = (selectedOption['price'] ?? 0.0).toDouble();
              total += price;
              print('Added $price for ${entry.key}: ${entry.value}');
            }
          }
        }
      }

      return total > 0 ? total : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

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
                  color: Colors.black54.withOpacity(0.5),
                  colorBlendMode: BlendMode.darken,
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
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service name
                    Text(
                      widget.service.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Selected options summary
                    if (widget.selectedOptions.isNotEmpty) ...[
                      Text(
                        widget.service.subServices
                            .where((subService) => widget.selectedOptions
                                .containsKey(subService.key))
                            .map((subService) {
                          ServiceOption option;
                          try {
                            option = subService.options.firstWhere(
                              (opt) =>
                                  opt.value ==
                                  widget.selectedOptions[subService.key],
                            );
                          } catch (e) {
                            option = subService.options.isNotEmpty
                                ? subService.options.first
                                : ServiceOption(
                                    label: 'N/A',
                                    value: 'na',
                                    price: 0.0,
                                  );
                          }
                          return '${subService.name.split(':').first.trim()}: ${option.label}';
                        }).join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Total price
                    Text(
                      'Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Total Amount',
                    textSize: 12,
                    color: AppColors.black54,
                  ),
                  const SizedBox(height: 2),
                  TextWidget(
                    text: '₹${_calculateTotalPrice().toStringAsFixed(2)}',
                    textSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: AppButton.primaryButton(
                onButtonPressed: () {
                  // Get the selected date and time
                  final selectedDate = fullDates.isNotEmpty
                      ? fullDates[selectedDateIndex]
                      : DateTime.now();
                  final selectedTime = times[selectedTimeIndex];
                  final totalPrice = _calculateTotalPrice();

                  // Print debug info before navigation
                  print('Passing to address screen:');
                  print('Selected Date: $selectedDate');
                  print('Selected Time: $selectedTime');
                  print('Total Price: $totalPrice');
                  print('Selected Options: ${widget.selectedOptions}');

                  // Navigate to AddressSelectionScreen with all required parameters
                  Get.to(
                    () => const AddressSelectionScreen(),
                    arguments: {
                      'service': widget.service,
                      'selectedOptions': widget.selectedOptions,
                      'selectedDate': selectedDate,
                      'selectedTime': selectedTime,
                      'totalPrice': totalPrice,
                    },
                  );
                },
                title: 'Continue',
                height: 48,
                borderRadius: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
