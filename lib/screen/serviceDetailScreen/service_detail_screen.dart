import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/selectAreaScreen/select_area_screen.dart';
import 'package:maidxpress/screen/serviceDetailScreen/reviewWidget/review_widget_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';

import '../../utils/constant/asset_constant.dart';
import '../../widget/textwidget/text_widget.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Clean Xpress"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
              ),
              sizedTextfield,
              FadeInDown(
                  child: const TextWidget(
                text: "CleanXpress",
                textSize: 20,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 4),
              FadeInDown(
                  child: const Row(
                children: [
                  TextWidget(
                    text: "Jenny Wilson",
                    textSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  TextWidget(
                    text: " 4.4 (120 Users)",
                    textSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              )),
              const SizedBox(height: 8),
              FadeInDown(
                child: Row(
                  children: [
                    Image.asset(
                      PngAssetPath.locationAppbarImg,
                      height: 20,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: TextWidget(
                        text: "BTM Layout Electronic City Phase 1",
                        maxLine: 1,
                        textSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.primary.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: const TextWidget(
                        text: "Cleaning",
                        textSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                  child: const TextWidget(
                text: "₹250.00",
                textSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              )),
              const SizedBox(height: 16),
              FadeIn(
                  child: const TextWidget(
                text: "CleanXpress Includes",
                textSize: 17,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 8),
              FadeIn(
                  child: const TextWidget(
                text:
                    "MaidsXpress Provides Professional Brooming And Cleaning Services Designed To Keep Your Home Spotless. Our Services Include:",
                textSize: 13,
                maxLine: 3,
                color: AppColors.black,
              )),
              const SizedBox(height: 10),
              FadeIn(
                  child: buildBullet(
                icon: Icons.check_circle,
                iconColor: AppColors.green700,
                title: "Sweeping & Brooming",
                desc:
                    "Removing Dust, Dirt, And Debris From Floors To Maintain Cleanliness.",
              )),
              FadeIn(
                  child: buildBullet(
                icon: Icons.check_circle,
                iconColor: AppColors.green700,
                title: "Mopping & Floor Cleaning",
                desc: "Deep Cleaning Of Floors To Eliminate Stains And Germs.",
              )),
              FadeIn(
                  child: buildBullet(
                icon: Icons.check_circle,
                iconColor: AppColors.green700,
                title: "Dusting & Surface Wiping",
                desc:
                    "Cleaning Furniture, Shelves, And Other Surfaces For A Fresh Look.",
              )),
              FadeIn(
                  child: buildBullet(
                icon: Icons.check_circle,
                iconColor: AppColors.green700,
                title: "Bathroom & Kitchen Cleaning",
                desc: "Sanitizing Sinks, Countertops, Toilets, And Appliances.",
              )),
              const SizedBox(height: 16),
              FadeIn(
                  child: const TextWidget(
                text: "CleanXpress Excludes",
                textSize: 17,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 8),
              FadeIn(
                  child: const TextWidget(
                text:
                    "MaidsXpress Provides A Range Of Cleaning Services Designed To Keep Your Environment Spotless. We Specialize In:",
                textSize: 13,
                maxLine: 3,
                color: AppColors.black87,
              )),
              const SizedBox(height: 10),
              FadeIn(
                  child: buildBullet(
                icon: Icons.cancel,
                iconColor: AppColors.redColor,
                title: "Vacuuming & Carpet Care",
                desc: "Keeping Carpets Free From Dust And Allergens.",
              )),
              FadeInUp(
                  child: buildBullet(
                icon: Icons.cancel,
                iconColor: AppColors.redColor,
                title: "Window Washing",
                desc: "Ensuring Your Windows Shine Brightly.",
              )),
              FadeInUp(
                  child: buildBullet(
                icon: Icons.cancel,
                iconColor: AppColors.redColor,
                title: "Upholstery Cleaning",
                desc: "Revitalizing Sofas And Chairs To Look Brand New.",
              )),
              FadeInUp(
                  child: buildBullet(
                icon: Icons.cancel,
                iconColor: AppColors.redColor,
                title: "Post-Construction Cleanup",
                desc: "Clearing Away Debris And Dust After Renovations.",
              )),
              const SizedBox(height: 16),
              FadeInLeft(
                  child: const TextWidget(
                text: "Summary",
                textSize: 16,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 10),
              SlideInRight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TextWidget(
                              text: "4.2",
                              textSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8.0, left: 2),
                              child: TextWidget(
                                text: "/5",
                                textSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star_border,
                                color: Colors.amber, size: 20),
                          ],
                        ),
                        SizedBox(height: 6),
                        TextWidget(
                          text: "[2,500 Reviews]",
                          textSize: 12,
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          buildRatingRow(stars: 5, value: 0.92, count: 2300),
                          buildRatingRow(stars: 4, value: 0.08, count: 200),
                          buildRatingRow(stars: 3, value: 0.08, count: 200),
                          buildRatingRow(stars: 2, value: 0.08, count: 200),
                          buildRatingRow(stars: 1, value: 0.08, count: 200),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                  child: const TextWidget(
                text: "Top Review",
                textSize: 16,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 10),
              FadeInUp(
                child: ListView.separated(
                  itemCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 12);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return const ReviewCard(
                      name: "Amit Sharma",
                      image:
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzFTXPMm6QE6GAEk_ZjePatR0-Y222qRviNw&s",
                      rating: 4,
                      date: "Jul 12, 2025",
                      comment:
                          "Great service! Very professional and fast. Would definitely recommend.",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: AppButton.primaryButton(
            onButtonPressed: () {
              Get.to(() => const SelectAreaScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500));
            },
            title: "Book Now"),
      ),
    );
  }

  Widget buildRatingRow(
      {required int stars, required double value, required int count}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          TextWidget(
            text: stars.toString(),
            textSize: 14,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade300,
              color: Colors.amber,
              minHeight: 8,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          TextWidget(
            text: count.toString(),
            textSize: 13,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  Widget buildBullet({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title – ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
