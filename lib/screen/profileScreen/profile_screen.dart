import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/auth/auth_controller.dart';
import 'package:maidxpress/controller/user/user_controller.dart';

import 'package:maidxpress/screen/paymentOptionScreen/payment_option_screen.dart';
import 'package:maidxpress/screen/profileScreen/bookingHistoryScreen/booking_history_screen.dart';
import 'package:maidxpress/screen/addressScreen/address_selection_screen.dart';

import 'package:maidxpress/utils/appcolors/app_colors.dart';

import 'package:maidxpress/widget/appbar/appbar.dart';

import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../utils/helper/helper_sncksbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = Get.find<UserController>();
  final AuthController _authController = Get.find<AuthController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await _userController.getUserProfile();
    } catch (e) {
      HelperSnackBar.error('Failed to load profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getInitials(String? name) {
    if (name != null && name.isNotEmpty) {
      final names = name.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return names[0][0].toUpperCase();
      }
    }
    return 'U'; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Profile", hideBack: true),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Obx(() {
                  final user = _userController.user;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primary,
                            child: TextWidget(
                              text: _getInitials(user?.name),
                              textSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: user?.name ?? 'Guest User',
                                  textSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextWidget(
                                        text:
                                            user?.email ?? 'No email provided',
                                        textSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.toNamed('/edit-profile'),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
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
                              title: "Personal Information",
                            ),
                            _buildTile(
                              icon: Icons.history,
                              onTap: () =>
                                  Get.to(() => const BookingHistoryScreen()),
                              title: "Booking History",
                            ),
                            _buildTile(
                              icon: Icons.notifications_none,
                              onTap: () {},
                              title: "Notification Settings",
                            ),
                            _buildTile(
                              icon: Icons.location_on_outlined,
                              onTap: () => Get.to(() => AddressSelectionScreen()),
                              title: "Manage Addresses",
                            ),
                            _buildTile(
                              icon: Icons.privacy_tip_outlined,
                              onTap: () {},
                              title: "Privacy Settings",
                            ),
                            _buildTile(
                              icon: Icons.payment,
                              onTap: () =>
                                  Get.to(() => const PaymentOptionsScreen()),
                              title: "Payment Methods",
                            ),
                            _buildTile(
                              icon: Icons.help_outline,
                              onTap: () {},
                              title: "Help And Support",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        child: Center(
                          child: OutlinedButton(
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text(
                                      'Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        _authController.logoutUser();
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
                                horizontal: 32,
                                vertical: 12,
                              ),
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
                    ],
                  );
                }),
              ),
            ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
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
