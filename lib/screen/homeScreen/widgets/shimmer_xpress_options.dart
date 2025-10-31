import 'package:flutter/material.dart';
import 'package:maidxpress/utils/widgets/shimmer_loader.dart';

class ShimmerXpressOptions extends StatelessWidget {
  const ShimmerXpressOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Show 5 shimmer items
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                const ShimmerLoader(
                  width: 70,
                  height: 70,
                  borderRadius: 35,
                ),
                const SizedBox(height: 8),
                ShimmerLoader(
                  width: 80,
                  height: 16,
                  borderRadius: 4,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
