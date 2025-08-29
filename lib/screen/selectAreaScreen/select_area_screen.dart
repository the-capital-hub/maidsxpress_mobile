import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/dropdownWidget/drop_down_widget.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';
import '../../controller/service/service_controller.dart';
import '../../models/service_model.dart';
import '../../widget/buttons/button.dart';
import '../pickupAndTimeScreen/pickup_and_time_Screen.dart';

class SelectAreaScreen extends StatefulWidget {
  final Service service; // Receive selected service

  const SelectAreaScreen({super.key, required this.service});

  @override
  State<SelectAreaScreen> createState() => _SelectAreaScreenState();
}

class _SelectAreaScreenState extends State<SelectAreaScreen> {
  // Map to store selected options for each subService (key: subService.key, value: option.value)
  final Map<String, String> selectedOptions = {};
  // Map to store selected labels for dropdowns (key: subService.key, value: option.label)
  final Map<String, String> selectedLabels = {};

  @override
  void initState() {
    super.initState();
    // Initialize selected options and labels with the first option for each subService
    for (var subService in widget.service.subServices) {
      if (subService.options.isNotEmpty) {
        selectedOptions[subService.key] = subService.options.first.value;
        selectedLabels[subService.key] = subService.options.first.label;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ServicesController controller = Get.find<ServicesController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(
          title: widget.service.name.isNotEmpty
              ? widget.service.name
              : "Clean Xpress"),
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
              const SizedBox(height: 12),
              // Dynamically generate dropdowns for each subService
              ...widget.service.subServices.map((subService) {
                // Ensure unique labels to avoid duplicates
                final uniqueLabels = subService.options
                    .map((option) => option.label)
                    .toSet()
                    .toList();
                if (uniqueLabels.isEmpty) {
                  return const SizedBox.shrink(); // Skip if no options
                }
                return Column(
                  children: [
                    DropDownWidget(
                      hintText: "Select ${subService.name.split(':').first}",
                      value:
                          selectedLabels[subService.key] ?? uniqueLabels.first,
                      statusList: uniqueLabels,
                      label: subService.name,
                      onChanged: (value) {
                        setState(() {
                          // Find the selected option based on label
                          final selectedOption = subService.options.firstWhere(
                            (option) => option.label == value,
                            orElse: () => subService.options.first,
                          );
                          selectedOptions[subService.key] =
                              selectedOption.value;
                          selectedLabels[subService.key] = selectedOption.label;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
              // Fallback message if no subServices
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: AppButton.primaryButton(
          onButtonPressed: () {
            // Pass selected service and options to PickupAndTimeScreen
            Get.to(() => PickupAndTimeScreen(
                // service: widget.service,
                // selectedOptions: selectedOptions,
                ));
          },
          title: "Book Now",
        ),
      ),
    );
  }
}
