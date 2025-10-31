import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maidxpress/screen/addressScreen/address_selection_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import '../../models/service_model.dart';
import '../../widget/buttons/button.dart';
import '../../widget/textwidget/text_widget.dart';

class PickupAndTimeScreen extends StatefulWidget {
  final Service service;
  final Map<String, Map<String, dynamic>> selectedOptions;

  const PickupAndTimeScreen({
    super.key,
    required this.service,
    required this.selectedOptions,
  });

  @override
  State<PickupAndTimeScreen> createState() => _PickupAndTimeScreenState();
}

class _PickupAndTimeScreenState extends State<PickupAndTimeScreen> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = 1;
  int selectedGenderIndex = 1;
  final instructionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String currentMonth = "";

  List<String> dates = [];
  List<int> days = [];
  List<DateTime> fullDates = [];
  List<String> monthNames = [];
  Map<int, String> monthMap = {};

  final List<String> times = [
    "08:00 am",
    "09:00 am",
    "09:30 am",
    "10:30 am",
    "11:00 am",
    "12:00 pm",
    "01:30 pm",
    "04:00 pm",
    "05:00 pm",
    "05:30 pm",
    "06:00 pm",
    "07:00 pm"
  ];

  // Ensure this order matches the UI and logic (index 0: Male, index 1: Female)
  final List<String> genders = ["Male", "Female"];

  double _calculateTotalPrice() {
    try {
      double total = 0.0;
      for (final entry in widget.selectedOptions.entries) {
        if (entry.value.isNotEmpty && entry.value['price'] != null) {
          total += entry.value['price'].toDouble();
        }
      }
      return total > 0 ? total : 0.0;
    } catch (e) {
      print('Error in _calculateTotalPrice: $e');
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    print('Received in PickupAndTimeScreen: ${widget.selectedOptions}');
    _generateDates();
    selectedDateIndex = 0;
    currentMonth = monthMap[0] ?? "";

    // Add scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final scrollOffset = _scrollController.offset;
      final itemWidth = 68.0; // 60 width + 8 margin
      final visibleIndex = (scrollOffset / itemWidth).round();

      if (visibleIndex >= 0 && visibleIndex < dates.length) {
        final month = monthMap[visibleIndex];
        if (month != null && month != currentMonth) {
          setState(() {
            currentMonth = month;
          });
        }
      }
    }
  }

  void _generateDates() {
    final now = DateTime.now();
    final minBookingDate =
        now.add(const Duration(days: 3)); // Minimum 3 days ahead

    dates.clear();
    days.clear();
    fullDates.clear();
    monthNames.clear();
    monthMap.clear();

    // Generate dates for next 6 months (180 days)
    for (int i = 0; i < 180; i++) {
      DateTime date = minBookingDate.add(Duration(days: i));
      dates.add(DateFormat('EEE').format(date));
      days.add(int.parse(DateFormat('d').format(date)));
      fullDates.add(date);

      // Store month information
      String monthName = DateFormat('MMM yyyy').format(date);
      monthNames.add(monthName);
      monthMap[i] = monthName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image section with overlay
          Container(
            width: double.infinity,
            child: Stack(
              children: [
                // Image with proper constraints
                Container(
                  height: 270,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      widget.service.image.isNotEmpty
                          ? widget.service.image
                          : "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=260&fit=crop",
                      fit: BoxFit.contain, // Maintain aspect ratio
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.grey200,
                          child: const Icon(
                            Icons.cleaning_services,
                            size: 60,
                            color: AppColors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Semi-transparent overlay for text visibility
                Container(
                  height: 270,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.4), // Adjustable opacity
                ),
                // Back Button
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: AppColors.black12,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Text Information
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: widget.service.name,
                        textSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 4),
                      if (widget.selectedOptions.isNotEmpty) ...[
                        TextWidget(
                          text: widget.selectedOptions.entries
                              .where((entry) => entry.value.isNotEmpty)
                              .map((entry) =>
                                  '${entry.key}: ${entry.value['label']}')
                              .join(', '),
                          textSize: 12,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 4),
                      ],
                      TextWidget(
                        text:
                            'Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}',
                        textSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const TextWidget(
                        text: "Start Date",
                        textSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      const Spacer(),
                      TextWidget(
                        text: currentMonth.isNotEmpty
                            ? currentMonth
                            : monthMap[0] ?? "",
                        textSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FlipInX(
                    child: SizedBox(
                      height: 70,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: dates.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          bool isSelected = index == selectedDateIndex;
                          final currentDate = fullDates[index];
                          final now = DateTime.now();
                          final isPastDate = currentDate
                              .isBefore(now.add(const Duration(days: 3)));

                          return GestureDetector(
                            onTap: isPastDate
                                ? null
                                : () => setState(() {
                                      selectedDateIndex = index;
                                    }),
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isPastDate
                                    ? AppColors.grey100
                                    : isSelected
                                        ? AppColors.primary
                                        : AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: isPastDate
                                    ? Border.all(
                                        color: AppColors.grey300, width: 1)
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: TextWidget(
                                      text: dates[index],
                                      textSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isPastDate
                                          ? AppColors.grey400
                                          : isSelected
                                              ? AppColors.white
                                              : AppColors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Flexible(
                                    child: TextWidget(
                                      text: days[index].toString(),
                                      textSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isPastDate
                                          ? AppColors.grey400
                                          : isSelected
                                              ? AppColors.white
                                              : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextWidget(
                    text: "Time",
                    textSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: times.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) {
                      bool isSelected = index == selectedTimeIndex;
                      return FadeIn(
                        delay: Duration(milliseconds: 50 * index),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedTimeIndex = index;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextWidget(
                                text: times[index],
                                textSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const TextWidget(
                    text: "Select the Gender",
                    textSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  FadeInLeft(
                    child: Row(
                      children: List.generate(genders.length, (index) {
                        bool isSelected = selectedGenderIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGenderIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextWidget(
                              text: genders[index],
                              textSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextWidget(
                    text: "Cleaning Instructions",
                    textSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  MyCustomTextField.textField(
                      hintText: "Type here ...",
                      controller: instructionController)
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AppButton.primaryButton(
          onButtonPressed: () {
            final selectedDate = fullDates.isNotEmpty
                ? fullDates[selectedDateIndex]
                : DateTime.now();
            final selectedTime = times[selectedTimeIndex];
            final totalPrice = _calculateTotalPrice();
            print(
                'Passing to AddressSelectionScreen: ${widget.selectedOptions}');
            // Map index to gender (0: Male, 1: Female)
            final selectedGender = selectedGenderIndex == 0 ? 'Male' : 'Female';
            print('Selected gender: $selectedGender');
            Get.to(
              () => const AddressSelectionScreen(),
              arguments: {
                'service': widget.service,
                'selectedOptions': widget.selectedOptions,
                'selectedDate': selectedDate,
                'selectedTime': selectedTime,
                'totalPrice': totalPrice,
                'genderPreference': selectedGender,
              },
            );
          },
          title: 'Continue - ₹${_calculateTotalPrice().toStringAsFixed(2)}',
          height: 48,
          borderRadius: 25,
        ),
      ),
    );
  }
}
