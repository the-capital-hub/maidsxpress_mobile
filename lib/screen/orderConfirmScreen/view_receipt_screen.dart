import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';

import '../../widget/textwidget/text_widget.dart';
import 'process_screen.dart';

class EReceiptScreen extends StatelessWidget {
  const EReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "E-Receipt"),
      body: SafeArea(
        child: Column(
          children: [
            Image.network(
                "https://sp-ao.shortpixel.ai/client/to_webp,q_glossy,ret_img,w_300,h_300/https://prooftag.net/wp-content/uploads/2021/07/QR-Code.png",
                height: 200),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildRowTile("Booking Date", "Nov 21, 2024 | 09 : 30 am"),
                    _buildRowTile("Workers", "Jenny Wilson"),
                    _buildRowTile(
                        "Confirmed Date & Time", "Nov 22, 2024 | 10 : 30 am"),
                    const Divider(),
                    _buildRowTile("Living Room", "Rs 185.00"),
                    _buildRowTile("Terrace", "Rs 80.00"),
                    _buildRowTile("Tax & Fees", "Rs 100.00"),
                    const Divider(),
                    _buildRowTile("Payment Methods", "Google Pay"),
                    _buildRowTile("Date", "Nov 21, 2024, 11:19 pm"),
                    _buildRowTile("Transaction ID", "HR23980HJKL",
                        trailingIcon: Icons.copy),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AppButton.primaryButton(
            onButtonPressed: () {
              Get.to(() => const ProcessScreen());
            },
            title: "Download  E-Receipt"),
      ),
    );
  }

  Widget _buildRowTile(String label, String value, {IconData? trailingIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F7F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextWidget(
              text: label,
              textSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              TextWidget(
                text: value,
                textSize: 13,
                fontWeight: FontWeight.w500,
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 16, color: Colors.grey.shade600),
            ],
          ),
        ],
      ),
    );
  }
}
