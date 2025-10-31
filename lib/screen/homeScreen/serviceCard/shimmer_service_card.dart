import 'package:flutter/material.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/widgets/shimmer_loader.dart';

class ShimmerServiceCard extends StatelessWidget {
  const ShimmerServiceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Slightly larger radius for modern look
      ),
      elevation: 3, // Subtle elevation for depth
      color: AppColors.white, // Use app's white color
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8), // Consistent margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          const ShimmerLoader(
            width: double.infinity,
            height: 160, // Slightly reduced height for better proportion
            borderRadius: 12, // Match card's border radius
            // Light highlight
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(
                16.0), // Increased padding for better spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const ShimmerLoader(
                  width: 180, // Slightly smaller for realism
                  height: 18, // Adjusted for typical title size
                  borderRadius: 6, // Softer corners
                ),
                const SizedBox(height: 10),

                // Description (two lines)
                const ShimmerLoader(
                  width: double.infinity,
                  height: 14, // Smaller height for description text
                  borderRadius: 6,
                ),
                const SizedBox(height: 8),
                ShimmerLoader(
                  width: MediaQuery.of(context).size.width *
                      0.6, // Partial width for realism
                  height: 14,
                  borderRadius: 6,
                ),
                const SizedBox(height: 16),

                // Price and button row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLoader(
                      width: 100, // Adjusted for price text
                      height: 20,
                      borderRadius: 6,
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.white,
                    ),
                    ShimmerLoader(
                      width: 120, // Slightly larger for button
                      height: 40, // Taller button for modern look
                      borderRadius: 20, // Rounded button style
                      baseColor: AppColors.primary,
                      // Primary color for button
                      highlightColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
