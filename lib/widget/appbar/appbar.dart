import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/appcolors/app_colors.dart';
import '../textwidget/text_widget.dart';

class HelperAppBar {
  static appbarHelper({
    required String title,
    List<Widget>? action,
    Color? bgColor,
    bool? hideBack,
    bool autoAction = false,
  }) {
    return PreferredSize(
        preferredSize: const Size(0, 56),
        child: AppBar(
          backgroundColor: bgColor ?? AppColors.transparent,
          elevation: 0,
          leadingWidth: 45,
          iconTheme: const IconThemeData(color: AppColors.black),
          scrolledUnderElevation: 0,
          title: TextWidget(
              text: title,
              fontWeight: FontWeight.w500,
              maxLine: 2,
              textSize: 17),
          centerTitle: true,
          automaticallyImplyLeading: hideBack == true ? false : true,
          actions: action,
          leading: hideBack == true
              ? null
              : IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_sharp,
                    size: 20,
                    color: AppColors.black,
                  ),
                ),
        ));
  }
}
