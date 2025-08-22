import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/appcolors/app_colors.dart';
import '../textwidget/text_widget.dart';

class MyCustomTextField {
  static Widget textField({
    required String hintText,
    String? lableText,
    String? valText,
    int? maxLine,
    int? maxLength,
    bool readonly = false,
    bool obcureText = false,
    Color? borderClr,
    double? borderRadius,
    Color? fillColor,
    Color? textClr,
    Widget? prefixIcon,
    Widget? suffixIcon,
    FocusNode? focusNode,
    Function()? onTap,
    Function(String val)? onChange,
    required TextEditingController controller,
    TextInputType? textInputType,
    TextCapitalization? textCapitalization,
  }) {
    return TextFormField(
      readOnly: readonly,
      maxLines: maxLine ?? 1,
      controller: controller,
      maxLength: textInputType == TextInputType.phone ? 10 : maxLength,
      keyboardType: textInputType,
      textInputAction: TextInputAction.next,
      cursorColor: AppColors.black54,
      focusNode: focusNode,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      style: GoogleFonts.outfit(
          textStyle:
              TextStyle(fontSize: 14, color: textClr ?? AppColors.black)),
      validator: (value) {
        if (value == '') {
          if (valText != null) {
            return valText;
          }
        }
        return null;
      },
      onTap: onTap,
      onChanged: onChange,
      obscureText: obcureText,
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelText: lableText,
          hintText: hintText,
          fillColor:fillColor?? AppColors.transparent,
          filled: true,
          labelStyle: GoogleFonts.outfit(
              textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textClr ?? AppColors.primary,
          )),
           hintStyle: GoogleFonts.outfit(
              textStyle: TextStyle(
            fontSize: 14,
            color: textClr ?? AppColors.black54 ,
          )),
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              borderSide:
                  BorderSide(color: borderClr ?? AppColors.primary, width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              borderSide:
                  BorderSide(color: borderClr ?? AppColors.primary, width: 2)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              borderSide:
                  BorderSide(color: borderClr ?? AppColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              borderSide:
                  BorderSide(color: borderClr ?? AppColors.primary, width: 2)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              borderSide:
                  BorderSide(color: borderClr ?? AppColors.primary, width: 2)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          counterText: "",
          suffixIcon: suffixIcon,
          // constraints: BoxConstraints(maxHeight: 50),
          prefix: prefixIcon),
    );
  }

  static textFieldPassword({
    required String hintText,
    required bool isObscureText,
    required String valText,
    Color? borderClr,
    double? borderRadius,
    Color? textClr,
    int? maxLine,
    String? lableText,
    required TextEditingController controller,
    bool? isPasswordField,
    bool? validator,
  }) {
    RxBool isVisible = true.obs;
    isVisible.value = isObscureText;
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lableText != null)
            TextWidget(
                text: lableText, textSize: 12, fontWeight: FontWeight.w500),
          if (lableText != null) const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLine ?? 1,
            controller: controller,
            cursorColor: AppColors.black54,
            style: GoogleFonts.outfit(
                textStyle:
                    TextStyle(fontSize: 14, color: textClr ?? AppColors.black)),
            validator: (value) {
              if (validator != null) {
                if (value == null || value.isEmpty) {
                  return 'Password cannot be empty';
                }

                // Minimum 8 characters
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }

                // At least one letter and one number
                if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                  return 'Password must contain both letters and numbers';
                }

                // At least one special character
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'Password must contain one special character';
                }
              } else {
                if (value == '') {
                  if (valText != null) {
                    return valText;
                  }
                }
              }
              return null;
            },
            decoration: InputDecoration(
              counterText: '',
              alignLabelWithHint: true,
              filled: true,
              fillColor: AppColors.transparent,
              hintStyle: GoogleFonts.outfit(
                  textStyle: TextStyle(
                fontSize: 12,
                color: textClr ?? AppColors.black54,
              )),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  borderSide: BorderSide(
                      color: borderClr ?? AppColors.blackBorder, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  borderSide: BorderSide(
                      color: borderClr ?? AppColors.blackBorder, width: 1)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  borderSide: BorderSide(
                      color: borderClr ?? AppColors.blackBorder, width: 1)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  borderSide: BorderSide(
                      color: borderClr ?? AppColors.blackBorder, width: 1)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  borderSide: BorderSide(
                      color: borderClr ?? AppColors.blackBorder, width: 1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              hintText: hintText.tr,
              // constraints: BoxConstraints(maxHeight: 50),
              suffixIcon: isPasswordField != null
                  ? InkWell(
                      onTap: () {
                        isVisible.value = !isVisible.value;
                      },
                      child: Icon(
                        !isVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.black54,
                        size: 20,
                      ),
                    )
                  : const SizedBox(),
            ),
            obscureText: isVisible.value,
          ),
        ],
      );
    });
  }
}
