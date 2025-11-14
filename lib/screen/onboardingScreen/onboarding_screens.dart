import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/asset_constant.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import '../../widget/textwidget/text_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../authScreen/loginScreen/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      "image": PngAssetPath.ob1Img,
      "text": "We provide professional service at a friendly price"
    },
    {
      "image": PngAssetPath.ob2Img,
      "text": "The best results and your satisfaction is out top priority"
    },
    {
      "image": PngAssetPath.ob3Img,
      "text": "Let’s make awesome changes at your home"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomHeight = screenHeight * 0.28;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 7, // Takes 70% of available space
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) => currentPage.value = index,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ZoomIn(
                      child: Image.asset(
                        onboardingData[index]["image"]!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: bottomHeight,
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.9,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Obx(() {
                final isLast = currentPage.value == onboardingData.length - 1;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: onboardingData[currentPage.value]["text"]!,
                      textSize: 24,
                      maxLine: 10,
                      textSpan: _buildOnboardingTextSpan(currentPage.value),
                      align: TextAlign.center,
                      fontWeight: FontWeight.w500,
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: onboardingData.length,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.grey,
                        dotHeight: 10,
                        dotWidth: 10,
                      ),
                    ),
                    AppButton.primaryButton(
                        onButtonPressed: () {
                          if (isLast) {
                            Get.to(() => const LoginScreen());
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        title: isLast ? "Get Started" : "Next"),
                  ],
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  TextSpan _buildOnboardingTextSpan(int index) {
    final text = onboardingData[index]["text"]!;
    List<TextSpan> spans = [];

    const highlightWords = ["friendly", "price", "top", "priority", "awesome"];

    text.split(" ").forEach((word) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
      final isHighlight = highlightWords.contains(cleanWord.toLowerCase());

      spans.add(TextSpan(
        text: "$word ",
        style: TextStyle(
          color: isHighlight ? AppColors.primary : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ));
    });

    return TextSpan(children: spans);
  }
}
