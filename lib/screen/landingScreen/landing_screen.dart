import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/calendarScreen/calendar_screen.dart';
import 'package:maidxpress/screen/profileScreen/profile_screen.dart';

import '../../controller/homeController/home_controller.dart';
import '../../utils/appcolors/app_colors.dart';
import '../../widget/textwidget/text_widget.dart';
import '../bookingScreen/booking_Screen.dart';
import '../favouriteScreen/favourite_screen.dart';
import '../homeScreen/home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    super.key,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  HomeController homeController = Get.put(HomeController());
  @override
  void initState() {
    super.initState();
  }

  // Helper method to get responsive icon size
  double getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 20.0;
    if (screenWidth < 400) return 22.0;
    return 24.0;
  }

  // Helper method to get responsive text size
  double getTextSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 8.0;
    if (screenWidth < 400) return 9.0;
    return 10.0;
  }

  List icons = [
    Icons.home,
    Icons.assignment,
    Icons.calendar_month,
    Icons.favorite,
    Icons.person,
  ];
  List iconsUnselected = [
    Icons.home_outlined,
    Icons.assignment_outlined,
    Icons.calendar_month_outlined,
    Icons.favorite_border,
    Icons.person_outline,
  ];
  List title = ["Home", "Bookings", "Calendar", "Favourite", "Profile"];
  List screen = [
    HomeScreen(),
    BookingScreen(),
    CalendarScreen(),
    // SizedBox(),
    FavouriteServiceScreen(),
    ProfileScreen(),
    // SizedBox(),
  ];
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColors.white,
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: SafeArea(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 60,
                maxHeight: 80,
              ),
              padding: EdgeInsets.only(
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 8,
                left: MediaQuery.of(context).size.width < 360 ? 12 : 16,
                right: MediaQuery.of(context).size.width < 360 ? 12 : 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                    top: BorderSide(color: AppColors.blackBorder, width: 0.5)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1FFFFFFF),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  icons.length,
                  (index) => Expanded(
                    child: InkWell(
                      onTap: () {
                        homeController.selectedIndex.value = index;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              homeController.selectedIndex == index
                                  ? icons[index]
                                  : iconsUnselected[index],
                              size: getIconSize(context),
                              color: homeController.selectedIndex == index
                                  ? AppColors.primary
                                  : AppColors.blackCard.withOpacity(0.7),
                            ),
                            const SizedBox(height: 3),
                            Flexible(
                              child: TextWidget(
                                text: title[index],
                                textSize: getTextSize(context),
                                color: homeController.selectedIndex == index
                                    ? AppColors.primary
                                    : AppColors.blackCard.withOpacity(0.7),
                                fontWeight: homeController.selectedIndex == index
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                maxLine: 1,
                                align: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: screen[homeController.selectedIndex.value],
        ));
  }

  // int currentTab() => widget.navigationShell.currentIndex;

  // void _goBranch(int index) {
  //   widget.navigationShell.goBranch(
  //     index,
  //     initialLocation: index == widget.navigationShell.currentIndex,
  //   );
  // }
}
