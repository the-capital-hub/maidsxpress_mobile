import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maidxpress/controller/user/user_controller.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import 'package:maidxpress/utils/helper/helper_sncksbar.dart';
import 'package:maidxpress/widget/appbar/appbar.dart';
import 'package:maidxpress/widget/buttons/button.dart';
import 'package:maidxpress/widget/text_field/text_field.dart';
import 'package:maidxpress/widget/textwidget/text_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserController _userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State variables
  String? _selectedGender;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _userController.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _cityController.text = user.city ?? '';
      _addressController.text = user.address ?? '';

      // Validate gender value before setting
      final validGenders = ['Male', 'Female', 'Other'];
      if (user.gender != null && validGenders.contains(user.gender)) {
        _selectedGender = user.gender;
      } else {
        _selectedGender = null; // Reset to null if invalid
      }
    }
  }

  String _getInitials() {
    final user = _userController.user;
    if (user?.name != null && user!.name.isNotEmpty) {
      final names = user.name.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return names[0][0].toUpperCase();
      }
    }
    return 'U'; // Default fallback
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      await HelperSnackBar.error('Failed to pick image: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update profile picture if selected
      if (_selectedImage != null) {
        final success =
            await _userController.updateProfilePicture(_selectedImage!.path);
        if (!success) {
          await HelperSnackBar.error('Failed to update profile picture');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Update profile data
      final success = await _userController.updateUserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        gender: _selectedGender,
      );

      if (success) {
        // Show success message and navigate back after a short delay
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        // Wait for the snackbar to show before navigating back
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      HelperSnackBar.error('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HelperAppBar.appbarHelper(title: "Edit Profile"),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              FadeInDown(
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? TextWidget(
                                text: _getInitials(),
                                textSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Personal Information Section
              FadeInLeft(
                child: const TextWidget(
                  text: "Personal Information",
                  textSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Name Field
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: MyCustomTextField.textField(
                  hintText: "Enter your full name",
                  lableText: "Full Name *",
                  controller: _nameController,
                  textInputType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  valText: "Name is required",
                ),
              ),

              const SizedBox(height: 16),

              // Email Field
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: MyCustomTextField.textField(
                  hintText: "Enter your email address",
                  lableText: "Email Address *",
                  controller: _emailController,
                  textInputType: TextInputType.emailAddress,
                  valText: "Email is required",
                ),
              ),

              const SizedBox(height: 16),

              // Phone Field
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: MyCustomTextField.textField(
                  hintText: "Enter your phone number",
                  lableText: "Phone Number",
                  controller: _phoneController,
                  textInputType: TextInputType.phone,
                ),
              ),

              const SizedBox(height: 16),

              // Gender Selection
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: "Gender",
                      textSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          hint: const TextWidget(
                            text: "Select Gender",
                            textSize: 14,
                            color: AppColors.black54,
                          ),
                          isExpanded: true,
                          items:
                              ['Male', 'Female', 'Other'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: TextWidget(
                                text: value,
                                textSize: 14,
                                color: AppColors.black,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Address Information Section
              FadeInLeft(
                delay: const Duration(milliseconds: 500),
                child: const TextWidget(
                  text: "Address Information",
                  textSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // City Field
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: MyCustomTextField.textField(
                  hintText: "Enter your city",
                  lableText: "City",
                  controller: _cityController,
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                ),
              ),

              const SizedBox(height: 16),

              // Address Field
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: MyCustomTextField.textField(
                  hintText: "Enter your full address",
                  lableText: "Full Address",
                  controller: _addressController,
                  textInputType: TextInputType.multiline,
                  maxLine: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

      // Update Button
      bottomNavigationBar: FadeInUp(
        delay: const Duration(milliseconds: 800),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton.primaryButton(
            onButtonPressed: _isLoading ? null : _updateProfile,
            title: _isLoading ? 'Updating...' : 'Update Profile',
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
