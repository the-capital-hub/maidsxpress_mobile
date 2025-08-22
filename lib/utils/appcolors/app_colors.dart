import 'package:flutter/material.dart';

class AppColors {
  // static const Color primaryColor = Colors.black;
  static const Color primary = Color(0XFF008B80);
  static const Color buttonGrad1 = Color(0XFF96008E);
  static const Color buttonGrad2 = Color(0XFF121696);
  static const Color buttonHome = Color(0XFFF6E9FE);
  static const Color transparent = Colors.transparent;
  static Color grey100 = Colors.grey.shade100;
  static Color grey200 = Colors.grey.shade200;
  static Color grey300 = Colors.grey.shade300;
  static const Color grey = Colors.grey;
  static Color grey700 = Colors.grey.shade700;
  static const Color green = Color(0xffB7F36B);
  static Color green700 = Colors.green.shade700;
  static const Color redColor = Colors.red;
  static const Color blue = Colors.blue;
  static const Color golden = Color(0xffF4B400);
  static const Color black = Color(0xFF000000);
  static const Color black12 = Colors.black12;
  static const Color black38 = Colors.black38;
  static const Color black54 = Colors.black54;
  static const Color black87 = Colors.black87;
  // static Color black45 = Colors.black45;
  static const Color blackCard = Color(0XFF25252D);
  static Color blackBorder = Color(0XFF4a4a4a).withOpacity(0.5);

  static const Color white = Color(0xFFFFFFFF);
  // static Color white70 = Colors.white70;
  static const Color white12 = Colors.white12;
  static const Color white38 = Colors.white38;
  static const Color white54 = Colors.white54;
  static const Color whiteCard = Color(0XFFFF8F8F8);

  static const LinearGradient primaryGradient = LinearGradient(
      colors: [
        AppColors.buttonGrad1,
        AppColors.buttonGrad2,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0, 1],
      tileMode: TileMode.decal);
}
