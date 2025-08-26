import 'package:flutter/material.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../utils/constant/asset_constant.dart';

class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  String selectedPayment = "Google Pay";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const TextWidget(
          text: "Payment Options",
          textSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Pay by UPI
                const TextWidget(
                  text: "Pay by any UPI App",
                  textSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),

                _buildUPIOption("Google Pay", PngAssetPath.gpayImg),
                _buildUPIOption("PhonePe", PngAssetPath.phonepeImg),
                _buildUPIOption("Paytm", PngAssetPath.paytmImg),

                const SizedBox(height: 8),
                _buildAddNewOption(
                  "Add New UPI ID",
                  "You need to have a registered UPI ID",
                  () {},
                ),

                const SizedBox(height: 20),

                // Credit & Debit Cards
                const TextWidget(
                  text: "Credit & Debit Cards",
                  textSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                _buildAddNewOption(
                  "Add New Card",
                  "Save and Pay via Cards",
                  () {},
                ),

                const SizedBox(height: 20),

                // Offers & Benefits
                const TextWidget(
                  text: "Offers & Benefits",
                  textSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                _buildOffersCard(),

                const SizedBox(height: 20),

                // Cancellation Policy
                const TextWidget(
                  text: "CANCELLATION POLICY",
                  textSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                const SizedBox(height: 6),
                const TextWidget(
                  maxLine: 2,
                  text:
                      "By avoiding cancellations after placing your order. A 100% cancellation fee will be applied.",
                  textSize: 12,
                  color: Colors.black87,
                ),
              ],
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: "₹365.00",
                      textSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: TextWidget(
                        text: "View Detailed Bill",
                        textSize: 13,
                        color: AppColors.primary,
                      ),
                    )
                  ],
                ),
                SizedBox(
                    width: 160,
                    child: AppButton.primaryButton(
                      onButtonPressed: () {
                        // proceed action
                      },
                      title: "Proceed to Pay",
                      width: 160,
                      height: 48,
                      fontSize: 15,
                      textColor: Colors.white,
                      bgColor: AppColors.primary,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUPIOption(String title, String iconPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 30,
          height: 30,
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        title: TextWidget(
          text: title,
          textSize: 15,
          fontWeight: FontWeight.w500,
        ),
        trailing: Radio<String>(
          value: title,
          groupValue: selectedPayment,
          activeColor: AppColors.primary,
          onChanged: (val) {
            setState(() {
              selectedPayment = val!;
            });
          },
        ),
        onTap: () {
          setState(() {
            selectedPayment = title;
          });
        },
      ),
    );
  }

  Widget _buildAddNewOption(String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Icon(
            Icons.add,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: TextWidget(
          text: title,
          textSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        subtitle: TextWidget(
          text: subtitle,
          textSize: 12,
          color: Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOffersCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Icon(
            Icons.local_offer,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: const TextWidget(
          text: "Shop Coupons Available",
          textSize: 15,
          fontWeight: FontWeight.w500,
        ),
        subtitle: const TextWidget(
          text: "View all coupons",
          textSize: 12,
          color: Colors.black54,
        ),
        onTap: () {},
      ),
    );
  }
}
