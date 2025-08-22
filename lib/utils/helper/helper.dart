import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/appcolors/app_colors.dart';
import '../../utils/constant/asset_constant.dart';
import '../../widget/textwidget/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';

class Helper {
  static String formatPrice(String text) {
    return "\u{20B9} $text";
  }

  static String formatDate({String? type, required String date}) {
    return DateFormat(type ?? "dd-MM-yyy").format(DateTime.parse(date));
  }

  static String formatDatePost(String date) {
    return DateFormat("yyyy-MM-dd").format(DateTime.parse(date));
  }

  static imageLoader() {
    return Container(
        color: Colors.black12,
        child: const SpinKitThreeBounce(size: 18, color: Colors.black));
  }

  static pageLoading() {
    return Container(
        height: double.infinity,
        width: double.infinity,
        child: const SpinKitThreeBounce(size: 30, color: AppColors.primary));
  }

  

  static showCustomSnackbar(BuildContext context, text) {
    final snackBar = SnackBar(
      content: TextWidget(
        text: text,
        textSize: 14,
        align: TextAlign.center,
        color: AppColors.white,
      ),
      behavior: SnackBarBehavior.floating, backgroundColor: AppColors.black54,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: 120, vertical: 20), // Center the Snackbar
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static tabLoading() {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.transparent,
        child: const SpinKitThreeBounce(size: 30, color: Colors.white));
  }

  static Widget spinLoading() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SpinKitThreeBounce(size: 30, color: Colors.white30),
    );
  }

  static loader(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SpinKitThreeBounce(size: 30, color: Colors.white);
      },
    );
  }

  static getDilogueLoader() {
    Get.defaultDialog(
        title: "",
        titlePadding: EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        content: SpinKitThreeBounce(size: 30, color: Colors.white));
  }

  static launchUrlFun(String url) async {
    await launch(url);
  }

  // Function to launch the phone dialer
  static launchPhone(String phoneNumber) async {
    // if (await canLaunch("tel:$phoneNumber")) {
    await launch("tel:$phoneNumber");
    // } else {
    //   throw 'Could not launch $phoneNumber';
    // }
  }

  // // Function to launch the mail app
  static launchMail(String mailAddress) async {
    // if (await canLaunch("mailto:$mailAddress")) {
    await launch("mailto:$mailAddress");
    // } else {
    //   throw 'Could not launch $mailAddress';
    // }
  }
}
