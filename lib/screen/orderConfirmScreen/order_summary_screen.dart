import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maidxpress/models/address_model.dart';
import 'package:maidxpress/models/service_model.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';
import '../selectAreaScreen/select_area_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Service service;
  final Map<String, dynamic> selectedOptions;
  final DateTime selectedDate;
  final String selectedTime;
  final Address selectedAddress;
  final String? genderPreference;

  const OrderSummaryScreen({
    super.key,
    required this.service,
    required this.selectedOptions,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedAddress,
    this.genderPreference,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final Map<String, int> quantities = {};

  @override
  void initState() {
    super.initState();
    // initialize all selected items with quantity 1
    widget.selectedOptions.forEach((key, value) {
      quantities[key] = 1;
    });
  }

  double _calculateTotal() {
    double subtotal = 0.0;
    widget.selectedOptions.forEach((key, value) {
      final price = (value['price'] is double)
          ? value['price'] as double
          : double.tryParse(value['price']?.toString() ?? '0') ?? 0.0;
      subtotal += (price * (quantities[key] ?? 1));
    });
    final tax = subtotal * 0.18; // 18% GST
    return subtotal + tax;
  }

  Map<String, dynamic>? _buildBookingDraft() {
    try {
      final address = widget.selectedAddress;

      // Validate and use phoneNumber
      final phoneNumber = address.phone.isNotEmpty ? address.phone : null;
      if (phoneNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Phone number is required for the selected address')),
        );
        return null;
      }

      final List<Map<String, dynamic>> selectedSubServices = [];
      double subtotal = 0.0;

      widget.selectedOptions.forEach((key, value) {
        if (value.isNotEmpty) {
          final price = (value['price'] is double)
              ? value['price'] as double
              : double.tryParse(value['price']?.toString() ?? '0') ?? 0.0;

          // Get the subservice name from the service's subservices list
          final subService = widget.service.subServices.firstWhere(
            (sub) => sub.key == key,
            orElse: () => SubService(
              key: key,
              name: value['label'] ?? key,
              options: [],
            ),
          );

          selectedSubServices.add({
            'key': key,
            'name': subService.name, // Using the actual subservice name
            'selectedOption': {
              'label': value['label'] ?? '',
              'value': value['value'] ?? '',
              'price': price,
            }
          });
          subtotal += price * (quantities[key] ?? 1);
        }
      });

      final taxRate = 0.18; // 18% tax
      final tax = subtotal * taxRate;
      final totalAmount = subtotal + tax;

      final bookingDraft = {
        'title': '${widget.service.name} Booking',
        'service': {
          'name': widget.service.name,
          'tag': widget.service.tag,
          'selectedSubServices': selectedSubServices,
        },
        'selectTimeAndDate': {
          'date': DateFormat('yyyy-MM-dd').format(widget.selectedDate),
          'time': widget.selectedTime,
          'gender': widget.genderPreference ?? 'Any',
        },
        'location': {
          'phoneNumber': phoneNumber,
          'locationAddress': {
            'name': address.label,
            'address': address.address,
          }
        },
        'transactionNumber': 'TXN${DateTime.now().millisecondsSinceEpoch}',
        'paymentStatus': 'pending',
        'amount': totalAmount,
      };

      return bookingDraft;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error preparing booking details')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.black),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const TextWidget(
          text: "Order Summary",
          textSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceCard(),
            const SizedBox(height: 20),
            _buildSelectedItems(),
            _buildSelectMoreButton(),
            const SizedBox(height: 20),
            _buildBookingSchedule(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildServiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.service.image.isNotEmpty
                  ? widget.service.image
                  : "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=150&h=150&fit=crop",
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag + Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextWidget(
                        text: widget.service.tag.isNotEmpty
                            ? widget.service.tag
                            : "Home Cleaning",
                        textSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    const TextWidget(
                      text: "4.4 (120 Users)",
                      textSize: 12,
                      color: AppColors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Name
                TextWidget(
                  text: widget.service.name,
                  textSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                const SizedBox(height: 8),

                // Location + Duration
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextWidget(
                        text: widget.selectedAddress.address,
                        textSize: 10,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    const TextWidget(
                      text: "3h 40 Mins",
                      textSize: 10,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: "Clothes Selected",
          textSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        const SizedBox(height: 12),
        ...widget.selectedOptions.entries.map((entry) {
          final key = entry.key;
          final value = entry.value;
          final qty = quantities[key] ?? 1;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: value['label'] ?? key,
                  textSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                Row(
                  children: [
                    _quantityButton(Icons.remove, () {
                      if (qty > 1) {
                        setState(() {
                          quantities[key] = qty - 1;
                        });
                      }
                    }),
                    const SizedBox(width: 12),
                    TextWidget(
                      text: qty.toString(),
                      textSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    const SizedBox(width: 12),
                    _quantityButton(Icons.add, () {
                      setState(() {
                        quantities[key] = qty + 1;
                      });
                    }),
                  ],
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: icon == Icons.remove
            ? Colors.black26
            : AppColors.primary, // Grey for minus, primary for add
        borderRadius: BorderRadius.circular(16), // Circular button
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 18,
          color: Colors.white, // White icon color
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildBookingSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScheduleCard(
          "Booking Date",
          "${DateFormat('MMM dd, yyyy').format(widget.selectedDate)} | ${widget.selectedTime}",
        ),
        const SizedBox(height: 8),
        _buildScheduleCard(
          "Confirmed Date & Time",
          "${DateFormat('MMM dd, yyyy').format(widget.selectedDate.add(const Duration(days: 1)))} | ${widget.selectedTime}",
        ),
      ],
    );
  }

  Widget _buildScheduleCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextWidget(
              text: title,
              textSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          TextWidget(
            text: value,
            textSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectMoreButton() {
    return Center(
      child: AppButton.primaryButton(
        onButtonPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SelectAreaScreen(service: widget.service)));
        },
        title: "Select More",
        height: 40,
        width: 100,
        borderRadius: 22,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "₹${_calculateTotal().toStringAsFixed(2)}",
                  textSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                const SizedBox(height: 4),
                const TextWidget(
                  text: "View Detailed Bill",
                  textSize: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: AppButton.primaryButton(
              onButtonPressed: () {
                final draft = _buildBookingDraft();
                if (draft != null) {
                  Get.toNamed('/paymentOptions', arguments: {
                    'bookingDraft': draft,
                    'totalAmount': _calculateTotal(),
                    'genderPreference': widget.genderPreference,
                  });
                }
              },
              title: "Proceed to Pay",
              height: 48,
              borderRadius: 25,
            ),
          ),
        ],
      ),
    );
  }
}
