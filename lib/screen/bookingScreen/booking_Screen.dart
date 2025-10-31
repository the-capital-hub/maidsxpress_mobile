import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maidxpress/controller/booking/bookings_controller.dart';
import 'package:maidxpress/models/booking_model.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

enum ServiceTab { upcoming, completed, cancelled }

class _BookingScreenState extends State<BookingScreen> {
  final BookingsController _bookingsController = Get.find<BookingsController>();
  final Map<int, bool> _isExpanded = {};
  ServiceTab selectedTab = ServiceTab.upcoming;
  final Map<ServiceTab, List<Booking>> _filteredBookings = {
    ServiceTab.upcoming: [],
    ServiceTab.completed: [],
    ServiceTab.cancelled: [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await _bookingsController.getAllBookings();

      if (!mounted) return;

      setState(() {
        _filteredBookings[ServiceTab.upcoming] = _bookingsController.bookings
            .where((b) => b.progressStatus?.toLowerCase() == 'upcoming')
            .toList();
        _filteredBookings[ServiceTab.completed] = _bookingsController.bookings
            .where((b) => b.progressStatus?.toLowerCase() == 'completed')
            .toList();
        _filteredBookings[ServiceTab.cancelled] = _bookingsController.bookings
            .where((b) => b.bookingStatus?.toLowerCase() == 'cancelled')
            .toList();
      });
    } catch (e) {
      if (mounted) {
        HelperSnackBar.error('Failed to load bookings: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime? date, String time) {
    if (date == null) return 'N/A';
    final dateFormat = DateFormat('MMM dd, yyyy');
    return '${dateFormat.format(date)} | $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Bookings", hideBack: true),
      body: Column(
        children: [
          FlipInX(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.white,
              ),
              child: CustomTabBar(
                selectedTab: selectedTab,
                onTabChange: (tab) {
                  setState(() {
                    selectedTab = tab;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : SlideInUp(
                    child: _buildBookingsList(selectedTab),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(ServiceTab tab) {
    final bookings = _filteredBookings[tab] ?? [];

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${tab.name} bookings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final isExpanded = _isExpanded[index] ?? false;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 1,
            color: AppColors.white,
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          booking.service.image?.isNotEmpty ?? false
                              ? booking.service.image ?? ''
                              : '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_work,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 4),
                                TextWidget(
                                  text: 'MaidsXpress',
                                  textSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: booking.service.name,
                              fontWeight: FontWeight.w600,
                              textSize: 15,
                            ),
                            if (booking
                                .service.selectedSubServices.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              ...booking.service.selectedSubServices
                                  .map((subService) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${subService.name} (${subService.selectedOption?.label ?? 'Not selected'})',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                            const SizedBox(height: 4),
                            TextWidget(
                              text:
                                  'Booking #${booking.id?.substring(0, 8) ?? ''}',
                              textSize: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(booking.bookingStatus ?? '')
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextWidget(
                                text:
                                    _formatStatus(booking.bookingStatus ?? ''),
                                textSize: 12,
                                color: _getStatusColor(
                                    booking.bookingStatus ?? ''),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: AppColors.black12,
                ),
                if (isExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TextWidget(
                              text: "Date & Time",
                              color: Colors.grey,
                              textSize: 12,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: TextWidget(
                                text: _formatDateTime(
                                  booking.selectTimeAndDate.date,
                                  booking.selectTimeAndDate.time,
                                ),
                                fontWeight: FontWeight.w500,
                                textSize: 13,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TextWidget(
                              text: "Location",
                              color: Colors.grey,
                              textSize: 12,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: TextWidget(
                                text:
                                    booking.location.locationAddress.address,
                                fontWeight: FontWeight.w500,
                                textSize: 13,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (booking.service.selectedSubServices.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const TextWidget(
                            text: 'Services',
                            fontWeight: FontWeight.w500,
                            textSize: 14,
                          ),
                          const SizedBox(height: 8),
                          ...booking.service.selectedSubServices.map((service) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(color: Colors.grey)),
                                  Flexible(
                                    child: TextWidget(
                                      text: service.name,
                                      textSize: 13,
                                      color: Colors.grey[700]!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.outlineButton(
                                onButtonPressed: () async {
                                  // Use orderId if available, otherwise booking id
                                  final receiptId = booking.orderId ?? booking.id ?? '';
                                  if (receiptId.isEmpty) {
                                    HelperSnackBar.error('Invalid booking');
                                    return;
                                  }
                                  await _bookingsController.downloadReceipt(receiptId);
                                },
                                title: 'View Receipt',
                                height: 45,
                                borderColor: AppColors.primary,
                              ),
                            ),
                            if (booking.bookingStatus == 'booked' &&
                                booking.progressStatus == 'upcoming') ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppButton.primaryButton(
                                  onButtonPressed: () {
                                    _showCancelDialog(booking.id!);
                                  },
                                  title: 'Cancel',
                                  height: 45,
                                  borderRadius: 25,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded[index] = !isExpanded;
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'booked':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return 'Upcoming';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  void _showCancelDialog(String bookingId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _bookingsController.cancelBooking(bookingId);
                await _loadBookings();
                HelperSnackBar.success('Booking cancelled successfully');
              } catch (e) {
                HelperSnackBar.error('Failed to cancel booking');
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class CustomTabBar extends StatelessWidget {
  final ServiceTab selectedTab;
  final Function(ServiceTab) onTabChange;

  const CustomTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: ServiceTab.values.map((tab) {
        final isSelected = tab == selectedTab;
        return Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 80,
              maxWidth: 120,
            ),
            child: GestureDetector(
              onTap: () => onTabChange(tab),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: isSelected
                    ? const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF0CA789),
                            width: 1.5,
                          ),
                        ),
                      )
                    : null,
                child: TextWidget(
                  text: StringExtension(tab.name).capitalize(),
                  textSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
