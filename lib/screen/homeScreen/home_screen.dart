import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/service/service_controller.dart';
import 'package:maidxpress/models/service_model.dart';
import 'package:maidxpress/screen/homeScreen/serviceCard/service_card_widget.dart';
import 'package:maidxpress/screen/notificationScreen/notification_screen.dart';
import 'package:maidxpress/screen/seeAllServiceScreen/see_all_service_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> bannerImages = [
    PngAssetPath.bannerImg,
    PngAssetPath.bannerImg,
    PngAssetPath.bannerImg,
  ];

  // Dynamic Xpress options based on available services
  List<Map<String, dynamic>> get xpressOptions {
    final controller = Get.find<ServicesController>();

    // Start with "All" option
    final options = <Map<String, dynamic>>[
      {
        'id': 'all',
        'image': PngAssetPath.homeImg,
        'title': 'All Services',
        'tag': 'all',
      },
    ];

    if (controller.services.isEmpty) return options;

    // Add unique services based on their tags
    final addedTags = <String>{};
    for (var service in controller.services) {
      if (service.tag.isNotEmpty && !addedTags.contains(service.tag)) {
        options.add({
          'id': service.id,
          'image': _getServiceImage(service.tag),
          'title': service.name,
          'tag': service.tag,
          'service': service,
        });
        addedTags.add(service.tag);
      }
    }

    // If no services with tags found, add all services as options
    if (options.length == 1 && controller.services.isNotEmpty) {
      options.addAll(controller.services.map((service) => {
            'id': service.id,
            'image': _getServiceImage(service.name.toLowerCase()),
            'title': service.name,
            'tag': service.tag.isNotEmpty
                ? service.tag
                : service.name.toLowerCase(),
            'service': service,
          }));
    }

    return options;
  }

  // Helper to get appropriate image based on service type
  String _getServiceImage(String tag) {
    if (tag.contains('clean') || tag.contains('house'))
      return PngAssetPath.homeImg;
    if (tag.contains('cook') || tag.contains('meal'))
      return PngAssetPath.cookImg;
    if (tag.contains('care') || tag.contains('baby') || tag.contains('elder'))
      return PngAssetPath.babycareImg;
    return PngAssetPath.starImg; // default image
  }

  String selectedXpressOption = "all"; // Default to "All Services"

  String selectedPopularService = "All";
  final List<String> popularService = [
    "All",
    "Baby Care",
    "Elderly Care",
    "Cooking Services",
    "Party Clean",
  ];

  @override
  Widget build(BuildContext context) {
    final ServicesController controller = Get.find<ServicesController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        List<Service> filteredServices;
        // If no services are loaded, show empty list
        if (controller.services.isEmpty) {
          filteredServices = [];
        }
        // If "All" is selected, show all services
        else if (selectedXpressOption == "all" ||
            selectedXpressOption.isEmpty) {
          filteredServices = List<Service>.from(controller.services);
        } else {
          // Get the selected Xpress option
          final selectedOption = xpressOptions.firstWhere(
            (option) => option['id'] == selectedXpressOption,
            orElse: () => {'id': '', 'title': '', 'image': '', 'tag': ''},
          );

          // Filter services based on the tag from API response
          filteredServices = controller.services
              .where((service) =>
                  service.tag.toLowerCase() ==
                  selectedOption['tag']?.toLowerCase())
              .toList();
        }

        // For services to display, use filtered services or all if empty
        final servicesToDisplay = filteredServices.isNotEmpty
            ? filteredServices
            : controller.services;

        // Filter by popularService if not "All"
        final displayedServices = selectedPopularService == "All"
            ? servicesToDisplay
            : servicesToDisplay
                .where((service) =>
                    service.tag.toLowerCase() ==
                        selectedPopularService.toLowerCase() ||
                    service.name
                        .toLowerCase()
                        .contains(selectedPopularService.toLowerCase()))
                .toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: topAndBanner(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const TextWidget(
                      text: "Upcoming Service",
                      textSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 12),
                    SlideInRight(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.primary, width: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.primary,
                              child: CircleAvatar(
                                radius: 23,
                                backgroundColor: AppColors.white,
                                child: Icon(
                                  Icons.baby_changing_station,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: "Baby Care",
                                    textSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(height: 3),
                                  TextWidget(
                                    text: "Sun, 24 2024 | 12:30 pm",
                                    textSize: 13,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const TextWidget(
                                text: "Re-schedule",
                                color: AppColors.white,
                                textSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextWidget(
                  text: "Services",
                  textSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 75,
                child: ListView.separated(
                  itemCount: xpressOptions.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 0),
                  itemBuilder: (BuildContext context, int index) {
                    bool isSelected =
                        selectedXpressOption == xpressOptions[index]['id']!;
                    return ZoomIn(
                      duration: Duration(milliseconds: 300 + index * 100),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedXpressOption = xpressOptions[index]['id']!;
                          });
                        },
                        splashColor: AppColors.transparent,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 1),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.grey200,
                                child: Image.asset(
                                  xpressOptions[index]['image']!,
                                  height: 22,
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextWidget(
                                text: xpressOptions[index]['title']!,
                                textSize: 13,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  children: [
                    const TextWidget(
                      text: "Popular Services",
                      textSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Get.to(() => const SeeAllServiceScreen()),
                      child: TextWidget(
                        text: "See All",
                        textSize: 13,
                        color: AppColors.black.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: AppColors.black54, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 35,
                child: ListView.separated(
                  itemCount: popularService.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 0),
                  itemBuilder: (BuildContext context, int index) {
                    bool isSelected =
                        selectedPopularService == popularService[index];
                    return FadeInLeft(
                      duration: Duration(milliseconds: 300 + index * 100),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedPopularService = popularService[index];
                          });
                        },
                        splashColor: AppColors.transparent,
                        child: Container(
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: TextWidget(
                              text: popularService[index],
                              textSize: 13,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Dynamic filtered services
              controller.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : displayedServices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: TextWidget(
                            text: "No services available for this category",
                            textSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        )
                      : ListView.separated(
                          itemCount: displayedServices.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, top: 15),
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            return FadeInUp(
                              duration:
                                  Duration(milliseconds: 400 + index * 100),
                              child: ServiceCardWidget(
                                service: displayedServices[index],
                              ),
                            );
                          },
                        ),
            ],
          ),
        );
      }),
    );
  }

  Widget topAndBanner() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 12, right: 12, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(50),
            AppColors.whiteCard,
            AppColors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        PngAssetPath.locationAppbarImg,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      const TextWidget(
                        text: "BTM Layout",
                        fontWeight: FontWeight.bold,
                        textSize: 14,
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ],
                  ),
                  const TextWidget(
                    text: "Electronic City Phase 1, Doddathogur Cross ..",
                    textSize: 12,
                    color: Colors.black54,
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Get.to(() => NotificationScreen());
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black12,
                  offset: Offset(1, 1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: MyCustomTextField.textField(
              hintText: "Search for service",
              fillColor: AppColors.white,
              borderClr: AppColors.transparent,
              suffixIcon: const Icon(
                CupertinoIcons.search,
                color: AppColors.primary,
              ),
              controller: TextEditingController(),
            ),
          ),
          const SizedBox(height: 12),
          const TextWidget(
            text: "Best Offers for you..!",
            textSize: 18,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CarouselSlider.builder(
              itemCount: bannerImages.length,
              itemBuilder: (context, index, realIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    bannerImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
              options: CarouselOptions(
                height: 150,
                viewportFraction: 1.08,
                enlargeCenterPage: true,
                autoPlay: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: bannerImages.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? AppColors.primary
                        : AppColors.black12,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
