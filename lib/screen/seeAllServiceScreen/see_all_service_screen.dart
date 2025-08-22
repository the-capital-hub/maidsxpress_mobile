import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "All Services"),
      body: ZoomInDown(
        child: ListView.separated(
          itemCount: 5,
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
          separatorBuilder: (context, index) => const SizedBox(height: 0),
          itemBuilder: (BuildContext context, int index) {
            return const ServiceCardWidget();
          },
        ),
      ),
    );
  }
}
