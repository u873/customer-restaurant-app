import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/home_bottom_nav.dart';
import '../../about/view/content_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../../cart/view/cart_screen.dart';
import '../../order_tracking/view/order_tracking_screen.dart';
import '../controller/home_controller.dart';

import '../../address/controller/address_controller.dart';
import '../../address/model/customer_address.dart';
import '../../address/view/customer_addresses_screen.dart';
import '../../auth/view/GuestSignupScreen.dart';
import '../../auth/view/login_screen.dart';
import '../../branch/controller/branch_controller.dart';
import '../../cart/controller/cart_controller.dart';
import '../../checkout/view/checkout_screen.dart';
import '../../location/view/location_screen.dart';
import '../../loyalty/view/loyalty_history_screen.dart';
import '../../loyalty/view/wallet_history_screen.dart';
import '../../menu/controller/menu_controller.dart';
import '../../menu/model/main_data_response.dart';
import '../../menu/view/deal_screen.dart';
import '../../menu/view/product_detail_screen.dart';
import '../../menu/view/see_all_screen.dart';
import '../../order_history/model/order_history_model.dart' hide OrderType;
import '../../order_history/view/order_history_screen.dart';
import '../../order_info/view/order_info_screen.dart';
import '../../profile/view/profile_screen.dart';

