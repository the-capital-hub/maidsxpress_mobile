import 'package:flutter/material.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';

import '../../utils/appcolors/app_colors.dart';
import '../../widget/textwidget/text_widget.dart';

class ProcessScreen extends StatefulWidget {
  const ProcessScreen({super.key});

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Process"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://hottouchkitchen.com/wp-content/uploads/2024/01/side-view-female-chef-kitchen-slicing-vegetables-compressed-scaled.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              sizedTextfield,
              const TextWidget(
                text: "CleanXpress",
                textSize: 18,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  TextWidget(
                    text: "Jenny Wilson",
                    textSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  TextWidget(
                    text: " 4.4 (120 Users)",
                    textSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              sizedTextfield,
              const ServiceProgressStepper(
                  currentStatus: ServiceStatus.floorCleaning),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: AppButton.primaryButton(onButtonPressed: () {}, title: "Home"),
      ),
    );
  }
}

enum ServiceStatus {
  arrived,
  startedWorking,
  floorCleaning,
  dishWash,
  completed,
}

class ServiceProgressStepper extends StatelessWidget {
  final ServiceStatus currentStatus;

  const ServiceProgressStepper({super.key, required this.currentStatus});

  List<_StepModel> get steps => const [
        _StepModel(
          title: "Arrived",
          description:
              "The CleanXpress has just arrived, ready to revolutionize your cleaning routine!",
          status: ServiceStatus.arrived,
        ),
        _StepModel(
          title: "Started Working",
          description:
              "A detailed overview of the project objectives and key milestones.",
          status: ServiceStatus.startedWorking,
        ),
        _StepModel(
          title: "Floor Cleaning",
          description:
              "Keep your floors sparkling clean with our advanced floor cleaning solutions. Whether it's hardwood.",
          status: ServiceStatus.floorCleaning,
        ),
        _StepModel(
          title: "Dish Wash",
          description:
              "A dishwash is a convenient appliance that automates the process of cleaning dishes, pots, and utensils.",
          status: ServiceStatus.dishWash,
        ),
        _StepModel(
          title: "Completed",
          description: "Service completed successfully!",
          status: ServiceStatus.completed,
        ),
      ];

  int getCurrentStatusIndex() {
    return steps.indexWhere((step) => step.status == currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = getCurrentStatusIndex();

    return ListView.builder(
      itemCount: steps.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final step = steps[index];
        final isActive = index <= currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0CA789)
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                if (index != steps.length - 1)
                  Container(
                    width: 2,
                    height: 60,
                    color: isActive
                        ? const Color(0xFF0CA789)
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: step.title,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.black : Colors.grey,
                      textSize: 14,
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: step.description,
                      maxLine: 2,
                      textSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StepModel {
  final String title;
  final String description;
  final ServiceStatus status;

  const _StepModel({
    required this.title,
    required this.description,
    required this.status,
  });
}
