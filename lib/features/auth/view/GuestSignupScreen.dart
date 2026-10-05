import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/controller/auth_controller.dart';

class GuestSignupScreen extends StatefulWidget {
  final int restaurantId;
  final VoidCallback? onClose;
  final VoidCallback? onGuestSignupSuccess;

  const GuestSignupScreen({
    required this.restaurantId,
    super.key,
    this.onClose,
    this.onGuestSignupSuccess,
  });

  @override
  State<GuestSignupScreen> createState() => _GuestSignupScreenState();
}

class _GuestSignupScreenState extends State<GuestSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = context.read<AuthController>();

    setState(() {
      _isLoading = true;
    });

    final success = await authController.guestSignup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      cellNum: _phoneController.text.trim(),
      restaurantId: widget.restaurantId,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      widget.onGuestSignupSuccess?.call();
      return;
    }

    final errorMessage =
        authController.errorMessage ?? "Guest signup failed. Please try again.";

    _showMessage(errorMessage);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return "Please enter your name";
    }

    if (name.length < 2) {
      return "Name is too short";
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return "Please enter your email";
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return "Please enter a valid email";
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return "Please enter your phone number";
    }

    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return "Please enter a valid phone number";
    }

    return null;
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.small.copyWith(
        color: AppColors.textSecondary,
      ),
      prefixIcon: Icon(icon, color: AppColors.iconSecondary, size: 18),
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: _isLoading ? null : widget.onClose,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.iconPrimary,
            size: 18,
          ),
        ),
        title: Text(
          "Continue as Guest",
          style: AppTextStyles.title,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    "Guest Checkout",
                    style: AppTextStyles.heading
                  ),
                ),
                const SizedBox(height: 7),
                const Center(
                  child: Text(
                    "Enter your details to continue with your order.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "Name",
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration(
                    hintText: "Enter your name",
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                Text(
                  "Email",
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration(
                    hintText: "Enter your email",
                    icon: Icons.email_outlined,
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                Text(
                  "Phone Number",
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration(
                    hintText: "03001234567",
                    icon: Icons.phone_outlined,
                  ),
                  validator: _validatePhone,
                  onFieldSubmitted: (_) {
                    _continueAsGuest();
                  },
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.border),
                  ),
                  child:  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 17,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You can place an order without creating a permanent account.",
                          style: AppTextStyles.small.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading || authController.isLoading
                        ? null
                        : _continueAsGuest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading || authController.isLoading
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : Text(
                      "Continue as Guest",
                      style: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
