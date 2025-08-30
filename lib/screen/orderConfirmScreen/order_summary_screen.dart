import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maidxpress/controller/address/address_controller.dart';
import 'package:maidxpress/controller/booking/bookings_controller.dart';
import 'package:maidxpress/services/auth_service.dart';
import 'package:maidxpress/models/address_model.dart';
import 'package:maidxpress/models/booking_model.dart';
import 'package:maidxpress/models/service_model.dart';
import 'package:maidxpress/models/service_model.dart' as service_models;
import 'package:maidxpress/utils/appcolors/app_colors.dart';
// App specific imports
import 'package:maidxpress/widget/textwidget/text_widget.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'dart:developer' as developer;

class OrderSummaryScreen extends StatefulWidget {
  final service_models.Service service;
  final Map<String, String> selectedOptions;
  final Address? selectedAddress;
  final DateTime selectedDate;
  final String selectedTime;

  const OrderSummaryScreen({
    super.key,
    required this.service,
    required this.selectedOptions,
    this.selectedAddress,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final BookingsController _bookingsController = Get.find<BookingsController>();
  final AddressController _addressController = Get.find<AddressController>();
  bool _isLoading = false;
  double _totalAmount = 0;
  static const double _taxRate = 0.18;

  Address? _getSelectedAddress() {
    return widget.selectedAddress ??
        _addressController.addresses.firstWhereOrNull(
          (a) => a.label.toLowerCase() == 'home',
        ) ??
        _addressController.addresses.firstOrNull;
  }

  @override
  void initState() {
    super.initState();

    // Debug print to check received parameters
    print('OrderSummaryScreen received:');
    print('Service: ${widget.service.name}');
    print('Selected Options: ${widget.selectedOptions}');
    print('Selected Date: ${widget.selectedDate}');
    print('Selected Time: ${widget.selectedTime}');
    print('Selected Address: ${widget.selectedAddress?.address}');

    // Initialize and calculate total
    _checkAuthAndInitialize();
  }

  Future<void> _checkAuthAndInitialize() async {
    final authService = Get.find<AuthService>();
    final isLoggedIn = authService.currentUser != null;

    if (!isLoggedIn) {
      final returnRoute = Get.currentRoute;
      final args = Get.arguments;

      Get.offAllNamed(
        '/login',
        arguments: {
          'returnRoute': returnRoute,
          'args': args,
        },
      );
      return;
    }

    _calculateTotal();
  }

  void _calculateTotal() {
    try {
      double subtotal = 0.0;

      // Debug print service details
      print('Service details:');
      print('Service Name: ${widget.service.name}');
      print('Service Subservices: ${widget.service.subServices.length}');

      // Calculate subtotal from selected options
      for (var subService in widget.service.subServices) {
        if (widget.selectedOptions.containsKey(subService.key) &&
            widget.selectedOptions[subService.key]!.isNotEmpty) {
          final selectedValue = widget.selectedOptions[subService.key];
          print('Processing subservice: ${subService.key} = $selectedValue');

          try {
            final option = subService.options.firstWhere(
              (opt) => opt.value == selectedValue,
              orElse: () {
                print(
                    'No matching option found for $selectedValue in ${subService.key}');
                return subService.options.isNotEmpty
                    ? subService.options.first
                    : ServiceOption(
                        label: 'Default', value: 'default', price: 0.0);
              },
            );

            print('Found option: ${option.label} - Price: ${option.price}');
            subtotal += option.price;
          } catch (e) {
            print('Error processing option $selectedValue: $e');
          }
        }
      }

      // Calculate tax and total
      final tax = subtotal * _taxRate;
      _totalAmount = subtotal + tax;

      print('Calculated total:');
      print('Subtotal: $subtotal');
      print('Tax (${_taxRate * 100}%): $tax');
      print('Total: $_totalAmount');

      // Force UI update
      if (mounted) setState(() {});
    } catch (e) {
      print('Error in _calculateTotal: $e');
      _totalAmount = 0.0;
      if (mounted) setState(() {});
    }
  }

  Future<void> _createBooking() async {
    if (_isLoading) return;

    final authService = Get.find<AuthService>();
    if (authService.currentUser == null) {
      final returnRoute = Get.currentRoute;
      final currentArgs = Get.arguments;

      final prefs = GetStorage();
      await prefs.write('pending_booking', {
        'route': returnRoute,
        'args': currentArgs,
        'serviceId': widget.service.id,
        'serviceName': widget.service.name,
        'selectedOptions': widget.selectedOptions,
        'selectedDate': widget.selectedDate.toIso8601String(),
        'selectedTime': widget.selectedTime,
        'selectedAddressId': widget.selectedAddress?.id,
      });

      Get.offAllNamed(
        '/login',
        arguments: {
          'returnRoute': returnRoute,
          'args': currentArgs,
          'fromBooking': true,
        },
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Get and validate the selected address
      final address = _getSelectedAddress();
      if (address == null) {
        Get.snackbar('Error', 'Please add or select a valid address');
        return;
      }

      // Ensure address fields are non-empty
      final addressLabel = address.label.isNotEmpty ? address.label : 'Home';
      final addressText =
          address.address.isNotEmpty ? address.address : 'Default Address';
      final phoneNumber =
          address.phone.isNotEmpty ? address.phone : '9876543210';
      final pincode = address.pincode.isNotEmpty ? address.pincode : '400001';

      // Create the booking payload with converted fields
      final booking = Booking(
        title: '${widget.service.name} Booking',
        service: BookingService(
          id: widget.service.id,
          name: widget.service.name,
          tag: widget.service.tag ?? 'service',
          image: widget.service.image,
          include:
              widget.service.include.map((detail) => detail.toJson()).toList(),
          exclude:
              widget.service.exclude.map((detail) => detail.toJson()).toList(),
          subServices:
              widget.service.subServices.map((sub) => sub.toJson()).toList(),
          selectedSubServices: widget.service.subServices
              .where((s) => widget.selectedOptions.containsKey(s.key))
              .map((s) {
            final option = s.options.firstWhere(
              (o) => o.value == widget.selectedOptions[s.key],
              orElse: () => s.options.first,
            );
            return service_models.SubService(
              key: s.key,
              name: s.name,
              options: [option],
              isSelected: true,
            ).toJson();
          }).toList(),
          isFavorite: widget.service.isFavorite,
        ),
        selectTimeAndDate: SelectTimeAndDate(
          date: DateFormat('yyyy-MM-dd').format(widget.selectedDate),
          time: widget.selectedTime,
        ),
        location: Location(
          locationAddress: LocationAddress(
            name: addressLabel,
            address: addressText,
          ),
          phoneNumber: phoneNumber,
          pincode: pincode,
        ),
        transactionNumber: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        paymentStatus: 'pending',
        amount: _totalAmount,
      );

      developer.log('Booking Payload: ${booking.toJson()}');

      // Call the booking controller
      try {
        final success = await _bookingsController.createBooking(booking);

        if (success) {
          // Navigate to home screen after successful booking
          if (mounted) {
            Get.offAllNamed('/landing');
            Get.snackbar(
              'Success',
              'Booking created successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.green,
              colorText: AppColors.white,
              duration: const Duration(seconds: 3),
            );
          }
        } else {
          if (mounted) {
            Get.snackbar(
              'Error',
              'Failed to create booking',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.redColor,
              colorText: AppColors.white,
            );
          }
        }
      } catch (e) {
        developer.log('Error in booking creation: $e');
        if (mounted) {
          Get.snackbar(
            'Error',
            'An error occurred while creating the booking',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.redColor,
            colorText: AppColors.white,
          );
        }
      }
    } catch (e) {
      developer.log('Error creating booking: $e');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redColor,
        colorText: AppColors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatPrice(double amount) => '₹${amount.toStringAsFixed(2)}';

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          TextWidget(
            text: '$label: ',
            textSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          Expanded(
            child: TextWidget(
              text: value,
              textSize: 14,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: label,
            textSize: 14,
            color: AppColors.black,
          ),
          TextWidget(
            text: '₹${amount.toStringAsFixed(2)}',
            textSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main service details
              Row(
                children: [
                  if (widget.service.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.service.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.grey200,
                          child: const Icon(Icons.image_not_supported,
                              color: AppColors.black),
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: widget.service.name,
                          textSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        if (widget.service.tag != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: TextWidget(
                              text: widget.service.tag!,
                              textSize: 12,
                              color: AppColors.grey700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              // Selected options
              if (widget.selectedOptions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Selected Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildSelectedOptions(),
              ],
            ],
          ),
        ),
      );

  Widget _buildAddressSection() {
    final address = widget.selectedAddress ??
        _addressController.addresses.firstWhereOrNull(
          (a) => a.label.toLowerCase() == 'home',
        ) ??
        _addressController.addresses.firstOrNull;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: address == null
            ? const TextWidget(
                text: 'No address selected',
                textSize: 13,
                color: AppColors.redColor,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Label',
                      address.label.isNotEmpty ? address.label : 'Home'),
                  _buildInfoRow('Phone',
                      address.phone.isNotEmpty ? address.phone : 'N/A'),
                  _buildInfoRow('Address',
                      address.address.isNotEmpty ? address.address : 'N/A'),
                ],
              ),
      ),
    );
  }

  Widget _buildDateTimeSection() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Date', _formatDate(widget.selectedDate)),
              _buildInfoRow('Time', widget.selectedTime),
            ],
          ),
        ),
      );

  List<Widget> _buildSelectedOptions() {
    final List<Widget> options = [];

    // Filter out unselected or empty options
    final selectedItems = widget.selectedOptions.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    for (var entry in selectedItems) {
      try {
        final subService = widget.service.subServices.firstWhere(
          (s) => s.key == entry.key,
          orElse: () => SubService(
            key: entry.key,
            name: entry.key,
            options: [
              ServiceOption(
                label: entry.value,
                value: entry.value,
                price: 0.0,
              )
            ],
          ),
        );

        final option = subService.options.firstWhere(
          (opt) => opt.value == entry.value,
          orElse: () => ServiceOption(
            label: entry.value,
            value: entry.value,
            price: 0.0,
          ),
        );

        options.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${subService.name}: ${option.label}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${option.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        print('Error building option ${entry.key}: $e');
      }
    }

    return options;
  }

  List<Widget> _buildPriceRows() {
    final subtotal = _totalAmount / (1 + _taxRate);
    final tax = _totalAmount - subtotal;
    return [
      ..._buildSelectedOptions(),
      _buildPriceRow('Subtotal', subtotal),
      _buildPriceRow('Tax (18% GST)', tax),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: 'Total Amount',
              textSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            TextWidget(
              text: _formatPrice(_totalAmount),
              textSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelperAppBar.appbarHelper(
        title: 'Order Summary',
        bgColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceDetails(),
                  const SizedBox(height: 16),
                  _buildAddressSection(),
                  const SizedBox(height: 16),
                  _buildDateTimeSection(),
                  const SizedBox(height: 24),
                  ..._buildPriceRows(),
                  const SizedBox(height: 24),
                  AppButton.primaryButton(
                    onButtonPressed: _isLoading ? null : _createBooking,
                    title: 'Confirm Booking',
                    height: 50,
                    borderRadius: 10,
                    isLoading: _isLoading,
                    textColor: Colors.white,
                    fontSize: 16,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
    );
  }
}
