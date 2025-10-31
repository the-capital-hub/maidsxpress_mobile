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
    bool isLoading = false,
  }) {
    return Container(
      width: width ?? Get.width,
      height: height ?? 48,
      decoration: BoxDecoration(
        color: (onButtonPressed == null || isLoading)
            ? (bgColor ?? AppColors.primary).withOpacity(0.7)
            : bgColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius ?? 100),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
        ),
        onPressed: isLoading ? null : onButtonPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
            ],
            TextWidget(
              text: title,
              textSize: fontSize ?? 14,
              fontWeight: FontWeight.w500,
              color: (onButtonPressed == null || isLoading)
                  ? (textColor ?? AppColors.white).withOpacity(0.7)
                  : textColor ?? AppColors.white,
            ),
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
    bool isLoading = false, // Added isLoading parameter
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
        onPressed: isLoading ? null : onButtonPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary), // Match outline button theme
                ),
              ),
              const SizedBox(width: 12),
            ],
            icon ?? const SizedBox(),
            TextWidget(
              text: title,
              textSize: fontSize ?? 14,
              fontWeight: FontWeight.w500,
              color: isLoading
                  ? AppColors.grey // Dim text when loading
                  : AppColors.black,
            ),
          ],
        ),
      ),
    );
  }
}
