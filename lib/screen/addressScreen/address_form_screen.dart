import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/controller/address/address_controller.dart';
import 'package:maidxpress/models/address_model.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';

class AddressFormScreen extends StatefulWidget {
  final String? addressId; // null → add, non-null → edit
  final Map<String, dynamic>? initialData;

  const AddressFormScreen({super.key, this.addressId, this.initialData});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final AddressController addressController = Get.find<AddressController>();
  final _formKey = GlobalKey<FormState>();

  final _labelController = TextEditingController();
  final _addressTextController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool get isEditMode => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode && widget.initialData != null) {
      _labelController.text = widget.initialData!['label'] ?? '';
      _addressTextController.text = widget.initialData!['address'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _pincodeController.text = widget.initialData!['pincode'] ?? '';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressTextController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  /// ✅ Submit Form (Add / Update)
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final address = Address(
        id: widget.addressId ?? '',
        label: _labelController.text.trim(),
        address: _addressTextController.text.trim(),
        phone: _phoneController.text.trim(),
        pincode: _pincodeController.text.trim(),
        isServiceable: true,
        user: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (isEditMode) {
        success = await addressController.updateAddress(address);
      } else {
        success = await addressController.addAddress(
          label: address.label,
          address: address.address,
          phone: address.phone,
          pincode: address.pincode,
        );
      }

      // Close form and show snackbar after successful operation
      if (success) {
        Navigator.of(context).pop(); // Use Navigator instead of Get.back to ensure proper context
      }
    } catch (e) {
      HelperSnackBar.error('Failed to add address. Try again.');
    }
  }

  /// ✅ Delete Address
  Future<void> _deleteAddress() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await addressController.deleteAddress(widget.addressId!);
      if (success) {
        Get.back();
        // Show success after returning to previous screen
        Future.delayed(const Duration(milliseconds: 200), () {
          HelperSnackBar.success('Address deleted successfully ✓');
        });
      }
    }
  }

  /// ✅ Form Fields
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: isEditMode ? 'Edit Address Details' : 'New Address Details',
          textSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),

        // Label
        MyCustomTextField.textField(
          controller: _labelController,
          hintText: 'Enter address label',
          lableText: 'Label (e.g., Home, Work)',
          valText: 'Please enter a label',
          borderRadius: 8.0,
        ),
        const SizedBox(height: 12),

        // Full Address
        MyCustomTextField.textField(
          controller: _addressTextController,
          hintText: 'Enter your full address',
          lableText: 'Full Address',
          valText: 'Please enter your address',
          maxLine: 3,
          borderRadius: 8.0,
          onChange: (value) {
            if (value.isNotEmpty && value.length < 10) {
              return 'Please enter a valid address';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Phone + Pincode
        Row(
          children: [
            Expanded(
              flex: 2,
              child: MyCustomTextField.textField(
                controller: _phoneController,
                hintText: 'Enter phone number',
                lableText: 'Phone Number',
                valText: 'Required',
                textInputType: TextInputType.phone,
                borderRadius: 8.0,
                onChange: (value) {
                  if (value.isNotEmpty && value.length < 10) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: MyCustomTextField.textField(
                controller: _pincodeController,
                hintText: 'Enter pincode',
                lableText: 'Pincode',
                valText: 'Please enter pincode',
                textInputType: TextInputType.number,
                maxLength: 6,
                borderRadius: 8.0,
                onChange: (value) {
                  if (value.isNotEmpty && value.length != 6) {
                    return 'Invalid pincode';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ✅ Buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: addressController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEditMode ? 'Update Address' : 'Add Address',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (isEditMode) ...[
          const SizedBox(height: 12),
          AppButton.outlineButton(
            onButtonPressed: _deleteAddress,
            borderColor: Colors.red,
            title: 'Delete Address',
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelperAppBar.appbarHelper(
        title: isEditMode ? 'Edit Address' : 'Add New Address',
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFormFields(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
