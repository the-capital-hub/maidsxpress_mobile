import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';

import '../../../widget/appbar/appbar.dart';
import '../../../widget/textwidget/text_widget.dart';
import '../addressScreen/location_screen.dart';

class SelectCityScreen extends StatefulWidget {
  const SelectCityScreen({super.key});

  @override
  State<SelectCityScreen> createState() => _SelectCityScreenState();
}

class _SelectCityScreenState extends State<SelectCityScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCity = 'Bengaluru';

  final List<String> popularCities = [
    'Mumbai',
    'Bengaluru',
    'Delhi',
    'Hyderabad',
    'Chennai',
    'Goa',
    'Kolkata',
    'Kochi',
  ];

  final Map<String, List<String>> allCitiesGrouped = {
    'A': [
      'Andhara Pradesh',
      'Ahmedabad',
      'Arunachal Pradesh',
      'Anatapuram',
      'Assam',
    ],
    'B': ['Bangalore', 'Ballari', 'Belgaum', 'Bhopal'],
    // Add more if needed...
  };

  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCities);
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = allCitiesGrouped.values
          .expand((cities) => cities)
          .where((city) => city.toLowerCase().contains(query))
          .toList();
    });
  }

  void _selectCity(String city) {
    setState(() {
      selectedCity = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelperAppBar.appbarHelper(title: "Select Your City"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                MyCustomTextField.textField(
                    hintText: "Enter your city name",
                    controller: _searchController,
                    textInputType: TextInputType.text),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: TextWidget(
                      text: 'Popular Cities',
                      textSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: popularCities.map((city) {
                    final isSelected = city == selectedCity;
                    return GestureDetector(
                      onTap: () => _selectCity(city),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_city,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.blackCard),
                            const SizedBox(height: 4),
                            TextWidget(
                              text: city,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.black,
                              fontWeight: FontWeight.w500,
                              textSize: 12,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const TextWidget(
                    text: 'All Cities',
                    textSize: 16,
                    fontWeight: FontWeight.bold),
                const SizedBox(height: 10),
                ListView.builder(
                  itemCount: _searchController.text.isNotEmpty
                      ? _filteredCities.length
                      : allCitiesGrouped.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (_searchController.text.isNotEmpty) {
                      final city = _filteredCities[index];
                      return ListTile(
                        onTap: () => _selectCity(city),
                        title: TextWidget(
                          text: city,
                          textSize: 14,
                          fontWeight:
                              city == selectedCity ? FontWeight.bold : null,
                          color: city == selectedCity
                              ? const Color(0xFF1AB69D)
                              : Colors.black,
                        ),
                      );
                    } else {
                      final key = allCitiesGrouped.keys.elementAt(index);
                      final cities = allCitiesGrouped[key]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 16),
                            child: TextWidget(
                              text: key,
                              textSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...cities.map((city) => ListTile(
                                onTap: () => _selectCity(city),
                                title: TextWidget(
                                  text: city,
                                  textSize: 14,
                                  fontWeight: city == selectedCity
                                      ? FontWeight.bold
                                      : null,
                                  color: city == selectedCity
                                      ? AppColors.primary
                                      : Colors.black,
                                ),
                              )),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AppButton.primaryButton(
            onButtonPressed: () {
              Get.to(() => const LocationScreen());
            },
            title: "Continue"),
      ),
    );
  }
}
