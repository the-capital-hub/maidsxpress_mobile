import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import '../../../widget/textwidget/text_widget.dart'; // Update the import path

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "History"),
      body: ZoomIn(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://hottouchkitchen.com/wp-content/uploads/2024/01/side-view-female-chef-kitchen-slicing-vegetables-compressed-scaled.jpg",
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextWidget(
                            text: 'CleanXpress',
                            textSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 4),
                          const TextWidget(
                            text: '24/2/2024 - Present',
                            textSize: 12,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (i) {
                                  return const Icon(
                                    Icons.star_border,
                                    size: 16,
                                    color: AppColors.grey,
                                  );
                                }),
                              ),
                              const SizedBox(width: 6),
                              const TextWidget(
                                text: 'Rate to our team',
                                textSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _statusLabel('Repeat Booking', AppColors.green700)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statusLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextWidget(
        text: text,
        color: color,
        textSize: 12,
      ),
    );
  }
}
