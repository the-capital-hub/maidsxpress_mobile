import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/service/service_controller.dart';
import 'package:maidxpress/screen/homeScreen/serviceCard/service_card_widget.dart';
import 'package:maidxpress/screen/homeScreen/serviceCard/shimmer_service_card.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ServicesController _servicesController = Get.find<ServicesController>();
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch services if not already loaded
    if (_servicesController.services.isEmpty) {
      _servicesController.getAllServices();
    }
  }

  // Mock data for bookings with dots
  final Map<String, List<Color>> bookingDots = {
    "2025-08-02": [AppColors.primary], // Single dot
    "2025-08-06": [AppColors.primary],
    "2025-08-08": [Colors.purple],
    "2025-08-10": [Colors.blue, Colors.orange, Colors.red],
    "2025-08-13": [Colors.blue, Colors.orange],
    "2025-08-15": [Colors.green, Colors.purple],
    "2025-08-17": [AppColors.primary],
    "2025-08-20": [Colors.blue, Colors.orange],
    "2025-08-22": [Colors.blue, Colors.orange, Colors.red],
    "2025-08-23": [Colors.purple],
    "2025-08-29": [Colors.blue, Colors.orange, Colors.red],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HelperAppBar.appbarHelper(
        title: "Calendar",
        hideBack: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Header
              _buildCalendarHeader(),

              // Calendar Grid
              _buildCalendarGrid(),

              const SizedBox(height: 20),

              // Services Booking Section
              TextWidget(
                  text: "Services Booking (3)",
                  textSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black),

              const SizedBox(height: 12),
              Obx(() {
                if (_servicesController.isLoading.value) {
                  return ListView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: ShimmerServiceCard(),
                    ),
                  );
                }

                final services = _servicesController.services;
                if (services.isEmpty) {
                  return const Center(
                    child: Text('No services available'),
                  );
                }

                return ListView.builder(
                  itemCount: services.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ServiceCardWidget(service: services[index]),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              currentMonth =
                  DateTime(currentMonth.year, currentMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        Column(
          children: [
            TextWidget(
              text: _getMonthName(currentMonth.month),
              textSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            TextWidget(
              text: currentMonth.year.toString(),
              textSize: 14,
              color: Colors.grey,
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            setState(() {
              currentMonth =
                  DateTime(currentMonth.year, currentMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Days of week header
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: TextWidget(
                          text: day,
                          textSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 10),

          // Calendar dates
          _buildCalendarDates(),
        ],
      ),
    );
  }

  Widget _buildCalendarDates() {
    List<Widget> weeks = [];
    DateTime firstDayOfMonth =
        DateTime(currentMonth.year, currentMonth.month, 1);

    // Get first Monday of the calendar view
    DateTime startDate =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));

    for (int week = 0; week < 6; week++) {
      List<Widget> days = [];

      for (int day = 0; day < 7; day++) {
        DateTime currentDate = startDate.add(Duration(days: week * 7 + day));
        bool isCurrentMonth = currentDate.month == currentMonth.month;
        bool isToday = _isSameDate(currentDate, DateTime.now());
        bool isSelected = _isSameDate(currentDate, selectedDate);

        String key =
            "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

        days.add(
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = currentDate;
                });
              },
              child: _buildDateCell(
                currentDate.day,
                isCurrentMonth,
                isToday,
                isSelected,
                bookingDots[key] ?? [],
              ),
            ),
          ),
        );
      }

      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: days),
        ),
      );
    }

    return Column(children: weeks);
  }

  Widget _buildDateCell(int day, bool isCurrentMonth, bool isToday,
      bool isSelected, List<Color> dots) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;

    if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = Colors.grey.shade300;
      textColor = Colors.black;
    } else if (!isCurrentMonth) {
      textColor = Colors.grey;
    }

    return SizedBox(
      height: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: TextWidget(
                text: day.toString(),
                textSize: 15,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (dots.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dots
                  .take(3)
                  .map((color) => Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
