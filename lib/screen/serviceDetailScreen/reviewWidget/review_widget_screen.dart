import 'package:flutter/material.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import '../../../widget/textwidget/text_widget.dart';

class ReviewCard extends StatelessWidget {
  final String image;
  final String name;
  final double rating;
  final String date;
  final String comment;

  const ReviewCard({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(image),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: name,
                        textSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextWidget(
                  text: date,
                  textSize: 12,
                  color: AppColors.black54,
                )
              ],
            ),
            const SizedBox(height: 10),
            TextWidget(
              text: comment,
              textSize: 14,
              maxLine: 10,
              color: AppColors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
