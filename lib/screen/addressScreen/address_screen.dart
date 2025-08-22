import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import '../../widget/textwidget/text_widget.dart';
import '../orderConfirmScreen/order_summary_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  int selectedAddressIndex = 0;

  final List<Map<String, dynamic>> addresses = [
    {
      "title": "Home",
      "icon": Icons.home_outlined,
      "address": "Electronic City Phase 1, Doddathogur Cross ..",
      "phone": "+91-7689098760"
    },
    {
      "title": "Office",
      "icon": Icons.work_outline,
      "address": "Electronic City Phase 1, Doddathogur Cross ..",
      "phone": "+91-7689098760"
    },
    {
      "title": "Home 2",
      "icon": Icons.home_outlined,
      "address": "Electronic City Phase 1, Doddathogur Cross ..",
      "phone": "+91-7689098760"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Location"),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = addresses[index];
                return FadeInDown(
                  delay: Duration(milliseconds: 100 * (index)),
                  child: Card(
                    color: AppColors.white,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(item["icon"],
                              size: 25, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: item["title"],
                                  textSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 16, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextWidget(
                                        text: item["address"],
                                        textSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const SizedBox(width: 2),
                                    const Icon(Icons.call,
                                        color: AppColors.black54, size: 14),
                                    const SizedBox(width: 4),
                                    TextWidget(
                                      text: "${item["phone"]}",
                                      textSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: selectedAddressIndex,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                selectedAddressIndex = val!;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                AppButton.outlineButton(
                    onButtonPressed: () {},
                    borderColor: AppColors.primary,
                    title: "+ Add New Address"),
                sizedTextfield,
                AppButton.primaryButton(
                    onButtonPressed: () {
                      Get.to(() => const OrderSummaryScreen());
                    },
                    title: "Continue")
              ],
            ),
          )
        ],
      ),
    );
  }
}
