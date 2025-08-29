import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/service/service_controller.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';

import '../homeScreen/serviceCard/service_card_widget.dart';

class SeeAllServiceScreen extends StatefulWidget {
  const SeeAllServiceScreen({super.key});

  @override
  State<SeeAllServiceScreen> createState() => _SeeAllServiceScreenState();
}

class _SeeAllServiceScreenState extends State<SeeAllServiceScreen> {
  @override
  Widget build(BuildContext context) {
    final ServicesController controller = Get.find<ServicesController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "All Services"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.services.isEmpty) {
          return const Center(child: Text('No services available'));
        }

        return ZoomInDown(
          child: ListView.separated(
            itemCount: controller.services.length,
            shrinkWrap: true,
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 20),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              return ServiceCardWidget(service: controller.services[index]);
            },
          ),
        );
      }),
    );
  }
}
