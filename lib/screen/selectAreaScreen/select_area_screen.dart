import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/dropdownWidget/drop_down_widget.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';
import '../../models/service_model.dart';

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
    for (var subService in widget.service.subServices) {
      if (subService.options.isNotEmpty) {
        selectedOptions[subService.key] = '';
        selectedLabels[subService.key] = 'None';
      }
    }
  }

  double calculateTotalPrice() {
    double total = 0.0;
    for (var subService in widget.service.subServices) {
      final selectedLabel = selectedLabels[subService.key];
      if (selectedLabel != null && selectedLabel != 'None') {
        final selectedOption = subService.options.firstWhere(
          (opt) => opt.label == selectedLabel,
          orElse: () => subService.options.first,
        );
        total += selectedOption.price;
      }
    }
    return total;
  }

  List<Widget> getSelectedItems() {
    List<Widget> items = [];
    for (var subService in widget.service.subServices) {
      final selectedLabel = selectedLabels[subService.key];
      if (selectedLabel != null && selectedLabel != 'None') {
        final selectedOption = subService.options.firstWhere(
          (opt) => opt.label == selectedLabel,
          orElse: () => subService.options.first,
        );

        items.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service name
              Text(
                subService.name.split(':').first.trim(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Row: Selected option (left) + Price (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary, // blue
                    ),
                  ),
                  Text(
                    "Rs ${selectedOption.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(
                color: Colors.grey,
                thickness: 0.5,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice();
    final selectedItems = getSelectedItems();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(
        title: widget.service.name.isNotEmpty
            ? widget.service.name
            : "CleanXpress",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: "Enter The Number Of Items To Be Cleaned.",
              textSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
            const SizedBox(height: 5),

            // Dropdowns for sub-services
            ...widget.service.subServices.map((subService) {
              final uniqueLabels = [
                'None',
                ...subService.options.map((opt) => opt.label).toSet().toList()
              ];
              if (uniqueLabels.length <= 1) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: subService.name.contains(':')
                              ? subService.name.split(':').first.trim()
                              : subService.name.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: subService.name.contains('Optional')
                              ? ' (Optional)'
                              : '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),

            // Order Summary
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 16),
              const Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 25),
              ...selectedItems,

              // Total row
            ],

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

      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: selectedItems.isEmpty
                ? null
                : () {
                    final Map<String, Map<String, dynamic>>
                        selectedOptionsWithPrice = {};
                    for (var subService in widget.service.subServices) {
                      final selectedLabel = selectedLabels[subService.key];
                      if (selectedLabel != null && selectedLabel != 'None') {
                        final selectedOption = subService.options.firstWhere(
                          (opt) => opt.label == selectedLabel,
                          orElse: () => subService.options.first,
                        );
                        selectedOptionsWithPrice[subService.key] = {
                          'value': selectedOption.value,
                          'price': selectedOption.price,
                          'label': selectedOption.label,
                        };
                      }
                    }
                    print(
                        'Passing to PickupAndTimeScreen: $selectedOptionsWithPrice');
                    Get.to(() => PickupAndTimeScreen(
                          service: widget.service,
                          selectedOptions: selectedOptionsWithPrice,
                        ));
                  },
            child: Text(
              selectedItems.isEmpty
                  ? "Select Items"
                  : "Continue - ₹${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
