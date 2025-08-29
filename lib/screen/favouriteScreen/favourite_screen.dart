import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/service/service_controller.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';

import '../homeScreen/serviceCard/service_card_widget.dart';

class FavouriteServiceScreen extends StatefulWidget {
  const FavouriteServiceScreen({super.key});

  @override
  State<FavouriteServiceScreen> createState() => _FavouriteServiceScreenState();
}

class _FavouriteServiceScreenState extends State<FavouriteServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(
          title: "Favourite Services", hideBack: true),
      body: Obx(() {
        final controller = Get.find<ServicesController>();
        final favoriteServices = controller.services.where((service) => service.isFavorite).toList();
        
        if (favoriteServices.isEmpty) {
          return const Center(
            child: Text('No favorite services yet!'),
          );
        }
        
        return SlideInUp(
          child: ListView.separated(
            itemCount: favoriteServices.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              return ServiceCardWidget(service: favoriteServices[index]);
            },
          ),
        );
      }),
    );
  }
}
