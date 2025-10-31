import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

import '../../../controller/auth/auth_controller.dart';

class RegisterDetailsScreen extends StatefulWidget {
  const RegisterDetailsScreen({super.key});

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map?;
    if (args != null) {
      final phone = (args['phone'] as String?) ?? '';
      final email = (args['email'] as String?) ?? '';
      if (phone.isNotEmpty) phoneController.text = phone;
      if (email.isNotEmpty) emailController.text = email;
    }
  }

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final city = cityController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || city.isEmpty || address.isEmpty) {
      HelperSnackBar.error('Please fill all the fields');
      return;
    }

    try {
      isLoading.value = true;
      final ok = await AuthController.to.register({
        'phone': phone,
        'name': name,
        'email': email,
        'city': city,
        'address': address,
      });
      if (ok) {
        HelperSnackBar.success('Registration successful. Please login.');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      HelperSnackBar.error('Registration failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(text: 'Complete your profile', textSize: 16, fontWeight: FontWeight.w700),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const TextWidget(text: 'Name', textSize: 14, fontWeight: FontWeight.w600),
            MyCustomTextField.textField(hintText: 'Your full name', lableText: 'Name', controller: nameController, textInputType: TextInputType.name),
            const SizedBox(height: 12),
            const TextWidget(text: 'Email', textSize: 14, fontWeight: FontWeight.w600),
            MyCustomTextField.textField(hintText: 'name@example.com', lableText: 'Email', controller: emailController, textInputType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            const TextWidget(text: 'Phone', textSize: 14, fontWeight: FontWeight.w600),
            MyCustomTextField.textField(hintText: '10-digit phone', lableText: 'Phone', controller: phoneController, textInputType: TextInputType.phone),
            const SizedBox(height: 12),
            const TextWidget(text: 'City', textSize: 14, fontWeight: FontWeight.w600),
            MyCustomTextField.textField(hintText: 'City', lableText: 'City', controller: cityController, textInputType: TextInputType.text),
            const SizedBox(height: 12),
            const TextWidget(text: 'Address', textSize: 14, fontWeight: FontWeight.w600),
            MyCustomTextField.textField(hintText: 'Full address', lableText: 'Address', controller: addressController, textInputType: TextInputType.streetAddress),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() => AppButton.primaryButton(
              onButtonPressed: isLoading.value ? null : _submit,
              title: isLoading.value ? 'Submitting...' : 'Complete Registration',
              isLoading: isLoading.value,
            )),
      ),
    );
  }
}


