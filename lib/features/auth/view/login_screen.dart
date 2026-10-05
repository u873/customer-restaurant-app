import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../core/services/google_auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onClose;
  final VoidCallback? onGuestSignup;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onClose,
    this.onGuestSignup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();

    debugPrint("LOGIN FCM TOKEN: $fcmToken");

    if (fcmToken == null || fcmToken.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("FCM token not available")));

      return;
    }

    final auth = context.read<AuthController>();

    final success = await auth.login(
      restaurantId: "1248",
      deviceId: fcmToken,
      email: _emailController.text.trim(),
      orderResourceId: "3",
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      widget.onLoginSuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Login failed.")),
      );
    }
  }

  Future<void> _googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleAuthService.signIn();

      if (googleUser == null) {
        return;
      }

      if (!mounted) return;

      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("FCM token not available")),
        );

        return;
      }

      final auth = context.read<AuthController>();

      final success = await auth.socialLogin(
        email: googleUser.email,
        restaurantId: 1248,
        socialAppId: googleUser.id,
        name: googleUser.displayName ?? googleUser.email.split('@').first,
        orderResourceId: 3,
        deviceId: fcmToken,
        loginTypeId: 2,
      );

      if (!mounted) return;

      if (success) {
        widget.onLoginSuccess?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? "Google login failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google login failed: $e")));
    }
  }

  void _goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _continueAsGuest() {
    if (widget.onGuestSignup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Guest signup is not available.")),
      );
      return;
    }

    widget.onGuestSignup!.call();
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
      prefixIcon: Icon(icon, color: AppColors.iconSecondary, size: 16),
      filled: true,
      fillColor: AppColors.foodCardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.foodCardBackground,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              text,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 55),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Login",
                            style: AppTextStyles.title.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 3),

                        Center(
                          child: Text(
                            "Welcome back. Ready to indulge?",
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          "EMAIL ADDRESS",
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: AppTextStyles.body,
                          decoration: _inputDecoration(
                            hintText: "name@example.com",
                            icon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your email";
                            }

                            if (!value.contains("@")) {
                              return "Please enter a valid email";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "PASSWORD",
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Forgot?",
                                style: AppTextStyles.action.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          style: AppTextStyles.body,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: AppTextStyles.small.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.iconSecondary,
                              size: 16,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.iconSecondary,
                                size: 15,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.foodCardBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(9),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }

                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (!auth.isLoading) {
                              _login();
                            }
                          },
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  )
                                : Text("Login", style: AppTextStyles.button),
                          ),
                        ),

                        const SizedBox(height: 13),

                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                "OR CONTINUE WITH",
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        _buildSocialButton(
                          icon: "G",
                          text: "Google",
                          onTap: auth.isLoading ? () {} : _googleLogin,
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: OutlinedButton(
                            onPressed: auth.isLoading ? null : _continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.foodCardBackground,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            child: Text(
                              "Continue as Guest",
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                GestureDetector(
                  onTap: _goToSignup,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySecondary,
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(text: "Sign Up", style: AppTextStyles.action),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
