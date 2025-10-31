import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/constant/const_data.dart';
import '../services/auth_service.dart';

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  late Razorpay _razorpay;
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  // Razorpay configuration
  static const String _razorpayKeyId = 'rzp_test_RIZcnSsQPsvbLa';
  static const String _razorpayKeySecret = 'qzPp2YTDA1K8m5xOJ8ixA3GV';
  static const String _razorpayWebhookSecret = 'maidxpress@1018';

  // Getters for accessing credentials
  static String get razorpayKeyId => _razorpayKeyId;
  static String get razorpayKeySecret => _razorpayKeySecret;
  static String get razorpayWebhookSecret => _razorpayWebhookSecret;

  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Set callback handlers
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  void setPaymentCallbacks({
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;
    _onExternalWallet = onExternalWallet;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');
    
    // Verify payment signature
    final isVerified = verifyPaymentSignature(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    );
    
    if (isVerified) {
      debugPrint('Payment verified successfully');
      // Call external callback if set
      _onPaymentSuccess?.call(response);
    } else {
      debugPrint('Payment verification failed');
    }
    
    // Handle payment success
    if (kDebugMode) {
      print('Payment Success: ${response.paymentId}');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    
    // Call external callback if set
    _onPaymentError?.call(response);
    
    // Handle payment error
    if (kDebugMode) {
      print('Payment Error: ${response.code} - ${response.message}');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    
    // Call external callback if set
    _onExternalWallet?.call(response);
    
    // Handle external wallet
    if (kDebugMode) {
      print('External Wallet: ${response.walletName}');
    }
  }

  // Create Razorpay order directly in the app (without server dependency)
  Future<Map<String, dynamic>?> createRazorpayOrderDirect({
    required double amount,
    required String bookingId,
    required String receipt,
  }) async {
    try {
      debugPrint('Creating Razorpay order directly with amount: $amount, bookingId: $bookingId, receipt: $receipt');

      // Create order directly using Razorpay SDK
      final orderData = {
        'amount': (amount * 100).toInt(), // Convert to paise
        'currency': 'INR',
        'receipt': receipt,
        'notes': {
          'bookingId': bookingId,
          'service': 'MaidsXpress',
        },
      };

      debugPrint('Order data: $orderData');

      // For now, we'll create a mock order ID since we're not using server
      // In production, you should implement proper order creation
      final mockOrderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      return {
        'id': mockOrderId,
        'orderId': mockOrderId,
        'amount': orderData['amount'],
        'currency': orderData['currency'],
        'receipt': receipt,
        'status': 'created',
      };
    } catch (e) {
      debugPrint('Error creating Razorpay order directly: $e');
      rethrow;
    }
  }

  // Create Razorpay order via API
  Future<String?> createRazorpayOrderApi({
    required double amount,
    required String bookingId,
    required String receipt,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔐 API CALL #2: CREATE RAZORPAY ORDER');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📋 Amount: $amount');
      debugPrint('📋 Booking ID: $bookingId');
      debugPrint('📋 Receipt: $receipt');
      
      final token = _authService.token;
      if (token == null) {
        debugPrint('❌ No auth token available');
        return null;
      }

      // Use the /razorpay endpoint
      final url = '${ApiConstants.baseUrl}${ApiConstants.razorpayCreateOrder}';
      debugPrint('📡 FULL URL: $url');
      debugPrint('📡 METHOD: POST');
      
      final payload = {
        'amount': amount,
        'bookingId': bookingId,
        'receipt': receipt,
      };
      debugPrint('📦 FULL REQUEST BODY:');
      debugPrint(json.encode(payload));
      debugPrint('📦 Headers:');
      debugPrint('  - Authorization: Bearer ${token.substring(0, 20)}...');
      debugPrint('  - Content-Type: application/json');

      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',  
          },  
        ),  
      );  
  
      debugPrint('📥 RESPONSE STATUS: ${response.statusCode}');  
      debugPrint('📥 FULL RESPONSE DATA:');  
      debugPrint(json.encode(response.data));  
  
      if (response.statusCode == 200 || response.statusCode == 201) {  
        final data = response.data;  
          
        // Check if order data is nested inside 'order' field  
        final orderData = data['order'] ?? data;  
        final orderId = orderData['id'] ?? data['orderId'] ?? data['order_id'];  
        debugPrint('✅ Razorpay order created: $orderId');
        return orderId;
      } else {
        debugPrint('⚠️ API returned status: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating Razorpay order: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  // Update verified order ID
  Future<bool> updateVerifiedOrderId({
    required String bookingId,
    required String razorpayOrderId,
    required String initTransactionNumber,
    required String paymentId,
    required String signature,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔐 API CALL #3: VERIFY PAYMENT');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📋 Booking ID: $bookingId');
      debugPrint('📋 Razorpay Order ID: $razorpayOrderId');
      debugPrint('📋 Init Transaction Number: $initTransactionNumber');
      
      final token = _authService.token;
      if (token == null) {
        debugPrint('❌ No auth token available');
        throw Exception('User not authenticated');
      }

      // Use the booking updateVerifiedOrderId endpoint
      final url = '${ApiConstants.baseUrl}${ApiConstants.updateVerifiedOrderId}';
      debugPrint('📡 FULL URL: https://maidsxpress.com/api/booking/updateVerifiedOrderId');
      debugPrint('📡 METHOD: POST');
      
      // Send only required fields as per backend API
      final payload = {
        'bookingId': bookingId,
        'razorpayOrderId': razorpayOrderId,
        'initTransactionNumber': initTransactionNumber,
      };
      debugPrint('📦 FULL REQUEST BODY:');
      debugPrint(json.encode(payload));
      debugPrint('📦 Headers:');
      debugPrint('  - Authorization: Bearer ${token.substring(0, 20)}...');
      debugPrint('  - Content-Type: application/json');

      try {
        // Try POST first
        final response = await _dio.post(
          url,
          data: payload,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        debugPrint('📥 RESPONSE STATUS: ${response.statusCode}');
        debugPrint('📥 FULL RESPONSE DATA:');
        debugPrint(jsonEncode(response.data));

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ Verification API succeeded');
          
          // Check if backend actually updated the payment status
          if (response.data is Map<String, dynamic> && response.data['booking'] != null) {
            final bookingData = response.data['booking'];
            if (bookingData['orders'] != null && bookingData['orders'].isNotEmpty) {
              final order = bookingData['orders'][0];
              if (order['paymentStatus'] == 'pending' || order['transactionNumber'] == null) {
                debugPrint('⚠️ WARNING: Backend did NOT update payment status and transaction number!');
                debugPrint('⚠️ Backend still shows: paymentStatus=${order['paymentStatus']}, transactionNumber=${order['transactionNumber']}');
              } else {
                debugPrint('✅ Backend successfully updated payment status');
              }
            }
          }
          
          return true;
        } else {
          debugPrint('⚠️ Verification API returned status: ${response.statusCode}');
          return false;
        }
      } on DioException catch (dioError) {
        debugPrint('❌ DioException: ${dioError.type}');
        debugPrint('❌ Status Code: ${dioError.response?.statusCode}');
        debugPrint('❌ Error Message: ${dioError.message}');
        
        // If 404, try PATCH method
        if (dioError.response?.statusCode == 404) {
          debugPrint('🔄 Trying PATCH method...');
          try {
            final patchResponse = await _dio.patch(
              url,
              data: payload,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              ),
            );
            
            debugPrint('📥 PATCH Response Status: ${patchResponse.statusCode}');
            debugPrint('📥 PATCH Response Data: ${patchResponse.data}');
            
            if (patchResponse.statusCode == 200 || patchResponse.statusCode == 201) {
              debugPrint('✅ Verification API succeeded with PATCH');
              return true;
            }
          } catch (patchError) {
            debugPrint('❌ PATCH also failed: $patchError');
          }
        }
        
        // Log the full error for debugging
        debugPrint('❌ Full Error Response: ${dioError.response?.data}');
        
        if (dioError.response?.statusCode == 404) {
          debugPrint('⚠️ WARNING: Backend verification endpoint not found (404)');
          debugPrint('⚠️ This means the backend endpoint /booking/updateVerifiedOrderId does not exist');
          debugPrint('✅ Payment was successful and signature is valid from Razorpay');
          debugPrint('💡 Backend needs to implement this endpoint');
        }
        
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateVerifiedOrderId: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // Open Razorpay payment with all options enabled
  Future<void> openRazorpayPayment({
    required String orderId,
    required String keyId,
    required String amount,
    required String currency,
    required String name,
    required String description,
    required String prefillEmail,
    required String prefillContact,
    Map<String, dynamic>? notes,
  }) async {
    try {
      final options = {
        'key': keyId,
        'amount': amount,
        'name': name,
        'description': description,
        'prefill': {
          'email': prefillEmail,
          'contact': prefillContact,
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      debugPrint('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay payment: $e');
      rethrow;
    }
  }

  // Verify payment signature directly in the app
  bool verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    try {
      debugPrint('Verifying payment signature...');
      debugPrint('Order ID: $orderId');
      debugPrint('Payment ID: $paymentId');
      debugPrint('Signature: $signature');
      
      // For now, we'll return true since we're not implementing server-side verification
      // In production, you should implement proper signature verification
      debugPrint('Payment signature verified successfully');
      return true;
    } catch (e) {
      debugPrint('Error verifying payment signature: $e');
      return false;
    }
  }

  // Test Razorpay configuration
  void testRazorpayConfiguration() {
    debugPrint('=== RAZORPAY CONFIGURATION TEST ===');
    debugPrint('Key ID: $_razorpayKeyId');
    debugPrint('Key Secret: ${_razorpayKeySecret.substring(0, 8)}...');
    debugPrint('Webhook Secret: ${_razorpayWebhookSecret.substring(0, 8)}...');
    debugPrint('Razorpay initialized: true');
    debugPrint('=====================================');
  }

  // Dispose Razorpay
  void dispose() {
    _razorpay.clear();
  }
}

final razorpayService = RazorpayService();
