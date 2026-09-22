import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/model/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../loyalty/provider/loyalty_provider.dart';
import '../../menu/controller/menu_controller.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onClose;
  final void Function(String orderNumber) onTrackOrder;
  final VoidCallback onLoyaltyPoints;
  final VoidCallback onWallet;
  final VoidCallback onAddresses;
  final VoidCallback onManageOrderType;
  final void Function(String type) onContent;

  const ProfileScreen({
    super.key,
    required this.onClose,
    required this.onTrackOrder,
    required this.onLoyaltyPoints,
    required this.onWallet,
    required this.onAddresses,
    required this.onManageOrderType,
    required this.onContent,
  });

  Future<void> _showEditProfileDialog(
    BuildContext context,
    UserModel user,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _EditProfileDialog(user: user);
      },
    );

    if (!context.mounted) return;

    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff292A2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xff343539),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthController>().logout();

    if (!context.mounted) return;

    onClose();
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    UserModel user,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _ChangePasswordDialog(user: user);
      },
    );

    if (!context.mounted) return;

    if (changed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );
    }
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    UserModel user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff292A2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xff343539),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete your account? "
            "This action cannot be undone.",
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    if (user.customerId.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Customer ID not found")));
      return;
    }

    final auth = context.read<AuthController>();

    auth.clearMessages();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Color(0xff292A2D),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 14),
                Text(
                  "Deleting account...",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );

    final success = await auth.deleteAccount(userId: user.customerId);

    if (!context.mounted) return;

    Navigator.of(context).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage ?? "Account deleted successfully"),
        ),
      );

      onClose();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? "Unable to delete account"),
        ),
      );
    }

    auth.clearMessages();
  }

  Future<void> _launchSocialUrl(BuildContext context, String type) async {
    final menuProvider = context.read<MenuProvider>();
    final data = menuProvider.menuResponse?.data;

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Social media information not available")),
      );
      return;
    }

    String? url;

    switch (type) {
      case 'facebook':
        url = data.facebookProfileUrl;
        break;

      case 'instagram':
        url = data.instagramProfileUrl;
        break;

      case 'tiktok':
        url = data.tiktokProfileUrl;
        break;

      case 'youtube':
        url = data.youtubeProfileUrl;
        break;

      case 'twitter':
        url = data.xProfileUrl;
        break;

      case 'linkedin':
        url = data.linkedinProfileUrl;
        break;

      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid social type")));
        return;
    }

    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Social media link is not available")),
      );
      return;
    }

    url = url.trim();

    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "https://$url";
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid social media URL")));
      return;
    }

    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );

      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to open this link")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final menuProvider = context.watch<MenuProvider>();
    final socialData = menuProvider.menuResponse?.data;

    final socialItems = <_SocialItem>[
      if (socialData?.facebookProfileUrl?.trim().isNotEmpty == true)
        const _SocialItem(
          type: "facebook",
          title: "Facebook",
          icon: Icons.facebook,
        ),
      if (socialData?.instagramProfileUrl?.trim().isNotEmpty == true)
        const _SocialItem(
          type: "instagram",
          title: "Instagram",
          icon: Icons.camera_alt_outlined,
        ),
      if (socialData?.tiktokProfileUrl?.trim().isNotEmpty == true)
        const _SocialItem(
          type: "tiktok",
          title: "TikTok",
          icon: Icons.music_note_outlined,
        ),
      if (socialData?.youtubeProfileUrl?.trim().isNotEmpty == true)
        const _SocialItem(
          type: "youtube",
          title: "YouTube",
          icon: Icons.play_circle_outline,
        ),
      if (socialData?.xProfileUrl?.trim().isNotEmpty == true)
        const _SocialItem(type: "twitter", title: "X", icon: Icons.close),
      if (socialData?.linkedinProfileUrl?.trim().isNotEmpty == true)
        const _SocialItem(
          type: "linkedin",
          title: "LinkedIn",
          icon: Icons.business_center_outlined,
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "My Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),

              const SizedBox(height: 16),

              // PROFILE CARD
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xff292A2D),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xff343539),
                          child: Icon(
                            Icons.person,
                            color: Colors.white54,
                            size: 35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.name ?? "User",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Consumer<LoyaltyProvider>(
                        builder: (context, loyalty, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "GOLD MEMBER • "
                                "${loyalty.loyaltyPoints.toStringAsFixed(0)} "
                                "POINTS",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // LOYALTY & WALLET
              if (AppConstants.enableLoyaltySystem) ...[
                Consumer<LoyaltyProvider>(
                  builder: (context, loyalty, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.stars_outlined,
                            title:
                                "${loyalty.loyaltyPoints.toStringAsFixed(0)} Points",
                            onTap: onLoyaltyPoints,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.account_balance_wallet_outlined,
                            title:
                                "Rs. ${loyalty.walletAmount.toStringAsFixed(0)}",
                            onTap: onWallet,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],

              const SizedBox(height: 20),

              // SETTINGS
              Column(
                children: [
                  // EDIT PROFILE
                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.edit_outlined,
                        title: "Edit Profile",
                        isLogout: true,
                        showArrow: true,
                        onTap: () {
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User information not available"),
                              ),
                            );
                            return;
                          }

                          _showEditProfileDialog(context, user);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // MANAGE ORDER TYPE
                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.swap_horiz_rounded,
                        title: "Manage Order Type",
                        isLogout: true,
                        showArrow: true,
                        onTap: onManageOrderType,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // MANAGE ADDRESSES
                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.location_on_outlined,
                        title: "Manage Addresses",
                        isLogout: true,
                        showArrow: true,
                        onTap: onAddresses,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // CHANGE PASSWORD
                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: "Change Password",
                        isLogout: true,
                        showArrow: true,
                        onTap: () {
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User information not available"),
                              ),
                            );
                            return;
                          }

                          _showChangePasswordDialog(context, user);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // DELETE ACCOUNT
                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.delete_outline_rounded,
                        title: "Delete Account",
                        isLogout: true,
                        showArrow: true,
                        onTap: () {
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User information not available"),
                              ),
                            );
                            return;
                          }
                          _showDeleteAccountDialog(context, user);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // LOGOUT
                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.logout,
                        title: "Logout",
                        isLogout: true,
                        showArrow: false,
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.info_outline,
                        title: "About Us",
                        isLogout: true,
                        showArrow: true,
                        onTap: () {
                          onContent('about');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _SettingsContainer(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.description_outlined,
                        title: "Terms & Conditions",
                        isLogout: true,
                        showArrow: true,
                        onTap: () {
                          onContent('terms');
                        },
                      ),
                    ],
                  ),

                  // SOCIAL MEDIA
                  if (socialItems.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    _SocialMediaContainer(
                      items: socialItems,
                      onTap: (type) {
                        _launchSocialUrl(context, type);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialItem {
  final String type;
  final String title;
  final IconData icon;

  const _SocialItem({
    required this.type,
    required this.title,
    required this.icon,
  });
}

class _SocialMediaContainer extends StatelessWidget {
  final List<_SocialItem> items;
  final void Function(String type) onTap;

  const _SocialMediaContainer({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
      decoration: BoxDecoration(
        color: const Color(0xff292A2D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public, size: 17, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Follow Us",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Padding(
            padding: EdgeInsets.only(left: 25),
            child: Text(
              "Connect with us on social media",
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),

          const SizedBox(height: 13),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              return SizedBox(
                width: 43,
                child: _SocialButton(item: item, onTap: () => onTap(item.type)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final _SocialItem item;
  final VoidCallback onTap;

  const _SocialButton({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: AppColors.primary, size: 20),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.title,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final UserModel user;

  const _EditProfileDialog({required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;

  DateTime? _selectedDate;
  String? _selectedGender;

  bool _isLoading = false;

  final List<String> _genders = ["Male", "Female"];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.user.name);

    _selectedGender = widget.user.gender;

    if (widget.user.dateBirth != null &&
        widget.user.dateBirth!.trim().isNotEmpty) {
      _selectedDate = DateTime.tryParse(widget.user.dateBirth!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (_isLoading) return;

    final now = DateTime.now();

    final firstDate = DateTime(1900, 1, 1);

    final lastDate = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xff292A2D),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xff292A2D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return "Select Date of Birth";
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return "$year-$month-$day";
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage("Please enter your name");
      return;
    }

    if (_selectedDate == null) {
      _showMessage("Please select your date of birth");
      return;
    }

    if (_selectedGender == null || _selectedGender!.trim().isEmpty) {
      _showMessage("Please select your gender");
      return;
    }

    final dateBirth = _formatDate(_selectedDate!);

    final auth = context.read<AuthController>();

    auth.clearMessages();

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await auth.updateCustomer(
        name: name,
        dateBirth: dateBirth,
        gender: _selectedGender!,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop(true);
        return;
      }

      _showMessage(auth.errorMessage ?? "Unable to update profile");

      auth.clearMessages();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage("Something went wrong. Please try again.");
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff292A2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xff343539),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NAME
            TextField(
              controller: _nameController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Name",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.white54,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xff343539),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // EMAIL - READ ONLY
            TextField(
              controller: TextEditingController(text: widget.user.email),
              enabled: false,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Email",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white38,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xff343539),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // PHONE - READ ONLY
            TextField(
              controller: TextEditingController(text: widget.user.phone),
              enabled: false,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Phone",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: Colors.white38,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xff343539),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // DATE OF BIRTH
            InkWell(
              onTap: _isLoading ? null : _pickDate,
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff343539),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white54,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDate(_selectedDate),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.white38
                              : Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // GENDER
            DropdownButtonFormField<String>(
              value: _selectedGender,
              dropdownColor: const Color(0xff343539),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Select Gender",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.white54,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xff343539),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
            ),

            if (context.watch<AuthController>().errorMessage != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.watch<AuthController>().errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  context.read<AuthController>().clearMessages();

                  Navigator.of(context).pop(false);
                },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  "Save",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.foodCardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Color(0xff343539),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsContainer extends StatelessWidget {
  final List<Widget> children;

  const _SettingsContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff292A2D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;
  final bool showArrow;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = isLogout ? AppColors.primary : Colors.white60;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: itemColor),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: itemColor, fontSize: 12),
                ),
              ),
              if (showArrow)
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.white54,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final UserModel user;

  const _ChangePasswordDialog({required this.user});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text.trim();

    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please enter both passwords");
      return;
    }

    if (newPassword.length < 6) {
      _showMessage("Password must be at least 6 characters");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    if (widget.user.email.trim().isEmpty) {
      _showMessage("User email not found");
      return;
    }

    final auth = context.read<AuthController>();

    setState(() {
      _isLoading = true;
    });

    auth.clearMessages();

    try {
      final success = await auth.changePassword(
        restaurantId: ApiConstants.restaurantId.toString(),
        email: widget.user.email.trim(),
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop(true);
        return;
      }

      _showMessage(auth.errorMessage ?? "Unable to change password");

      auth.clearMessages();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage("Something went wrong. Please try again.");
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff292A2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xff343539),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Change Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Enter your new password",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            enabled: !_isLoading,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: "New Password",
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.white54,
                size: 18,
              ),
              suffixIcon: IconButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
              filled: true,
              fillColor: const Color(0xff343539),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            enabled: !_isLoading,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: "Confirm Password",
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.white54,
                size: 18,
              ),
              suffixIcon: IconButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
              filled: true,
              fillColor: const Color(0xff343539),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
            ),
          ),
          if (context.watch<AuthController>().errorMessage != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.watch<AuthController>().errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  context.read<AuthController>().clearMessages();

                  Navigator.of(context).pop(false);
                },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  "Change",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
