import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/payment/payment_controller.dart';
import '../../models/booking_model.dart';
import '../../utils/appcolors/app_colors.dart';
import '../../utils/helper/helper_sncksbar.dart';
import '../../widget/buttons/button.dart';
import '../../widget/textwidget/text_widget.dart';
import '../orderConfirmScreen/order_confirm_screen.dart';

class RazorpayPaymentScreen extends StatefulWidget {
  final Booking booking;
  final double amount;
  final String userEmail;
  final String userPhone;

  const RazorpayPaymentScreen({
    super.key,
    required this.booking,
    required this.amount,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  late PaymentController _paymentController;

  @override
  void initState() {
    super.initState();
    _initializePaymentController();
    _setupPaymentCallbacks();
  }

  void _initializePaymentController() {
    try {
      _paymentController = Get.find<PaymentController>();
    } catch (e) {
      // If PaymentController is not found, create it
      _paymentController = Get.put(PaymentController());
    }
    
    // Listen for payment status changes
    ever(_paymentController.paymentStatus.obs, (String status) {
      if (status == 'success') {
        // Navigate to success screen
        Get.offAll(() => OrderConfirmScreen(booking: widget.booking));
      }
    });
  }

  void _setupPaymentCallbacks() {
    // Payment callbacks are already set up in the service
    // We can add additional logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const TextWidget(
          text: "Payment",
          textSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Details Card
                _buildServiceDetailsCard(),
                const SizedBox(height: 20),
                
                // Payment Amount Card
                _buildPaymentAmountCard(),
                const SizedBox(height: 20),
                
                // Payment Status
                if (_paymentController.paymentStatus != 'pending')
                  _buildPaymentStatusCard(),
                
                const Spacer(),
                
                // Payment Button
                _buildPaymentButton(),
                const SizedBox(height: 16),
                
                // Cancel Button
                if (_paymentController.paymentStatus == 'pending')
                  _buildCancelButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextWidget(
            text: "Service Details",
            textSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: widget.booking.service.name,
            textSize: 14,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 4),
          TextWidget(
            text: widget.booking.location.locationAddress.address,
            textSize: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 4),
          TextWidget(
            text: "Date: ${widget.booking.selectTimeAndDate.date}",
            textSize: 12,
            color: Colors.grey.shade600,
          ),
          TextWidget(
            text: "Time: ${widget.booking.selectTimeAndDate.time}",
            textSize: 12,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAmountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TextWidget(
            text: "Total Amount",
            textSize: 16,
            fontWeight: FontWeight.bold,
          ),
          TextWidget(
            text: "₹${widget.amount.toStringAsFixed(2)}",
            textSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (_paymentController.paymentStatus) {
      case 'processing':
        statusText = "Processing Payment...";
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'success':
        statusText = "Payment Successful!";
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'failed':
        statusText = "Payment Failed";
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'cancelled':
        statusText = "Payment Cancelled";
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
      default:
        statusText = "Payment Pending";
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextWidget(
              text: statusText,
              textSize: 14,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton.primaryButton(
        onButtonPressed: _paymentController.isLoading ? null : _processPayment,
        title: _paymentController.isLoading ? "Processing..." : "Pay with Razorpay",
        height: 50,
        fontSize: 16,
        textColor: Colors.white,
        bgColor: _paymentController.isLoading ? AppColors.grey : AppColors.primary,
        isLoading: _paymentController.isLoading,
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton.outlineButton(
        onButtonPressed: _cancelPayment,
        title: "Cancel Payment",
        height: 50,
        fontSize: 16,
        borderColor: Colors.red,
      ),
    );
  }

  Future<void> _processPayment() async {
    try {
      final success = await _paymentController.processPayment(
        booking: widget.booking,
        amount: widget.amount,
        userEmail: widget.userEmail,
        userPhone: widget.userPhone,
        notes: {
          'serviceName': widget.booking.service.name,
          'bookingDate': widget.booking.selectTimeAndDate.date.toString(),
          'bookingTime': widget.booking.selectTimeAndDate.time,
        },
      );

      if (success) {
        // Payment processing started successfully
        HelperSnackBar.info('Payment window opened');
      }
    } catch (e) {
      HelperSnackBar.error('Failed to process payment: $e');
    }
  }

  void _cancelPayment() {
    _paymentController.cancelPayment();
    Get.back();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
