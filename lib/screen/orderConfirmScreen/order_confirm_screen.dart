import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/orderConfirmScreen/view_receipt_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

class OrderConfirmScreen extends StatefulWidget {
  final dynamic booking; // Or use your specific booking model type
  
  const OrderConfirmScreen({super.key, required this.booking});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            sizedTextfield,
            sizedTextfield,
            sizedTextfield,
            sizedTextfield,
            const TextWidget(
              text: "Thank You!",
              textSize: 25,
              fontWeight: FontWeight.w600,
            ),
            sizedTextfield,
            const TextWidget(
              text: "Yay ! Payment Received",
              textSize: 16,
              fontWeight: FontWeight.w500,
            ),
            sizedTextfield,
            const TextWidget(text: "We are on the away..!", textSize: 14),
            sizedTextfield,
            Image.asset(PngAssetPath.paysuccessImg),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primaryButton(
                onButtonPressed: () {
                  Get.to(() => const EReceiptScreen());
                },
                title: "View  E-Receipt"),
            sizedTextfield,
            const TextWidget(
                text: "Home",
                textSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)
          ],
        ),
      ),
    );
  }
}
