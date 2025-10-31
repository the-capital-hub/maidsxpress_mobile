import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/booking/bookings_controller.dart';
import 'package:maidxpress/controller/booking/coupon_controller.dart';
import 'package:maidxpress/models/coupon_model.dart';
import 'package:maidxpress/models/booking_model.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';
import 'package:maidxpress/screen/orderConfirmScreen/order_confirm_screen.dart';
import '../../utils/constant/asset_constant.dart';
import '../../services/auth_service.dart';
import 'dart:developer' as developer;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:maidxpress/services/razorpay_service.dart';

class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  String selectedPayment = "Razorpay";
  final CouponController _couponController = Get.find<CouponController>();
  final BookingsController _bookingsController = Get.find<BookingsController>();
  final AuthService _authService = AuthService();
  final TextEditingController _couponText = TextEditingController();
  double _total = 0;
  ApplyCouponResult? _applied;
  bool _isLoading = false; // Added loading state
  Razorpay? _razorpay;
  Booking? _currentBooking;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final totalArg = args?['totalAmount'];
    if (totalArg is num) {
      _total = totalArg.toDouble();
    } else {
      _total = 0.0;
      print('Warning: totalAmount is not a number in Get.arguments: $totalArg');
    }
    print('Initialized _total: $_total');
    print('Received arguments: $args');
    
    // Initialize Razorpay
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    developer.log('🎉 Payment Success Callback Triggered');
    developer.log('Payment ID: ${response.paymentId}');
    developer.log('Razorpay Order ID: ${response.orderId}');
    developer.log('Signature: ${response.signature}');
    
    HelperSnackBar.success('Payment Successful! 🎉');

    if (_currentBooking != null) {
      final paymentId = response.paymentId ?? '';
      final razorpayOrderId = response.orderId ?? response.paymentId ?? '';

      // Update booking status locally with payment info
      // Verification was already done before opening Razorpay
      developer.log('💰 Updating booking with payment details...');
      
      List<BookingOrder> updatedOrders = _currentBooking!.orders.map((order) {
        return BookingOrder(
          orderId: razorpayOrderId,
          paymentStatus: 'paid',
          transactionNumber: paymentId,
          createdAt: order.createdAt,
        );
      }).toList();
      
      if (updatedOrders.isEmpty) {
        updatedOrders = [
          BookingOrder(
            orderId: razorpayOrderId,
            paymentStatus: 'paid',
            transactionNumber: paymentId,
            createdAt: DateTime.now(),
          ),
        ];
      }
      
      _currentBooking = _currentBooking!.copyWith(
        orderId: razorpayOrderId,
        transactionNumber: paymentId,
        paymentStatus: 'paid',
        bookingStatus: 'booked',
        orders: updatedOrders,
      );
      
      developer.log('✅ Booking updated with paid status');
      developer.log('📋 Payment ID: $paymentId');
      developer.log('📋 Order ID: $razorpayOrderId');

      developer.log('🚀 Navigating to Order Confirm Screen with updated booking');
      developer.log('📋 Final booking data: ${_currentBooking!.toJson()}');
      
      // Convert booking to JSON to preserve all nested data during navigation
      final bookingJson = _currentBooking!.toJson();
      developer.log('📋 Booking JSON paymentStatus: ${bookingJson['paymentStatus']}');
      developer.log('📋 Booking JSON transactionNumber: ${bookingJson['transactionNumber']}');
      if (bookingJson['orders'] != null && (bookingJson['orders'] as List).isNotEmpty) {
        developer.log('📋 Booking JSON first order paymentStatus: ${(bookingJson['orders'] as List).first['paymentStatus']}');
        developer.log('📋 Booking JSON first order transactionNumber: ${(bookingJson['orders'] as List).first['transactionNumber']}');
      }
      
      Get.offAll(() => OrderConfirmScreen(booking: bookingJson));
    } else {
      developer.log('❌ Current booking is null');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    developer.log('Payment Error: ${response.message}');
    
    String errorCode = response.code?.toString() ?? '';
    String errorMessage = response.message ?? '';
    
    // Check if this is a user cancellation
    if (errorCode == 'USER_CANCELLED' || 
        errorCode == 'PAYMENT_CANCELLED' ||
        errorMessage.toLowerCase().contains('cancelled') ||
        errorMessage.toLowerCase().contains('user cancelled') ||
        errorMessage.toLowerCase().contains('payment cancelled')) {
      HelperSnackBar.info('Payment was cancelled');
      return;
    }
    
    HelperSnackBar.error('Payment Failed: ${errorMessage.isNotEmpty ? errorMessage : 'Please try again'}');
    setState(() => _isLoading = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    developer.log('External Wallet: ${response.walletName}');
    HelperSnackBar.info('Redirecting to ${response.walletName}...');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const TextWidget(
          text: "Payment Options",
          textSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const TextWidget(
                        text: "Payment Methods",
                        textSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 12),
                      _buildPayLaterOption(),
                      const SizedBox(height: 8),
                      _buildRazorpayOption(),
                      const SizedBox(height: 8),
                      const TextWidget(
                        text: "Pay by any UPI App",
                        textSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      _buildUPIOption("Google Pay", PngAssetPath.gpayImg, "(Coming soon)"),
                      _buildUPIOption("PhonePe", PngAssetPath.phonepeImg, "(Coming soon)"),
                      _buildUPIOption("Paytm", PngAssetPath.paytmImg, "(Coming soon)"),
                      const SizedBox(height: 8),
                      _buildAddNewOption(
                        "Add New UPI ID",
                        "You need to have a registered UPI ID",
                        () {},
                      ),
                      const SizedBox(height: 20),
                      const TextWidget(
                        text: "Credit & Debit Cards",
                        textSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 12),
                      _buildAddNewOption(
                        "Add New Card",
                        "Save and Pay via Cards",
                        () {},
                      ),
                      const SizedBox(height: 20),
                      const TextWidget(
                        text: "Offers & Benefits",
                        textSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 12),
                      _buildOffersCard(),
                      const SizedBox(height: 12),
                      _buildCouponInput(),
                      const SizedBox(height: 20),
                      const TextWidget(
                        text: "CANCELLATION POLICY",
                        textSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 6),
                      const TextWidget(
                        maxLine: 2,
                        text:
                            "By avoiding cancellations after placing your order. A 100% cancellation fee will be applied.",
                        textSize: 12,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 12 + bottomInset,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text:
                                    "₹${(_applied?.discountedTotal ?? _total).toStringAsFixed(2)}",
                                textSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {},
                                child: const TextWidget(
                                  text: "View Detailed Bill",
                                  textSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          child: AppButton.primaryButton(
                            onButtonPressed: _isLoading ? null : _onProceed,
                            title:
                                _isLoading ? "Processing..." : "Proceed to Pay",
                            width: 160,
                            height: 48,
                            fontSize: 15,
                            textColor: Colors.white,
                            bgColor:
                                _isLoading ? AppColors.grey : AppColors.primary,
                            isLoading:
                                _isLoading, // Disable button while loading
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRazorpayOption() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.primary.withOpacity(0.05),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.payment,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const TextWidget(
          text: "Pay Now (Card / UPI)",
          textSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        subtitle: const TextWidget(
          text: "Cards, UPI, Wallets & More",
          textSize: 12,
          color: Colors.grey,
        ),
        trailing: Radio<String>(
          value: "Razorpay",
          groupValue: selectedPayment,
          activeColor: AppColors.primary,
          onChanged: (val) {
            setState(() {
              selectedPayment = val!;
            });
          },
        ),
        onTap: () {
          setState(() {
            selectedPayment = "Razorpay";
          });
        },
      ),
    );
  }

  Widget _buildPayLaterOption() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              "PL",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: const TextWidget(
          text: "Pay Later",
          textSize: 15,
          fontWeight: FontWeight.w500,
        ),
        trailing: Radio<String>(
          value: "PayLater",
          groupValue: selectedPayment,
          activeColor: AppColors.primary,
          onChanged: (val) {
            setState(() {
              selectedPayment = val!;
            });
          },
        ),
        onTap: () {
          setState(() {
            selectedPayment = "PayLater";
          });
        },
      ),
    );
  }

  Widget _buildUPIOption(String title, String iconPath, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 30,
          height: 30,
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        title: Row(
          children: [
            TextWidget(
              text: title,
              textSize: 15,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(width: 4),
            TextWidget(
              text: subtitle,
              textSize: 12,
              color: Colors.grey,
            ),
          ],
        ),
        trailing: Radio<String>(
          value: title,
          groupValue: selectedPayment,
          activeColor: AppColors.primary,
          onChanged: null, // Disabled for coming soon options
        ),
        onTap: null, // Disabled for coming soon options
      ),
    );
  }

  Widget _buildAddNewOption(String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Icon(
            Icons.add,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: TextWidget(
          text: title,
          textSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        subtitle: TextWidget(
          text: subtitle,
          textSize: 12,
          color: Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOffersCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Icon(
            Icons.local_offer,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: const TextWidget(
          text: "Have a coupon?",
          textSize: 15,
          fontWeight: FontWeight.w500,
        ),
        subtitle: const TextWidget(
          text: "Apply and get instant discount",
          textSize: 12,
          color: Colors.black54,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildCouponInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponText,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: 'Enter coupon code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (v) {
                final up = v.toUpperCase();
                if (v != up) {
                  final sel = _couponText.selection;
                  _couponText.value = TextEditingValue(
                    text: up,
                    selection: sel,
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: AppButton.outlineButton(
              onButtonPressed: _applyCoupon,
              title: 'Apply',
              height: 40,
              borderColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyCoupon() async {
    final code = _couponText.text.trim();
    if (code.isEmpty) {
      HelperSnackBar.error('Enter a coupon code');
      return;
    }
    final result =
        await _couponController.applyCoupon(code: code, totalAmount: _total);
    if (result != null && result.status) {
      setState(() => _applied = result);
      HelperSnackBar.success('Coupon applied');
      print(
          'Coupon applied: Discounted total = ${result.discountedTotal}, Discount amount = ${result.discountAmount}');
    } else {
      HelperSnackBar.error('Invalid coupon code');
    }
  }

  Future<void> _onProceed() async {
    if (_isLoading) return; // Prevent multiple taps
    setState(() => _isLoading = true);

    final args = Get.arguments as Map<String, dynamic>?;
    final draft = args?['bookingDraft'] as Map<String, dynamic>?;
    if (draft == null) {
      HelperSnackBar.error('Missing booking details');
      developer.log('Error: bookingDraft is null in Get.arguments');
      setState(() => _isLoading = false);
      return;
    }

    // Handle Pay Later
    if (selectedPayment == "PayLater") {
      await _handlePayLater(draft);
      return;
    }

    // Handle Razorpay payment
    if (selectedPayment == "Razorpay") {
      // Log the draft to see what we're receiving
      developer.log('📋 Full Draft Data Received:');
      developer.log('  Gender in selectTimeAndDate: ${draft['selectTimeAndDate']?['gender']}');
      developer.log('  Time in selectTimeAndDate: ${draft['selectTimeAndDate']?['time']}');
      developer.log('  Date in selectTimeAndDate: ${draft['selectTimeAndDate']?['date']}');
      developer.log('  Full selectTimeAndDate: ${draft['selectTimeAndDate']}');
      await _handleRazorpayPayment(draft);
      return;
    }

    // Handle other payment methods (existing logic)
    await _handleOtherPayments(draft);
  }

  Future<void> _handlePayLater(Map<String, dynamic> draft) async {
    try {
      final finalAmount = (_applied?.discountedTotal ?? _total).toDouble();
      
      // Create booking with pay later status - use PAY_LATER prefix
      final updatedDraft = Map<String, dynamic>.from(draft);
      updatedDraft['amount'] = finalAmount;
      updatedDraft['transactionNumber'] = 'PAY_LATER';
      updatedDraft['paymentStatus'] = 'pending';
      updatedDraft['bookingStatus'] = 'booked';
      updatedDraft['progressStatus'] = 'upcoming';
      updatedDraft['isRecurring'] = false;

      // Just ensure service field exists for safety
      if (updatedDraft['service'] == null) {
        updatedDraft['service'] = {};
      }

      if (_applied != null) {
        updatedDraft['coupon'] = _applied!.coupon.toJson();
        updatedDraft['discountAmount'] = _applied!.discountAmount;
      }

      final booking = Booking.fromJson(updatedDraft);
      final created = await _bookingsController.createBookingReturn(booking);
      
      if (created != null && created.id != null && created.id!.isNotEmpty) {
        HelperSnackBar.success('Booking confirmed!');
        setState(() => _isLoading = false);
        Get.offAll(() => OrderConfirmScreen(booking: created));
      } else {
        HelperSnackBar.error('Failed to create booking');
      }
    } catch (e) {
      developer.log('Pay Later error: $e');
      HelperSnackBar.error('Failed to process booking');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRazorpayPayment(Map<String, dynamic> draft) async {
    try {
      final finalAmount = (_applied?.discountedTotal ?? _total).toDouble();
      
      // Create booking first - don't use RAZORPAY_TXN prefix
      final updatedDraft = Map<String, dynamic>.from(draft);
      updatedDraft['amount'] = finalAmount;
      updatedDraft['transactionNumber'] = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      updatedDraft['paymentStatus'] = 'pending';
      updatedDraft['bookingStatus'] = 'booked';
      updatedDraft['progressStatus'] = 'upcoming';
      updatedDraft['isRecurring'] = false;

      if (_applied != null) {
        updatedDraft['coupon'] = _applied!.coupon.toJson();
        updatedDraft['discountAmount'] = _applied!.discountAmount;
      }

      // Log what we're about to send to server
      developer.log('📤 Sending to Server (Razorpay):');
      developer.log('  Gender: ${updatedDraft['selectTimeAndDate']?['gender']}');
      developer.log('  Time: ${updatedDraft['selectTimeAndDate']?['time']}');
      developer.log('  Date: ${updatedDraft['selectTimeAndDate']?['date']}');

      final booking = Booking.fromJson(updatedDraft);
      
      // Store the original transaction number BEFORE sending to server
      final originalTxnNumber = booking.transactionNumber;
      developer.log('📝 Original TXN from draft: $originalTxnNumber');
      
      final created = await _bookingsController.createBookingReturn(booking);
      
      if (created != null && created.id != null && created.id!.isNotEmpty) {
        // Use the booking as returned from server
        var updatedBooking = created;
        
        developer.log('✅ Booking created');
        developer.log('📝 Transaction from server: ${created.transactionNumber}');
        developer.log('📝 Original TXN we sent: $originalTxnNumber');
        
        // Get user details for payment
        final user = _authService.currentUser;
        final userEmail = user?.email ?? 'user@example.com';
        final userPhone = user?.phone ?? '9999999999';

        // Log all booking details
        developer.log('═══════════════════════════════════════════════════════');
        developer.log('📋 BOOKING DETAILS AFTER CREATION');
        developer.log('═══════════════════════════════════════════════════════');
        developer.log('Booking ID: ${created.id}');
        developer.log('Transaction Number: ${created.transactionNumber}');
        developer.log('Payment Status: ${created.paymentStatus}');
        developer.log('Booking Status: ${created.bookingStatus}');
        developer.log('Amount: ${created.amount}');
        
        // Log orders details
        if (created.orders.isNotEmpty) {
          developer.log('Orders Count: ${created.orders.length}');
          for (int i = 0; i < created.orders.length; i++) {
            final order = created.orders[i];
            developer.log('Order[$i] ID: ${order.orderId}');
            developer.log('Order[$i] Transaction: ${order.transactionNumber}');
            developer.log('Order[$i] Payment Status: ${order.paymentStatus}');
          }
        } else {
          developer.log('No orders found in booking');
        }
        developer.log('═══════════════════════════════════════════════════════');

        // Step 1: Create Razorpay order via API
        developer.log('📞 STEP 2: Creating Razorpay order via API...');
        
        // Get the orderId from the first order (booking.orderId)
        final receiptOrderId = updatedBooking.orders.isNotEmpty 
            ? updatedBooking.orders.first.orderId 
            : updatedBooking.orderId ?? created.id!;
        
        developer.log('📋 Using receipt (booking.orderId): $receiptOrderId');
        developer.log('📋 Booking ID: ${created.id}');
        developer.log('📋 Amount: $finalAmount');
        
        final razorpayOrderId = await razorpayService.createRazorpayOrderApi(
          amount: finalAmount,
          bookingId: created.id!,
          receipt: receiptOrderId,
        );
        
        if (razorpayOrderId != null && razorpayOrderId.isNotEmpty) {
          developer.log('✅ Razorpay order created: $razorpayOrderId');
          
          // Step 2: Call updateVerifiedOrderId BEFORE opening Razorpay
          developer.log('📞 STEP 3: Calling updateVerifiedOrderId...');
          developer.log('📋 Booking ID: ${created.id}');
          developer.log('📋 Razorpay Order ID: $razorpayOrderId');
          developer.log('📋 Init Transaction Number: $originalTxnNumber');
          
          // Use the original TXN we sent (not server response which might be PAY_LATER)
          final verified = await razorpayService.updateVerifiedOrderId(
            bookingId: created.id!,
            razorpayOrderId: razorpayOrderId,
            initTransactionNumber: originalTxnNumber, // Use original, not server response
            paymentId: '', // Not available yet, will be set after payment
            signature: '', // Not available yet, will be set after payment
          );
          
          if (verified) {
            developer.log('✅ updateVerifiedOrderId successful');
          } else {
            developer.log('⚠️ updateVerifiedOrderId failed, but continuing with payment');
          }
          
          // Update the booking to replace ORD- orders with the Razorpay order ID
          if (updatedBooking.orders.isNotEmpty) {
            final updatedOrders = [
              BookingOrder(
                orderId: razorpayOrderId,
                paymentStatus: 'pending',
                transactionNumber: originalTxnNumber, // Use the original TXN we sent
                createdAt: updatedBooking.orders.first.createdAt ?? DateTime.now(),
              ),
            ];
            
            updatedBooking = updatedBooking.copyWith(
              orderId: razorpayOrderId,
              orders: updatedOrders,
            );
            
            developer.log('📋 Updated booking with Razorpay order ID: $razorpayOrderId');
          }
          
          // Step 3: Open Razorpay with the actual order_id
          developer.log('📞 STEP 4: Opening Razorpay payment gateway...');
          await _openRazorpayDirectly(
            booking: updatedBooking,
            amount: finalAmount,
            userEmail: userEmail,
            userPhone: userPhone,
            razorpayOrderId: razorpayOrderId,
          );
        } else {
          developer.log('⚠️ Failed to create Razorpay order, opening without order_id');
          await _openRazorpayDirectly(
            booking: updatedBooking,
            amount: finalAmount,
            userEmail: userEmail,
            userPhone: userPhone,
          );
        }
      } else {
        HelperSnackBar.error('Failed to create booking');
      }
    } catch (e) {
      developer.log('Razorpay payment error: $e');
      
      // Provide more specific error messages
      String errorMessage = 'Failed to process payment';
      if (e.toString().contains('Server error')) {
        errorMessage = 'Payment service is temporarily unavailable. Please try again later.';
      } else if (e.toString().contains('Authentication failed')) {
        errorMessage = 'Session expired. Please login again.';
      } else if (e.toString().contains('Invalid payment request')) {
        errorMessage = 'Invalid booking details. Please try again.';
      } else if (e.toString().contains('Payment service unavailable')) {
        errorMessage = 'Payment service is down. Please try again later.';
      } else {
        errorMessage = 'Payment failed: ${e.toString()}';
      }
      
      HelperSnackBar.error(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOtherPayments(Map<String, dynamic> draft) async {
    try {
      final finalAmount = (_applied?.discountedTotal ?? _total).toDouble();

      // Create a new draft to avoid null issues
      final updatedDraft = Map<String, dynamic>.from(draft);
      
      // Ensure all required fields are set
      updatedDraft['amount'] = finalAmount;
      // Don't override transactionNumber if it already has PAY_LATER
      if (!updatedDraft.containsKey('transactionNumber') || 
           updatedDraft['transactionNumber'] != 'PAY_LATER') {
        updatedDraft['transactionNumber'] = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      }
      updatedDraft['paymentStatus'] = 'pending';
      updatedDraft['bookingStatus'] = 'booked';
      updatedDraft['progressStatus'] = 'upcoming';
      updatedDraft['isRecurring'] = false; // Set based on your logic

      if (_applied != null) {
        // Only add coupon fields if coupon is applied
        updatedDraft['coupon'] = _applied!.coupon.toJson();
        updatedDraft['discountAmount'] = _applied!.discountAmount;
      }

      // Validate required fields
      final serviceData = updatedDraft['service'] as Map<String, dynamic>?;
      if (serviceData == null || serviceData['selectedSubServices'] == null) {
        HelperSnackBar.error('Invalid service data');
        setState(() => _isLoading = false);
        return;
      }

      Booking booking;
      try {
        booking = Booking.fromJson(updatedDraft);
      } catch (e) {
        developer.log('ERROR: Failed to create Booking object: $e');
        HelperSnackBar.error('Invalid booking data format');
        setState(() => _isLoading = false);
        return;
      }

      final created = await _bookingsController.createBookingReturn(booking);
      if (created != null && created.id != null && created.id!.isNotEmpty) {
        HelperSnackBar.success('Booking confirmed');
        setState(() => _isLoading = false);
        Get.offAll(() => OrderConfirmScreen(booking: created));
      } else {
        HelperSnackBar.error('Failed to create booking');
        developer
            .log('Error: Failed to create booking, created booking: $created');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      HelperSnackBar.error('Failed to process payment: $e');
      developer.log('Payment processing error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openRazorpayDirectly({
    required Booking booking,
    required double amount,
    required String userEmail,
    required String userPhone,
    String? razorpayOrderId,
  }) async {
    try {
      _currentBooking = booking;
      
      if (_razorpay == null) {
        HelperSnackBar.error('Payment gateway not initialized');
        setState(() => _isLoading = false);
        return;
      }

      var options = {
        'key': 'rzp_test_RIZcnSsQPsvbLa',
        'amount': (amount * 100).round(),
        'name': 'MaidsXpress',
        'description': 'Payment for ${booking.service.name}',
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': 'Customer',
        },
        'external': {
          'wallets': ['paytm', 'gpay', 'phonepe'],
        },
      };
      
      // If we have a razorpay order ID, use it for better tracking
      if (razorpayOrderId != null && razorpayOrderId.isNotEmpty) {
        options['order_id'] = razorpayOrderId;
        developer.log('Using Razorpay order ID: $razorpayOrderId');
      }

      developer.log('Opening Razorpay with options: $options');
      
      // Open Razorpay payment gateway directly
      _razorpay!.open(options);
      
      setState(() => _isLoading = false);
    } catch (e) {
      developer.log('Error opening Razorpay: $e');
      HelperSnackBar.error('Failed to open payment gateway');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}
