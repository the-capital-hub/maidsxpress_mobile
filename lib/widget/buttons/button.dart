import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../utils/appcolors/app_colors.dart';
import '../textwidget/text_widget.dart';

class AppButton {
  static Widget primaryButton({
    required void Function()? onButtonPressed,
    required String title,
    double? height,
    Color? bgColor,
    Color? textColor,
    Widget? suffixIcon,
    double? borderRadius,
    double? width,
    double? fontSize,
  }) {
    return Container(
      width: width ?? Get.width,
      height: height ?? 48,
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius ?? 100),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor:
              Colors.transparent, // Make button background transparent
          shadowColor: Colors.transparent, // Remove any shadow
        ),
        onPressed: onButtonPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Opacity(opacity: 0, child: suffixIcon ?? const SizedBox()),
            TextWidget(
              text: title,
              textSize: fontSize ?? 14,
              fontWeight: FontWeight.w500,
              color: textColor ?? AppColors.white,
            ),
            suffixIcon ?? const SizedBox()
          ],
        ),
      ),
    );
  }

  static Widget outlineButton({
    required void Function()? onButtonPressed,
    required String title,
    double? height,
    Color? bgColor,
    Color? borderColor,
    double? borderRadius,
    double? fontSize,
    double? width,
    Widget? icon,
  }) {
    return Container(
      width: width ?? Get.width,
      height: height ?? 45,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? AppColors.blackBorder),
        borderRadius: BorderRadius.circular(borderRadius ?? 100),
        color: bgColor ?? AppColors.transparent,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(4),
          shape: const StadiumBorder(),
          backgroundColor: bgColor ?? AppColors.transparent,
          splashFactory: NoSplash.splashFactory,
        ).copyWith(
          shadowColor: MaterialStateProperty.all(Colors.transparent),
        ),
        onPressed: onButtonPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? const SizedBox(),
            TextWidget(
              text: title,
              textSize: fontSize ?? 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }
}
