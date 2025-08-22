import 'package:flutter/material.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/constant/app_var.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';

import '../../widget/textwidget/text_widget.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<String> tabs = [
    'All',
    'Payment',
    'Services',
    'Re-Schedule',
    'Track'
  ];
  String selectedTab = 'All';
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: HelperAppBar.appbarHelper(title: "Notifications"),
        body: Column(
          children: [
            const Divider(),
            sizedTextfield,
            SizedBox(
              height: 35,
              child: ListView.separated(
                itemCount: tabs.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: 0),
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = selectedTab == tabs[index];
                  return InkWell(
                    onTap: () {
                      selectedTab = tabs[index];
                      setState(() {});
                    },
                    splashColor: AppColors.transparent,
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          color:
                              isSelected ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(100)),
                      child: Center(
                        child: TextWidget(
                          text: tabs[index],
                          textSize: 13,
                          color:
                              isSelected ? AppColors.white : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: List.generate(
                    tabs.length, (index) => buildNotificationList(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (selectedTab == 'All' || selectedTab == 'Services') ...[
          sectionHeader("Services"),
          serviceCard(
            context,
            "Hey, Karthik",
            "Our CleanXpress is ready come your home. Can you confirm with us?",
            "assets/clean1.png",
            actionButtons: [
              actionButton("Absent", AppColors.redColor),
              actionButton("Re-Schedule", AppColors.primary),
            ],
          ),
          serviceCard(
            context,
            "Hey, Karthik",
            "Our CleanXpress is ready come your home. Can you confirm with us?",
            "assets/clean2.png",
            actionButtons: [actionButton("Track", AppColors.primary)],
          ),
        ],
        if (selectedTab == 'All' || selectedTab == 'Track') ...[
          sectionHeader("Arrived the service"),
          serviceCard(
            context,
            "Our team is here...!",
            "Karthik kumar our team is waiting outside. Please connect with my team.",
            "assets/team1.png",
            actionButtons: [actionButton("Call", AppColors.primary)],
          ),
          serviceCard(
            context,
            "Our team is here...!",
            "Karthik kumar our team is waiting outside. Please connect with my team.",
            "assets/team2.png",
            actionButtons: [actionButton("Call", AppColors.primary)],
          ),
        ],
        if (selectedTab == 'All' || selectedTab == 'Payment') ...[
          sectionHeader("Payments"),
          serviceCard(
            context,
            "Payment Reminder",
            "Hey there! Just a friendly reminder that your payment is due soon. If you have any questions or need assistance, feel free to reach out. Thanks!",
            "assets/pay1.png",
            actionButtons: [actionButton("Pay Now", AppColors.primary)],
          ),
          serviceCard(
            context,
            "Payment Reminder",
            "Hey there! Just a friendly reminder that your payment is due soon. If you have any questions or need assistance, feel free to reach out. Thanks!",
            "assets/pay2.png",
            actionButtons: [actionButton("Pay Now", AppColors.primary)],
          ),
          serviceCard(
            context,
            "Payment Canceled",
            "The payment has been canceled. Please let us know if you need any further assistance.",
            "assets/cancel.png",
            actionButtons: [actionButton("Re-Pay", AppColors.redColor)],
          ),
        ],
        if (selectedTab == 'All' || selectedTab == 'Re-Schedule') ...[
          sectionHeader("Re-Schedule"),
          serviceCard(
            context,
            "Re-Schedule Reminder",
            "You have requested a reschedule. Please confirm your availability.",
            "assets/reschedule.png",
            actionButtons: [actionButton("Confirm", AppColors.primary)],
          ),
        ],
      ],
    );
  }

  Widget sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextWidget(text: text, textSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget serviceCard(
    BuildContext context,
    String title,
    String description,
    String imagePath, {
    List<Widget> actionButtons = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: AppColors.black38, blurRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 55,
                  height: 48,
                  color: Colors.grey[300],
                  child: Image.network(
                      "https://hottouchkitchen.com/wp-content/uploads/2024/01/side-view-female-chef-kitchen-slicing-vegetables-compressed-scaled.jpg",
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                        text: title, textSize: 15, fontWeight: FontWeight.w600),
                    const SizedBox(height: 6),
                    TextWidget(
                      text: description,
                      textSize: 12,
                      maxLine: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          sizedTextfield,
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: actionButtons,
          ),
        ],
      ),
    );
  }

  Widget actionButton(String label, Color color) {
    return AppButton.outlineButton(
        onButtonPressed: () {},
        title: label,
        height: 35,
        fontSize: 12,
        width: 120,
        borderColor: color);
  }
}
