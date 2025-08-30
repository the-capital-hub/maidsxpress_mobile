import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';

import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/dropdownWidget/drop_down_widget.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../models/service_model.dart';
import '../../widget/buttons/button.dart';
import 'package:maidxpress/screen/pickupAndTimeScreen/pickup_and_time_screen.dart';

class SelectAreaScreen extends StatefulWidget {
  final Service service;

  const SelectAreaScreen({super.key, required this.service});

  @override
  State<SelectAreaScreen> createState() => _SelectAreaScreenState();
}

class _SelectAreaScreenState extends State<SelectAreaScreen> {
  final Map<String, String> selectedOptions = {};
  final Map<String, String> selectedLabels = {};

  @override
  void initState() {
    super.initState();
    // Initialize with "None" as default for each subService
    for (var subService in widget.service.subServices) {
      if (subService.options.isNotEmpty) {
        selectedOptions[subService.key] = ''; // No value selected by default
        selectedLabels[subService.key] = 'None'; // Default to None
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(
        title: widget.service.name.isNotEmpty
            ? widget.service.name
            : "Clean Xpress",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: "Enter the number of items to be cleaned.",
              textSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            // Dynamically generate dropdowns for each subService
            ...widget.service.subServices.map((subService) {
              // Create a list with "None" and unique option labels
              final uniqueLabels = [
                'None',
                ...subService.options.map((opt) => opt.label).toSet().toList()
              ];
              if (uniqueLabels.length <= 1) {
                return const SizedBox.shrink(); // Skip if no valid options
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: subService.name.split(':').first.trim(),
                    textSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  DropDownWidget(
                    hintText: 'Select ${subService.name.split(':').first}',
                    value: selectedLabels[subService.key] ?? 'None',
                    statusList: uniqueLabels,
                    label: subService.name,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedLabels[subService.key] = newValue;
                          if (newValue != 'None') {
                            final selectedOption =
                                subService.options.firstWhere(
                              (opt) => opt.label == newValue,
                              orElse: () => subService.options.first,
                            );
                            selectedOptions[subService.key] =
                                selectedOption.value;
                          } else {
                            selectedOptions.remove(subService.key);
                          }
                        });
                      }
                    },
                  ),
                  // Display price if an option is selected (not None)
                  if (selectedLabels[subService.key] != 'None')
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Price: ₹${subService.options.firstWhere((opt) => opt.label == selectedLabels[subService.key]).price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            if (widget.service.subServices.isEmpty)
              const TextWidget(
                text: "No services available for selection.",
                textSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AppButton.primaryButton(
          onButtonPressed: () {
            Get.to(() => PickupAndTimeScreen(
                  service: widget.service,
                  selectedOptions: selectedOptions,
                ));
          },
          title: "Book Now",
        ),
      ),
    );
  }
}