import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../widgets/custom_header.dart';
import '../widgets/menu_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final GlobalKey<MenuListState> _menuListKey = GlobalKey<MenuListState>();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;

      final authController = context.read<AuthController>();
      final addressController = context.read<AddressController>();
      final menuProvider = context.read<MenuProvider>();
      final cartProvider = context.read<CartProvider>();

      if (authController.isLoggedIn || authController.isGuest) {
        await addressController.getCustomerAddresses();

        if (!mounted) return;

        final selectedAddress = addressController.selectedAddress;

        if (selectedAddress != null) {
          await menuProvider.setDeliveryLocation(
            address: selectedAddress.address1,
            lat: selectedAddress.latitude,
            lng: selectedAddress.longitude,
            orderAmount: cartProvider.subtotal,
          );
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _prepareOrderTypeFlow();
    });
  }

  Future<void> _prepareOrderTypeFlow() async {
    final menuProvider = context.read<MenuProvider>();
    final branchController = context.read<BranchController>();

    final existingBranch =
        branchController.selectedBranch ?? menuProvider.nearestBranch;

    if (existingBranch != null) {
      if (menuProvider.nearestBranch?.id != existingBranch.id) {
        menuProvider.selectBranch(existingBranch);
      }

      _showOrderTypeSheet();
      return;
    }

    await menuProvider.findNearestBranch();

    if (!mounted) return;

    if (menuProvider.nearestBranch == null) {
      return;
    }

    branchController.selectBranch(menuProvider.nearestBranch!);

    _showOrderTypeSheet();
  }

  void _showOrderTypeSheet({VoidCallback? onCompleted}) {
    final menuProvider = context.read<MenuProvider>();
    final branchController = context.read<BranchController>();

    final selectedBranch =
        branchController.selectedBranch ?? menuProvider.nearestBranch;

    final branchId = selectedBranch?.id;

    if (branchId == null) {
      return;
    }

    if (menuProvider.nearestBranch?.id != selectedBranch!.id) {
      menuProvider.selectBranch(selectedBranch);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isDeliverySelected =
            menuProvider.selectedOrderType == OrderType.delivery;

        final isPickupSelected =
            menuProvider.selectedOrderType == OrderType.pickup;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "How would you like to order?",
                style: AppTextStyles.heading,
              ),

              const SizedBox(height: 6),

              const Text(
                "Choose your preferred order type",
                style: AppTextStyles.bodySecondary,
              ),

              const SizedBox(height: 20),

              // DELIVERY
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await menuProvider.changeOrderType(
                    OrderType.delivery,
                    branchId,
                    context,
                  );

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }

                  onCompleted?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDeliverySelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.foodCardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDeliverySelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isDeliverySelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delivery_dining_outlined,
                        color: AppColors.primary,
                        size: 30,
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Delivery", style: AppTextStyles.body),

                            SizedBox(height: 4),

                            Text(
                              "Get your food delivered to your address",
                              style: AppTextStyles.small,
                            ),
                          ],
                        ),
                      ),

                      if (isDeliverySelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 25,
                        )
                      else
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.iconSecondary,
                          size: 15,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // PICKUP
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await menuProvider.changeOrderType(
                    OrderType.pickup,
                    branchId,
                    context,
                  );

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }

                  onCompleted?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPickupSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.foodCardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPickupSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isPickupSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pickup / Takeaway",
                              style: AppTextStyles.body,
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Pick up your order from the branch",
                              style: AppTextStyles.small,
                            ),
                          ],
                        ),
                      ),

                      if (isPickupSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 25,
                        )
                      else
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.iconSecondary,
                          size: 15,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  void _openSeeAll() {
    late SeeAllScreen seeAllScreen;

    seeAllScreen = SeeAllScreen(
      onClose: _closeOverlay,

      onProductTap: (item, onAddedToCart) {
        context.read<HomeController>().setOverlay(
          ProductDetailScreen(
            item: item,

            onClose: () {
              context.read<HomeController>().setOverlay(seeAllScreen);
            },

            onAddedToCart: () {
              _closeOverlay();
            },
          ),
        );
      },

      onDealTap: (item) {
        context.read<HomeController>().setOverlay(
          DealScreen(
            item: item,

            onClose: () {
              context.read<HomeController>().setOverlay(seeAllScreen);
            },
          ),
        );
      },
    );

    context.read<HomeController>().setOverlay(seeAllScreen);
  }

  void onCategoryChanged(int index) {
    final homeController = context.read<HomeController>();

    // Search ke baad "All types" select karne par
    // search clear kar do taake complete menu render ho.
    if (index == 0 && homeController.searchQuery.trim().isNotEmpty) {
      homeController.resetSearch();
    }

    homeController.setCategory(index);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _menuListKey.currentState?.scrollToCategory(index);
    });
  }

  void _openHome() {
    context.read<HomeController>().setSelectedNavIndex(0);
  }

  void _openCart() {
    context.read<HomeController>().setSelectedNavIndex(1);
  }

  void _openHistory() {
    final auth = context.read<AuthController>();

    if (auth.isSessionLoading) return;

    context.read<HomeController>().setSelectedNavIndex(2);
  }

  void _openProfile() {
    final auth = context.read<AuthController>();

    if (auth.isSessionLoading) return;

    context.read<HomeController>().setSelectedNavIndex(3);
  }

  void _openProductDetail(Menu item) {
    context.read<HomeController>().setOverlay(
      ProductDetailScreen(item: item, onClose: _closeOverlay),
    );
  }

  void _openDeal(Menu item) {
    context.read<HomeController>().setOverlay(
      DealScreen(item: item, onClose: _closeOverlay),
    );
  }

  void _openCheckout() {
    final auth = context.read<AuthController>();

    if (auth.isLoggedIn || auth.isGuest) {
      _showCheckout();
      return;
    }

    context.read<HomeController>().setOverlay(
      LoginScreen(
        onLoginSuccess: _showCheckout,
        onClose: _closeCheckoutToCart,
        onGuestSignup: _openGuestSignup,
      ),
    );
  }

  void _openGuestSignup() {
    final menuProvider = context.read<MenuProvider>();

    context.read<HomeController>().setOverlay(
      GuestSignupScreen(
        restaurantId: menuProvider.restaurantId,

        onClose: _showCheckout,

        onGuestSignupSuccess: () {
          _showCheckout(autoPlaceOrder: true);
        },
      ),
    );
  }

  void _openProfileGuestSignup() {
    final menuProvider = context.read<MenuProvider>();

    context.read<HomeController>().setOverlay(
      GuestSignupScreen(
        restaurantId: menuProvider.restaurantId,

        onClose: () {
          context.read<HomeController>().setSelectedNavIndex(3);
        },

        onGuestSignupSuccess: () {
          context.read<HomeController>().setSelectedNavIndex(3);
        },
      ),
    );
  }

  void _showCheckout({bool autoPlaceOrder = false}) {
    context.read<HomeController>().setOverlay(
      CheckoutScreen(
        autoPlaceOrder: autoPlaceOrder,

        onClose: _closeCheckoutToCart,

        onOrderPlaced: (_, __) {
          context.read<HomeController>().setSelectedNavIndex(2);
        },

        onChangeAddress: _openCheckoutAddressChange,

        onGuestSignup: _openGuestSignup,
      ),
    );
  }

  void _openCheckoutAddressChange() {
    context.read<HomeController>().setOverlay(
      CustomerAddressesScreen(
        selectionOnly: false,

        onClose: () {
          _showCheckout();
        },

        onAddressSelected: (address) async {
          final menuProvider = context.read<MenuProvider>();
          final cartProvider = context.read<CartProvider>();
          final addressController = context.read<AddressController>();

          addressController.selectAddress(address);

          await menuProvider.setDeliveryLocation(
            address: address.address1,
            lat: address.latitude,
            lng: address.longitude,
            orderAmount: cartProvider.subtotal,
          );

          if (!mounted) return;

          _showCheckout();
        },

        onOpenLocation: (int addressTypeId, CustomerAddress? existingAddress) {
          context.read<HomeController>().setOverlay(
            LocationScreen(
              addressTypeId: addressTypeId,
              existingAddress: existingAddress,

              onClose: () {
                _openCheckoutAddressChange();
              },

              onAddressSaved: () async {
                await context.read<AddressController>().getCustomerAddresses();

                if (!mounted) return;

                _openCheckoutAddressChange();
              },
            ),
          );
        },
      ),
    );
  }

  void _openAddresses() {
    context.read<HomeController>().setOverlay(
      CustomerAddressesScreen(
        onClose: () {
          context.read<HomeController>().setSelectedNavIndex(3);
        },

        onAddressSelected: (address) {
          final menuProvider = context.read<MenuProvider>();
          final cartProvider = context.read<CartProvider>();

          menuProvider.setDeliveryLocation(
            address: address.address1,
            lat: address.latitude,
            lng: address.longitude,
            orderAmount: cartProvider.subtotal,
          );

          context.read<HomeController>().setSelectedNavIndex(3);
        },

        onOpenLocation: (int addressTypeId, CustomerAddress? existingAddress) {
          context.read<HomeController>().setOverlay(
            LocationScreen(
              addressTypeId: addressTypeId,
              existingAddress: existingAddress,

              onClose: () {
                _openAddresses();
              },

              onAddressSaved: () async {
                await context.read<AddressController>().getCustomerAddresses();

                if (!mounted) return;

                _openAddresses();
              },
            ),
          );
        },
      ),
    );
  }

  void _openHistoryOrder(OrderHistory order) {
    _showOrderInfo(order);
  }

  void _showOrderInfo(OrderHistory order) {
    context.read<HomeController>().setOverlay(
      OrderInfoScreen(
        orderNumber: order.orderId,
        orderItems: const [],
        order: order,
        onClose: () {
          context.read<HomeController>().setSelectedNavIndex(2);
        },
        onTrackOrder: () {
          _openTracking(order);
        },
      ),
    );
  }

  void _openTracking(OrderHistory order) {
    context.read<HomeController>().setOverlay(
      OrderTrackingScreen(
        orderId: order.id.toString(),
        address: order.address?.address1,
        onClose: () {
          _showOrderInfo(order);
        },
      ),
    );
  }

  void _openLoyaltyHistory() {
    context.read<HomeController>().setOverlay(
      LoyaltyHistoryScreen(
        onClose: () {
          context.read<HomeController>().setSelectedNavIndex(3);
        },

        onRedeemPoints: _openLoyaltyRedemption,
      ),
    );
  }

  void _openLoyaltyRedemption() {
    context.read<HomeController>().setOverlay(
      LoyaltyRedemptionScreen(onClose: _openLoyaltyHistory),
    );
  }

  void _openWalletHistory() {
    context.read<HomeController>().setOverlay(
      WalletHistoryScreen(
        onClose: () {
          context.read<HomeController>().setSelectedNavIndex(3);
        },
      ),
    );
  }

  void _closeOverlay() {
    context.read<HomeController>().closeOverlay();
  }

  void _closeCheckoutToCart() {
    context.read<HomeController>().setSelectedNavIndex(1);
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff292A2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text("Exit App?", style: AppTextStyles.dialogContent),

          content: const Text(
            "Do you want to exit the app?",
            style: AppTextStyles.dialogContent,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                SystemNavigator.pop();
              },
              child: const Text(
                "Exit",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomePage() {
    return Consumer2<MenuProvider, HomeController>(
      builder: (context, provider, homeController, child) {
        if (provider.menuResponse == null && !provider.isLoading) {
          return const SizedBox();
        }

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomHeader(
                onSearchChanged: (query) {
                  homeController.setSearchQuery(query);
                },

                onSearchStateChanged: (isSearching) {
                  homeController.setSearching(isSearching);
                },
              ),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: BannerSlider()),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What do you want to eat today?",
                                    style: AppTextStyles.subtitle,
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    "Choose Your Favorite Food",
                                    style: AppTextStyles.heading,
                                  ),
                                ],
                              ),
                            ),

                            GestureDetector(
                              onTap: _openSeeAll,
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 2, left: 12),
                                child: Text(
                                  "See All",
                                  style: AppTextStyles.action,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                    SliverToBoxAdapter(
                      child: CategoryList(
                        selectedIndex: homeController.selectedCategory,
                        searchQuery: homeController.searchQuery ?? '',
                        isSearching: homeController.isSearching,
                        onCategoryChanged: onCategoryChanged,
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: MenuList(
                        key: _menuListKey,
                        selectedCategoryIndex: homeController.selectedCategory,
                        searchQuery: homeController.searchQuery,
                        isSearching: homeController.isSearching,
                        onCategoryChanged: onCategoryChanged,
                        onProductTap: _openProductDetail,
                        onDealTap: _openDeal,
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartPage() {
    return CartScreen(onClose: _openHome, onCheckout: _openCheckout);
  }

  Widget _buildHistoryPage() {
    final auth = context.watch<AuthController>();

    if (auth.isSessionLoading) {
      return const SizedBox();
    }

    if (!auth.isLoggedIn && !auth.isGuest) {
      return LoginScreen(
        onLoginSuccess: () {
          context.read<HomeController>().setSelectedNavIndex(2);
        },

        onClose: _openHome,

        onGuestSignup: _openGuestSignup,
      );
    }

    return OrderHistoryScreen(
      onClose: _openHome,
      onOrderTap: _openHistoryOrder,
    );
  }

  Widget _buildProfilePage() {
    final auth = context.watch<AuthController>();

    if (auth.isSessionLoading) {
      return const SizedBox();
    }

    if (!auth.isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: () {
          context.read<HomeController>().setSelectedNavIndex(3);
        },

        onClose: _openHome,
        onGuestSignup: _openProfileGuestSignup,
      );
    }

    return ProfileScreen(
      onClose: _openHome,
      onManageOrderType: () {
        _showOrderTypeSheet(onCompleted: _openHome);
      },

      onAddresses: _openAddresses,

      onTrackOrder: (orderNumber) {
        context.read<HomeController>().setOverlay(
          OrderTrackingScreen(
            orderId: orderNumber,
            address: null,
            onClose: _closeOverlay,
          ),
        );
      },

      onLoyaltyPoints: _openLoyaltyHistory,

      onWallet: _openWalletHistory,
      onContent: (type) {
        context.read<HomeController>().setOverlay(
          ContentScreen(type: type, onClose: _closeOverlay),
        );
      },
    );
  }

  Widget _buildCurrentScreen(int selectedNavIndex) {
    switch (selectedNavIndex) {
      case 0:
        return _buildHomePage();

      case 1:
        return _buildCartPage();

      case 2:
        return _buildHistoryPage();

      case 3:
        return _buildProfilePage();

      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, homeController, child) {
        final overlayScreen = homeController.overlayScreen;

        return PopScope(
          canPop: false,

          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (overlayScreen != null) {
              _closeOverlay();
              return;
            }

            if (homeController.selectedNavIndex != 0) {
              _openHome();
              return;
            }

            _showExitDialog();
          },

          child: Scaffold(
            backgroundColor: AppColors.background,

            body: Stack(
              children: [
                Positioned.fill(
                  child: _buildCurrentScreen(homeController.selectedNavIndex),
                ),

                if (overlayScreen != null)
                  Positioned.fill(child: overlayScreen),
              ],
            ),

            bottomNavigationBar: overlayScreen == null
                ? HomeBottomNav(
                    selectedIndex: homeController.selectedNavIndex,

                    onHomeTap: _openHome,

                    onCartTap: _openCart,

                    onHistoryTap: _openHistory,

                    onProfileTap: _openProfile,
                  )
                : null,
          ),
        );
      },
    );
  }
}
