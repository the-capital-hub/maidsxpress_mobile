import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/serviceDetailScreen/service_detail_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import '../../../models/service_model.dart';
import '../../../widget/textwidget/text_widget.dart';

class ServiceCardWidget extends StatelessWidget {
  final Service service;

  const ServiceCardWidget({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    if (service.id.isEmpty) {
      return const SizedBox.shrink(); // Return empty widget if no data
    }
    // Calculate minimum price across all subServices
    final startingPrice = _calculateStartingPrice(service.subServices);
    // Get first non-empty description from include
    final description = service.include
        .firstWhere(
          (item) => item.description.isNotEmpty,
          orElse: () => ServiceDetail(description: "No description available"),
        )
        .description;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          Get.to(() => ServiceDetailScreen(service: service));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  height: 180,
                  width: double.maxFinite,
                  child: FittedBox(
                    fit: BoxFit
                        .fitHeight, // Changed to fitHeight to preserve bottom
                    clipBehavior: Clip.hardEdge,
                    alignment: Alignment.center, // Center to balance cropping
                    child: Image.network(
                      service.image.isNotEmpty
                          ? service.image
                          : 'https://via.placeholder.com/300',
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () {
                    // TODO: Add favorite functionality
                    Get.snackbar('Favorite', 'Feature coming soon!');
                  },
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: service.name.isNotEmpty
                      ? service.name
                      : "Unnamed Service",
                  textSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                TextWidget(
                  textSize: 14,
                  text: description,
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
                    TextWidget(
                      text: "₹${startingPrice.toStringAsFixed(2)}",
                      fontWeight: FontWeight.bold,
                      textSize: 14,
                    ),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const TextWidget(
                      text: " 4.4 ", // Static, update if rating is in model
                      fontWeight: FontWeight.w500,
                      textSize: 14,
                    ),
                    const TextWidget(
                      text:
                          "(120 Users)", // Static, update if user count is in model
                      textSize: 14,
                      color: AppColors.black54,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton.primaryButton(
                  onButtonPressed: () {
                    Get.to(() => ServiceDetailScreen(service: service));
                  },
                  width: 100,
                  height: 35,
                  fontSize: 13,
                  title: "Book Now",
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  // Helper method to calculate minimum price
  double _calculateStartingPrice(List<SubService> subServices) {
    if (subServices.isEmpty) return 2500.00; // Default price
    double minPrice = double.infinity;
    for (var subService in subServices) {
      for (var option in subService.options) {
        if (option.price < minPrice) {
          minPrice = option.price;
        }
      }
    }
    return minPrice != double.infinity ? minPrice : 2500.00;
  }
}
