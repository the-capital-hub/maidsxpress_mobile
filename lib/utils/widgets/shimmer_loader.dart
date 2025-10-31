import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Shimmer.fromColors(
          baseColor: baseColor ?? Colors.grey[300]!,
          highlightColor: highlightColor ?? Colors.grey[100]!,
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ShimmerListLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;

  const ShimmerListLoader({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 100.0,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: ShimmerLoader(
            width: double.infinity,
            height: itemHeight,
            borderRadius: 8.0,
          ),
        );
      },
    );
  }
}

class ShimmerGridLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;
  final int crossAxisCount;
  final EdgeInsets padding;

  const ShimmerGridLoader({
    Key? key,
    this.itemCount = 6,
    this.itemHeight = 150.0,
    this.spacing = 8.0,
    this.crossAxisCount = 2,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerLoader(
          width: double.infinity,
          height: itemHeight,
          borderRadius: 12.0,
        );
      },
    );
  }
}
