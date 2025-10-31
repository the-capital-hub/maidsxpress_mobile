import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/screen/orderConfirmScreen/view_receipt_screen.dart';
import 'package:maidxpress/models/booking_model.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

class OrderConfirmScreen extends StatefulWidget {
  final dynamic booking; // Can be Booking object or Map<String, dynamic>
  
  const OrderConfirmScreen({super.key, required this.booking});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  @override
  void initState() {
    super.initState();
    print('OrderConfirm: Received booking type: ${widget.booking.runtimeType}');
    if (widget.booking is Booking) {
      print('OrderConfirm: Booking paymentStatus: ${(widget.booking as Booking).paymentStatus}');
      print('OrderConfirm: Booking transactionNumber: ${(widget.booking as Booking).transactionNumber}');
    } else if (widget.booking is Map) {
      print('OrderConfirm: Booking (Map) paymentStatus: ${(widget.booking as Map)['paymentStatus']}');
      print('OrderConfirm: Booking (Map) transactionNumber: ${(widget.booking as Map)['transactionNumber']}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            sizedTextfield,
            sizedTextfield,
            sizedTextfield,
            sizedTextfield,
            const TextWidget(
              text: "Thank You!",
              textSize: 25,
              fontWeight: FontWeight.w600,
            ),
            sizedTextfield,
            const TextWidget(
              text: "Yay ! Payment Received",
              textSize: 16,
              fontWeight: FontWeight.w500,
            ),
            sizedTextfield,
            const TextWidget(text: "We are on the away..!", textSize: 14),
            sizedTextfield,
            Image.asset(PngAssetPath.paysuccessImg),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primaryButton(
                onButtonPressed: () {
                  final booking = widget.booking;
                  final id = (booking is Map)
                      ? (booking['_id']?.toString() ?? booking['id']?.toString() ?? '')
                      : (booking?.id?.toString() ?? '');
                  if (id.isEmpty) return;
                  
                  // Get orderId if booking has one
                  String? orderId;
                  Map<String, dynamic>? bookingJson;
                  
                  if (booking is Booking) {
                    orderId = booking.orderId;
                    // Convert Booking to JSON to ensure all nested data is preserved
                    bookingJson = booking.toJson();
                  } else if (booking is Map<String, dynamic>) {
                    orderId = booking['orderId']?.toString();
                    bookingJson = booking;
                  }
                  
                  print('OrderConfirm: Passing booking to EReceipt - paymentStatus: ${booking is Booking ? booking.paymentStatus : 'unknown'}');
                  
                  Get.to(() => const EReceiptScreen(), arguments: {
                    'bookingId': id,
                    'orderId': orderId,
                    'booking': bookingJson, // Pass as JSON
                  });
                },
                title: "View  E-Receipt"),
            sizedTextfield,
            InkWell(
              onTap: () => Get.offAllNamed('/landing'),
              child: const TextWidget(
                  text: "Home",
                  textSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            )
          ],
        ),
      ),
    );
  }
}
