import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Your City",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Enter your city name Eg: Chennai",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Popular Cities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Popular Cities",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: popularCities.map((city) {
                  final isSelected = city == selectedCity;
                  return GestureDetector(
                    onTap: () => _selectCity(city),
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city,
                            color:
                                isSelected ? Colors.white : AppColors.blackCard,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            city,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected ? Colors.white : AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Expanded Cities List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _searchController.text.isNotEmpty
                    ? _filteredCities.length
                    : allCitiesGrouped.length,
                itemBuilder: (context, index) {
                  if (_searchController.text.isNotEmpty) {
                    final city = _filteredCities[index];
                    return ListTile(
                      onTap: () => _selectCity(city),
                      title: Text(
                        city,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: city == selectedCity
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: city == selectedCity
                              ? AppColors.primary
                              : Colors.black,
                        ),
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
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...cities.map((city) => ListTile(
                              onTap: () => _selectCity(city),
                              title: Text(
                                city,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: city == selectedCity
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: city == selectedCity
                                      ? AppColors.primary
                                      : Colors.black,
                                ),
                              ),
                            )),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),

      // Continue Button
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
