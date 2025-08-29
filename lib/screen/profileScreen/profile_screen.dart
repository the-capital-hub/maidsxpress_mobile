import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/auth/auth_controller.dart';
import 'package:maidxpress/screen/mapLocationScreen/map_location_screen.dart';
import 'package:maidxpress/screen/paymentOptionScreen/payment_Option_Screen.dart';
import 'package:maidxpress/screen/profileScreen/bookingHistoryScreen/booking_history_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';

import '../../widget/textwidget/text_widget.dart'; // Update path accordingly

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Profile", hideBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                          'https://media.istockphoto.com/id/1437816897/photo/business-woman-manager-or-human-resources-portrait-for-career-success-company-we-are-hiring.jpg?s=612x612&w=0&k=20&c=tyLvtzutRh22j9GqSGI33Z4HpIwv9vL_MZw_xOE19NQ='), // Replace with actual image
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: "Karthik",
                            textSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: TextWidget(
                                  text:
                                      "Electronic City Phase 1, Doddathogur Cross ..",
                                  textSize: 12,
                                ),
                              ),
                              Icon(
                                Icons.link,
                                size: 14,
                                color: Colors.grey,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SlideInUp(
                  child: Column(
                    children: [
                      _buildTile(
                          icon: Icons.person_outline,
                          onTap: () {},
                          title: "Personal Information"),
                      _buildTile(
                          icon: Icons.history,
                          onTap: () {
                            Get.to(() => const BookingHistoryScreen());
                          },
                          title: "Booking History"),
                      _buildTile(
                          icon: Icons.notifications_none,
                          onTap: () {},
                          title: "Notification Settings"),
                      _buildTile(
                          icon: Icons.location_on_outlined,
                          onTap: () {},
                          title: "Location Settings"),
                      _buildTile(
                          icon: Icons.privacy_tip_outlined,
                          onTap: () {},
                          title: "Privacy Settings"),
                      _buildTile(
                          icon: Icons.payment,
                          onTap: () {
                            Get.to(() => const PaymentOptionsScreen());
                          },
                          title: "Payment Methods"),
                      _buildTile(
                          icon: Icons.help_outline,
                          onTap: () {
                            Get.to(() => const MapLocationScreen());
                          },
                          title: "Help And Support"),
                    ],
                  ),
                ),
                sizedTextfield,
                FadeInUp(
                  child: Center(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  AuthController.to.logoutUser();
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.redColor,
                        side: const BorderSide(color: AppColors.redColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const TextWidget(
                        text: "Logout",
                        textSize: 12,
                        color: AppColors.redColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
      {required IconData icon,
      required String title,
      required Function() onTap}) {
    return Card(
      elevation: 2,
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: TextWidget(text: title, textSize: 14),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}
