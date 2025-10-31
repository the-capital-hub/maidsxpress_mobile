import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/controller/booking/bookings_controller.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/models/booking_model.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';

import '../../widget/textwidget/text_widget.dart';

class EReceiptScreen extends StatefulWidget {
  const EReceiptScreen({super.key});

  @override
  State<EReceiptScreen> createState() => _EReceiptScreenState();
}

class _EReceiptScreenState extends State<EReceiptScreen> {
  final BookingsController _controller = Get.find<BookingsController>();
  Booking? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  Future<void> _fetchBookingData() async {
    // First try to get booking object directly from arguments
    final bookingArg = Get.arguments?['booking'];
    if (bookingArg != null) {
      print('EReceipt: Booking provided directly from arguments');
      
      // Convert to Booking model if it's a Map
      Booking? booking;
      if (bookingArg is Booking) {
        booking = bookingArg;
        print('EReceipt: Booking is already Booking type');
      } else if (bookingArg is Map<String, dynamic>) {
        booking = Booking.fromJson(bookingArg);
        print('EReceipt: Booking converted from Map to Booking type');
      }
      
      if (booking != null) {
        print('EReceipt: Booking ID: ${booking.id}');
        print('EReceipt: Booking paymentStatus: ${booking.paymentStatus}');
        print('EReceipt: Booking transactionNumber: ${booking.transactionNumber}');
        print('EReceipt: Booking orderId: ${booking.orderId}');
        print('EReceipt: Booking orders count: ${booking.orders.length}');
        if (booking.orders.isNotEmpty) {
          print('EReceipt: First order orderId: ${booking.orders.first.orderId}');
          print('EReceipt: First order paymentStatus: ${booking.orders.first.paymentStatus}');
          print('EReceipt: First order transactionNumber: ${booking.orders.first.transactionNumber}');
        }
      }
      
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
      
      print('EReceipt: Booking loaded directly: ${booking?.id}');
      return;
    }
    
    // Otherwise fetch by ID
    final bookingId = (Get.arguments?['bookingId'] ?? '').toString();
    print('EReceipt: Fetching booking with ID: $bookingId');
    
    if (bookingId.isEmpty) {
      print('EReceipt: No booking ID or booking object provided');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final booking = await _controller.getBooking(bookingId);
      print('EReceipt: Booking fetched: ${booking != null ? booking.id : 'null'}');
      
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
      
      if (booking == null) {
        print('EReceipt: Booking not found for ID: $bookingId');
        print('EReceipt: Local bookings count: ${_controller.bookings.length}');
        if (_controller.bookings.isNotEmpty) {
          print('EReceipt: First booking ID in list: ${_controller.bookings.first.id}');
        }
      }
    } catch (e, stackTrace) {
      print('EReceipt: Error fetching booking: $e');
      print('EReceipt: Stack trace: $stackTrace');
      setState(() {
        _booking = null;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy | hh:mm a').format(date);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('MMM dd, yyyy, hh:mm a').format(dateTime);
  }

  String _formatCurrency(double amount) {
    return 'Rs ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "E-Receipt"),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _booking == null
                ? const Center(
                    child: TextWidget(
                      text: "Booking not found",
                      textSize: 16,
                    ),
                  )
                : Column(
                    children: [
                      // Receipt icon placeholder (QR functionality removed)
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.receipt_long,
                          size: 120,
                          color: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Booking Date - Dynamic
                              _buildRowTile(
                                "Booking Date",
                                _booking!.createdAt != null
                                    ? _formatDate(_booking!.createdAt!)
                                    : 'N/A',
                              ),
                              
                              // Workers - Not available in current model, keeping placeholder
                              _buildRowTile("Workers", "To be assigned"),
                              
                              // Confirmed Date & Time - Dynamic
                              _buildRowTile(
                                "Confirmed Date & Time",
                                "${DateFormat('MMM dd, yyyy').format(_booking!.selectTimeAndDate.date)} | ${_booking!.selectTimeAndDate.time}",
                              ),
                              
                              const Divider(),
                              
                              // Service Breakdown - Dynamic
                              ..._buildServiceBreakdown(),
                              
                              const Divider(),
                              
                              // Payment Method - Dynamic
                              _buildRowTile(
                                "Payment Methods",
                                _getPaymentMethodLabel(),
                              ),
                              
                              // Payment Date - Dynamic
                              _buildRowTile(
                                "Date",
                                _formatDateTime(_booking!.updatedAt),
                              ),
                              
                              // Transaction ID - Dynamic (use orderId if available, otherwise transactionNumber)
                              _buildRowTile(
                                "Transaction ID",
                                _booking!.orderId ?? _booking!.transactionNumber,
                                trailingIcon: Icons.copy,
                                onCopy: () {
                                  Get.snackbar(
                                    'Copied',
                                    'Transaction ID copied to clipboard',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AppButton.primaryButton(
          onButtonPressed: () async {
            // Use orderId from booking if available, otherwise fallback to booking id
            // If booking has orders array, use the first order's orderId
            String? receiptId;
            
            if (_booking != null) {
              // First try to get orderId from the booking object directly
              if (_booking!.orderId != null && _booking!.orderId!.isNotEmpty) {
                receiptId = _booking!.orderId;
              } 
              // If booking has orders array, get the first order's orderId
              else if (_booking!.orders.isNotEmpty && _booking!.orders[0].orderId.isNotEmpty) {
                receiptId = _booking!.orders[0].orderId;
              }
              // Fallback to booking id
              else if (_booking!.id != null && _booking!.id!.isNotEmpty) {
                receiptId = _booking!.id;
              }
            }
            
            // Try to get from arguments as well
            if (receiptId == null || receiptId.isEmpty) {
              receiptId = Get.arguments?['orderId']?.toString() ?? Get.arguments?['bookingId']?.toString();
            }
            
            if (receiptId == null || receiptId.isEmpty) {
              HelperSnackBar.error('No receipt ID available');
              return;
            }
            
            print('EReceipt: Downloading receipt for ID: $receiptId');
            final ctrl = Get.find<BookingsController>();
            await ctrl.downloadReceipt(receiptId);
          },
          title: "Download E-Receipt",
        ),
      ),
    );
  }

  String _getPaymentMethodLabel() {
    // Check if this is a Razorpay payment (orderId exists or payment is paid)
    if (_booking!.orderId != null || _booking!.paymentStatus == 'paid') {
      return 'Online Payment (UPI/Card)';
    } else if (_booking!.paymentStatus == 'pending') {
      // Check if transaction starts with TXN (not RAZORPAY_TXN) and not PAY_LATER
      final isPayLater = _booking!.transactionNumber == 'PAY_LATER';
      return isPayLater ? 'Pay Later' : 'Online Payment (Pending)';
    }
    return 'Online Payment';
  }

  List<Widget> _buildServiceBreakdown() {
    final List<Widget> items = [];
    
    // Add service name as title
    if (_booking!.service.name.isNotEmpty) {
      items.add(
        _buildRowTile("Service", _booking!.service.name),
      );
    }

    // Add selected sub-services with prices
    if (_booking!.service.selectedSubServices.isNotEmpty) {
      for (var subService in _booking!.service.selectedSubServices) {
        if (subService.selectedOption != null) {
          items.add(
            _buildRowTile(
              subService.name,
              _formatCurrency(subService.selectedOption!.price),
            ),
          );
        }
      }
    }

    // Add total amount
    items.add(
      _buildRowTile("Total", _formatCurrency(_booking!.amount)),
    );   

    return items;
  }

  Widget _buildRowTile(String label, String value,
      {IconData? trailingIcon, VoidCallback? onCopy}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F7F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextWidget(
                text: label,
                textSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onCopy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextWidget(
                      text: value,
                      textSize: 13,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(trailingIcon, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
