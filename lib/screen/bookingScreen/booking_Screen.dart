import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';

import '../../widget/textwidget/text_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

enum ServiceTab { upcoming, completed, cancelled }

class _BookingScreenState extends State<BookingScreen> {
  ServiceTab selectedTab = ServiceTab.upcoming;
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
              decoration: const BoxDecoration(color: AppColors.white, boxShadow: [
                BoxShadow(
                    color: AppColors.black12, blurRadius:4, offset: const Offset(2,2))
              ]),
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
          sizedTextfield,
          Expanded(
            child: SlideInUp(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final expanded = _isExpanded[index];
            
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
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: item.title,
                                      fontWeight: FontWeight.w600,
                                      textSize: 15,
                                    ),
                                    const SizedBox(height: 4),
                                    TextWidget(
                                      text: item.subtitle,
                                      textSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.help_outline,
                                  size: 20, color: AppColors.primary),
                            ],
                          ),
                        ),
                        const Divider(
                          color: AppColors.black12,
                        ),
                        if (expanded) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const TextWidget(
                                      text: "Date & Time",
                                      color: Colors.grey,
                                      textSize: 12,
                                    ),
                                    const SizedBox(height: 4),
                                    TextWidget(
                                      text: item.dateTime,
                                      fontWeight: FontWeight.w500,
                                      textSize: 13,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const TextWidget(
                                      text: "Location",
                                      color: Colors.grey,
                                      textSize: 12,
                                    ),
                                    const SizedBox(height: 4),
                                    TextWidget(
                                      text: item.location,
                                      fontWeight: FontWeight.w500,
                                      textSize: 13,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AppButton.primaryButton(
                                    onButtonPressed: () {},
                                    height: 45,
                                    title: "View E-Receipt")
                              ],
                            ),
                          ),
                        ],
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isExpanded[index] = !_isExpanded[index];
                            });
                          },
                          child: Icon(
                            expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  List<bool> _isExpanded = List.generate(3, (index) => index == 0);

  final List<_ReceiptModel> items = [
    const _ReceiptModel(
      image:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfPaLRTIaPsY_Q4lXjrkvTyE5ilrBv-DpPYA&s',
      title: 'CleanXpress',
      subtitle: 'Maryland Winkles',
      status: 'Completed',
      dateTime: 'June 12, 2025 | 13:00 - 15:00',
      location: 'Silkboard, Bengaluru',
    ),
    const _ReceiptModel(
      image:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfPaLRTIaPsY_Q4lXjrkvTyE5ilrBv-DpPYA&s',
      title: 'CleanXpress',
      subtitle: 'Maryland Winkles',
      status: 'Completed',
      dateTime: 'June 10, 2025 | 11:00 - 13:00',
      location: 'HSR Layout, Bengaluru',
    ),
    const _ReceiptModel(
      image:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfPaLRTIaPsY_Q4lXjrkvTyE5ilrBv-DpPYA&s',
      title: 'CleanXpress',
      subtitle: 'Maryland Winkles',
      status: 'Completed',
      dateTime: 'June 08, 2025 | 09:00 - 11:00',
      location: 'Indiranagar, Bengaluru',
    ),
  ];
}

class _ReceiptModel {
  final String image;
  final String title;
  final String subtitle;
  final String status;
  final String dateTime;
  final String location;

  const _ReceiptModel({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.dateTime,
    required this.location,
  });
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ServiceTab.values.map((tab) {
        final isSelected = tab == selectedTab;
        return GestureDetector(
          onTap: () => onTabChange(tab),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: isSelected
                ? const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF0CA789),
                        width: 1.5,
                      ),
                    ))
                : null,
            child: TextWidget(
              text: tab.name.capitalize(),
              textSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }
}

extension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
