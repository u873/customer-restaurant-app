import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String customerId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.email,
    required this.customerId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _otp = ["", "", "", ""];

  Timer? _timer;
  int _secondsRemaining = 45;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // TIMER
  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 45;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();

        setState(() {
          _secondsRemaining = 0;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  // ADD DIGIT
  void _addDigit(String digit) {
    for (int i = 0; i < _otp.length; i++) {
      if (_otp[i].isEmpty) {
        setState(() {
          _otp[i] = digit;
        });
        return;
      }
    }
  }

  // REMOVE DIGIT
  void _removeDigit() {
    for (int i = _otp.length - 1; i >= 0; i--) {
      if (_otp[i].isNotEmpty) {
        setState(() {
          _otp[i] = "";
        });
        return;
      }
    }
  }

  String get _otpValue => _otp.join();

  bool get _isComplete {
    return _otp.every((digit) => digit.isNotEmpty);
  }

  // VERIFY OTP
  Future<void> _verifyOtp() async {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the complete OTP")),
      );
      return;
    }

    final auth = context.read<AuthController>();

    final success = await auth.verifyAccountOtp(
      customerId: widget.customerId,
      otp: _otpValue,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage ?? "OTP verified successfully"),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Invalid OTP")),
      );
    }
  }

  Future<void> _resendOtp() async {
    final auth = context.read<AuthController>();

    final success = await auth.resendAccountOtp(customerId: widget.customerId);

    if (!mounted) return;

    if (success) {
      setState(() {
        _otp.fillRange(0, _otp.length, "");
      });

      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage ?? "OTP resent successfully"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Unable to resend OTP")),
      );
    }
  }

  // OTP BOX
  Widget _otpBox(int index) {
    final hasValue = _otp[index].isNotEmpty;

    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.foodCardBackground,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: hasValue ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      child: Text(
        hasValue ? _otp[index] : "",
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // NUMBER BUTTON
  Widget _keyButton(String value) {
    return GestureDetector(
      onTap: () => _addDigit(value),
      child: Container(
        height: 39,
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // BACKSPACE
  Widget _backspaceButton() {
    return GestureDetector(
      onTap: _removeDigit,
      child: Container(
        height: 39,
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.backspace_outlined,
          size: 16,
          color: AppColors.iconSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, "0");

    final seconds = (_secondsRemaining % 60).toString().padLeft(2, "0");

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            children: [
              // HEADER
              SizedBox(
                height: 45,
                child: Row(
                  children: [
                    // BACK BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardBackgroundLight,
                          border: Border.all(color: AppColors.border),
                        ),

                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.iconSecondary,
                          size: 16,
                        ),
                      ),
                    ),

                    // CENTER TITLE
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Zest & Sizzle",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 30),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // LOCK ICON
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardBackgroundLight,
                ),

                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),

              const SizedBox(height: 18),

              // TITLE
              const Text(
                "Verification Code",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              // DESCRIPTION
              Text(
                "Enter the 4-digit code sent to your phone\n"
                "${_maskedPhone()}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 8,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              // OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _otpBox(0),

                  const SizedBox(width: 9),
                  _otpBox(1),
                  const SizedBox(width: 9),

                  _otpBox(2),

                  const SizedBox(width: 9),

                  _otpBox(3),
                ],
              ),

              const SizedBox(height: 15),

              // RESEND
              GestureDetector(
                onTap: _secondsRemaining == 0 ? _resendOtp : null,

                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),

                    children: [
                      const TextSpan(text: "Didn't receive code? "),

                      TextSpan(
                        text: _secondsRemaining == 0
                            ? "Resend"
                            : "Resend ($minutes:$seconds)",

                        style: TextStyle(
                          color: _secondsRemaining == 0
                              ? AppColors.primary
                              : AppColors.textTertiary,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 42,

                child: ElevatedButton(
                  onPressed: _verifyOtp,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,

                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(width: 5),

                      Icon(Icons.arrow_forward, size: 13),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // CHANGE PHONE
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "Change phone number",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
              ),

              const Spacer(),

              GridView.count(
                crossAxisCount: 3,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.7,

                children: [
                  _keyButton("1"),
                  _keyButton("2"),
                  _keyButton("3"),
                  _keyButton("4"),
                  _keyButton("5"),
                  _keyButton("6"),
                  _keyButton("7"),
                  _keyButton("8"),
                  _keyButton("9"),

                  const SizedBox(),

                  _keyButton("0"),
                  _backspaceButton(),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // MASK PHONE NUMBER
  String _maskedPhone() {
    final phone = widget.phoneNumber;

    if (phone.length < 7) {
      return phone;
    }

    return "${phone.substring(0, 5)}***${phone.substring(phone.length - 2)}";
  }
}
