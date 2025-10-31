import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/booking_model.dart';
import '../../screen/orderConfirmScreen/order_confirm_screen.dart';
import '../../utils/helper/helper_sncksbar.dart';

class PaymentController extends GetxController {
  Razorpay? _razorpay;
  
  // Observable variables
  final RxBool _isLoading = false.obs;
  final RxString _paymentStatus = 'pending'.obs;
  final RxString _currentOrderId = ''.obs;
  final RxString _currentBookingId = ''.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  String get paymentStatus => _paymentStatus.value;
  String get currentOrderId => _currentOrderId.value;
  String get currentBookingId => _currentBookingId.value;

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
  }

  /// Initialize Razorpay
  void _initializeRazorpay() {
    try {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      debugPrint('✅ Razorpay initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Razorpay: $e');
    }
  }

  /// Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    _isLoading.value = false;
    _paymentStatus.value = 'success';
    
    HelperSnackBar.success('Payment Successful! 🎉');
    
    // Navigate to success screen
    Get.offAll(() => OrderConfirmScreen(booking: _getCurrentBooking()));
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error: ${response.message}');
    debugPrint('❌ Payment Error Code: ${response.code}');
    
    _isLoading.value = false;
    _paymentStatus.value = 'failed';
    
    // Handle user cancellation differently
    String errorCode = response.code?.toString() ?? '';
    String errorMessage = response.message ?? '';
    
    // Check if this is a user cancellation
    if (errorCode == 'USER_CANCELLED' || 
        errorCode == 'PAYMENT_CANCELLED' ||
        errorMessage.toLowerCase().contains('cancelled') ||
        errorMessage.toLowerCase().contains('user cancelled') ||
        errorMessage.toLowerCase().contains('payment cancelled')) {
      
      debugPrint('🔄 User cancelled payment - not showing error dialog');
      
      HelperSnackBar.info('Payment was cancelled. You can try again.');
      return;
    }
    
    // For actual payment errors
    String finalErrorMessage = errorMessage.isNotEmpty ? errorMessage : 'Payment failed. Please try again.';
    HelperSnackBar.error('Payment Failed: $finalErrorMessage');
  }

  /// Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('🔗 External Wallet: ${response.walletName}');
    HelperSnackBar.info('Redirecting to ${response.walletName}...');
  }


  // Process payment with Razorpay
  Future<bool> processPayment({
    required Booking booking,
    required double amount,
    required String userEmail,
    required String userPhone,
    Map<String, dynamic>? notes,
  }) async {
    try {
      debugPrint('🚀 Starting Razorpay payment process...');
      debugPrint('Amount: $amount');
      debugPrint('Booking ID: ${booking.id}');
      debugPrint('Customer: $userEmail');
      
      _isLoading.value = true;
      _paymentStatus.value = 'processing';
      _currentBookingId.value = booking.id ?? '';

      // Check if Razorpay is initialized
      if (_razorpay == null) {
        debugPrint('❌ Razorpay not initialized!');
        throw Exception('Razorpay not initialized');
      }

      // Generate order ID
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      _currentOrderId.value = orderId;

      var options = {
        'key': 'rzp_test_RIZcnSsQPsvbLa', // Your Razorpay key
        'amount': (amount * 100).round(), // Amount in paise
        'name': 'MaidsXpress',
        'description': 'Payment for ${booking.service.name}',
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': 'Customer',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      debugPrint('🚀 Opening Razorpay with options: $options');
      
      // Open Razorpay payment gateway
      _razorpay!.open(options);
      
      return true;
    } catch (e) {
      _isLoading.value = false;
      _paymentStatus.value = 'failed';
      debugPrint('❌ Error processing payment: $e');
      
      HelperSnackBar.error('Payment failed: ${e.toString()}');
      return false;
    }
  }

  // Handle payment success
  void handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    _paymentStatus.value = 'success';
    
    HelperSnackBar.success('Payment successful!');
    
    // You can add additional logic here like:
    // - Update booking status
    // - Navigate to success screen
    // - Send confirmation email
  }

  // Handle payment error
  void handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    _paymentStatus.value = 'failed';
    
    String errorMessage = 'Payment failed';
    if (response.message != null) {
      errorMessage = response.message!;
    }
    
    HelperSnackBar.error(errorMessage);
  }

  // Handle external wallet
  void handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    // Handle external wallet selection
  }

  // Retry payment
  Future<bool> retryPayment({
    required Booking booking,
    required double amount,
    required String userEmail,
    required String userPhone,
    Map<String, dynamic>? notes,
  }) async {
    _paymentStatus.value = 'pending';
    return await processPayment(
      booking: booking,
      amount: amount,
      userEmail: userEmail,
      userPhone: userPhone,
      notes: notes,
    );
  }

  // Cancel payment
  void cancelPayment() {
    _paymentStatus.value = 'cancelled';
    _isLoading.value = false;
    HelperSnackBar.info('Payment cancelled');
  }

  // Reset payment state
  void resetPaymentState() {
    _paymentStatus.value = 'pending';
    _currentOrderId.value = '';
    _currentBookingId.value = '';
    _isLoading.value = false;
  }

  // Get current booking (placeholder)
  Booking _getCurrentBooking() {
    // This should return the current booking being processed
    // For now, return a placeholder
    return Booking(
      title: 'Current Booking',
      service: BookingService(
        name: 'Service',
        selectedSubServices: [],
      ),
      selectTimeAndDate: SelectTimeAndDate(
        date: DateTime.now(),
        time: '10:00 AM',
      ),
      location: Location(
        locationAddress: LocationAddress(name: 'Home', address: 'Address'),
        phoneNumber: '9999999999',
      ),
      transactionNumber: _currentOrderId.value,
      paymentStatus: 'success',
      amount: 0.0,
    );
  }

  @override
  void onClose() {
    if (_razorpay != null) {
      _razorpay!.clear();
    }
    super.onClose();
  }
}
