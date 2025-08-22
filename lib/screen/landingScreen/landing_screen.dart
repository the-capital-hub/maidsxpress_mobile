import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    SizedBox(),
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
          bottomNavigationBar: Container(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                icons.length,
                (index) => InkWell(
                  onTap: () {
                    homeController.selectedIndex.value = index;
                  },
                  child: SizedBox(
                    width: 50,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          homeController.selectedIndex == index
                              ? icons[index]
                              : iconsUnselected[index],
                          size: 24,
                          color: homeController.selectedIndex == index
                              ? AppColors.primary
                              : AppColors.blackCard.withOpacity(0.7),
                        ),
                        const SizedBox(height: 2),
                        TextWidget(
                          text: title[index],
                          textSize: 10,
                          color: homeController.selectedIndex == index
                              ? AppColors.primary
                              : AppColors.blackCard.withOpacity(0.7),
                          fontWeight: homeController.selectedIndex == index
                              ? FontWeight.w500
                              : FontWeight.normal,
                          maxLine: 2,
                          align: TextAlign.center,
                        ),
                        // const SizedBox(height: 6),
                        // if (homeController.selectedIndex == index)
                        //   Container(
                        //     width: 100,
                        //     height: 2,
                        //     decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(2),
                        //         color: AppColors.primary),
                        //   )
                      ],
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
