import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/address/address_controller.dart';
import 'package:maidxpress/models/address_model.dart';
import 'package:maidxpress/screen/addressScreen/address_form_screen.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';
import 'package:maidxpress/screen/orderConfirmScreen/order_summary_screen.dart';
import 'package:maidxpress/models/service_model.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final AddressController _addressController = Get.put(AddressController());
  int selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load addresses when screen opens
    _addressController.loadAddresses();
  }

  // Refresh when coming back from add/edit screen
  Future<void> _refreshData() async {
    await _addressController.loadAddresses();
  }

  String _formatAddress(Address address) {
    return '${address.address}, ${address.pincode}';
  }

  IconData _getAddressIcon(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('home')) {
      return Icons.home_outlined;
    } else if (lowerLabel.contains('work') || lowerLabel.contains('office')) {
      return Icons.work_outline;
    } else {
      return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Location"),
      body: Obx(() {
        if (_addressController.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColors.primary,
          ));
        }

        if (_addressController.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextWidget(
                  text: 'No addresses found',
                  textSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 16),
                AppButton.outlineButton(
                  onButtonPressed: () async {
                    await Get.to(() => const AddressFormScreen());
                    await _refreshData();
                  },
                  borderColor: AppColors.primary,
                  title: "+ Add New Address",
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await _addressController.loadAddresses();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _addressController.addresses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final address = _addressController.addresses[index];
                    return FadeInDown(
                      delay: Duration(milliseconds: 100 * index),
                      child: Card(
                        color: AppColors.white,
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          leading: Icon(
                            _getAddressIcon(address.label),
                            size: 28,
                            color: AppColors.primary,
                          ),
                          title: TextWidget(
                            text: address.label,
                            textSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: TextWidget(
                                      text: _formatAddress(address),
                                      textSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.call,
                                      size: 14, color: AppColors.black54),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: TextWidget(
                                      text: address.phone,
                                      textSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: 100), // Increased to 150
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: IconButton(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.edit,
                                        color: AppColors.primary, size: 20),
                                    onPressed: () async {
                                      await Get.to(() => AddressFormScreen(
                                            addressId: address.id,
                                            initialData: {
                                              'label': address.label,
                                              'address': address.address,
                                              'phone': address.phone,
                                              'pincode': address.pincode,
                                            },
                                          ));
                                      await _refreshData();
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: IconButton(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                    onPressed: () async {
                                      final confirm = await Get.dialog<bool>(
                                        AlertDialog(
                                          title: const Text('Delete Address'),
                                          content: const Text(
                                              'Are you sure you want to delete this address?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Get.back(result: false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Get.back(result: true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final success = await _addressController
                                            .deleteAddress(address.id);
                                        if (success) {
                                          // Show success message after deletion
                                          Get.snackbar(
                                            'Success',
                                            'Address deleted successfully ✓',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.green,
                                            colorText: Colors.white,
                                            duration: const Duration(seconds: 2),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4), // Added spacer
                                Flexible(
                                  child: Radio<int>(
                                    value: index,
                                    groupValue: selectedAddressIndex,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedAddressIndex = val!;
                                      });
                                      _addressController.selectAddress(address);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  AppButton.outlineButton(
                    onButtonPressed: () async {
                      await Get.to(() => const AddressFormScreen());
                      await _refreshData();
                    },
                    borderColor: AppColors.primary,
                    title: "+ Add New Address",
                  ),
                  const SizedBox(height: 16),
                  AppButton.primaryButton(
                    onButtonPressed: () {
                      if (_addressController.selectedAddress.value != null) {
                        final Map<String, dynamic> args = Get.arguments ?? {};
                        print('Received in AddressSelectionScreen: $args');
                        Get.to(() => OrderSummaryScreen(
                              service: args['service'] ??
                                  Service(
                                      id: '',
                                      name: '',
                                      tag: '',
                                      image: '',
                                      include: [],
                                      exclude: [],
                                      subServices: [],
                                      isFavorite: false),
                              selectedOptions:
                                  Map<String, Map<String, dynamic>>.from(
                                      args['selectedOptions'] ?? {}),
                              selectedDate: args['selectedDate'] is DateTime
                                  ? args['selectedDate']
                                  : DateTime.now(),
                              selectedTime: args['selectedTime']?.toString() ??
                                  'Not specified',
                              selectedAddress:
                                  _addressController.selectedAddress.value!,
                              genderPreference:
                                  args['genderPreference']?.toString(),
                            ));
                      } else {
                        Get.snackbar(
                          'Error',
                          'Please select an address first',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    title: "Continue",
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
