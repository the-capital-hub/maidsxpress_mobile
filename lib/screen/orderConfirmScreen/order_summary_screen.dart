import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';

import '../../utils/appcolors/app_colors.dart';
import '../../widget/textwidget/text_widget.dart';
import 'order_confirm_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Order Summary"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  width: 100,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              "https://hottouchkitchen.com/wp-content/uploads/2024/01/side-view-female-chef-kitchen-slicing-vegetables-compressed-scaled.jpg"))),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.primary.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: const TextWidget(
                            text: "Home Cleaning",
                            textSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const TextWidget(
                          text: " 4.4 (120 Users)",
                          textSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const TextWidget(
                        text: "Home Cleaning",
                        textSize: 15,
                        fontWeight: FontWeight.w600),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppColors.primary, size: 16),
                        TextWidget(text: "BTM Layout", textSize: 12),
                        SizedBox(width: 8),
                        Icon(Icons.alarm_rounded,
                            color: AppColors.primary, size: 16),
                        TextWidget(text: "3h 40 Mins", textSize: 12),
                      ],
                    )
                  ],
                ),
              ],
            ),
            sizedTextfield,
            Divider(height: 25, color: AppColors.black12),
            const TextWidget(
              text: "Order Summary",
              textSize: 16,
              fontWeight: FontWeight.w500,
            ),
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 20),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(
                  height: 24, color: AppColors.black12, thickness: 0.5),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: "Brooming & Mopping",
                      textSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: "1 RK",
                          textSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        TextWidget(
                          text: "Rs 1,500.00 (dusting +200)",
                          textSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton.outlineButton(
                  onButtonPressed: () {
                    Get.back();
                    Get.back();
                    Get.back();
                  },
                  title: "Edit"),
              sizedTextfield,
              AppButton.primaryButton(
                  onButtonPressed: () {
                    Get.to(() => const OrderConfirmScreen());
                  },
                  title: "Proceed to Pay ₹ 365"),
            ],
          )),
    );
  }
}
