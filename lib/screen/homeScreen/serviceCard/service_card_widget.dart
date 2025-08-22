import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/serviceDetailScreen/service_detail_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import '../../../widget/textwidget/text_widget.dart';

class ServiceCardWidget extends StatefulWidget {
  const ServiceCardWidget({super.key});

  @override
  State<ServiceCardWidget> createState() => _ServiceCardWidgetState();
}

class _ServiceCardWidgetState extends State<ServiceCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  'https://hottouchkitchen.com/wp-content/uploads/2024/01/side-view-female-chef-kitchen-slicing-vegetables-compressed-scaled.jpg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),

          // Bottom section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(
                  text: "InstaXpress",
                  textSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                TextWidget(
                  textSize: 14,
                  text:
                      "MaidsXpress Provides Professional Brooming And Cleaning Services Designed .....",
                  maxLine: 2,
                  color: AppColors.black54,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextWidget(
                      text: "Starting Price ",
                      color: AppColors.grey700,
                      fontWeight: FontWeight.w500,
                      textSize: 13,
                    ),
                    const TextWidget(
                      text: "₹2,500.00 ",
                      fontWeight: FontWeight.bold,
                      textSize: 14,
                    ),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const TextWidget(
                      text: " 4.4 ",
                      fontWeight: FontWeight.w500,
                      textSize: 14,
                    ),
                    const TextWidget(
                      text: "(120 Users)",
                      textSize: 14,
                      color: AppColors.black54,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton.primaryButton(
                    onButtonPressed: () {
                      Get.to(() => const ServiceDetailScreen());
                    },
                    width: 100,
                    height: 35,
                    fontSize: 13,
                    title: "Book Now")
              ],
            ),
          )
        ],
      ),
    );
  }
}
