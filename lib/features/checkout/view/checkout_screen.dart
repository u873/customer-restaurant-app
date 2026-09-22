import 'dart:convert';

import 'package:customer_estaurant_app/features/cart/model/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../address/controller/address_controller.dart';
import '../../address/model/customer_address.dart';
import '../../auth/controller/auth_controller.dart';
import '../../cart/controller/cart_controller.dart';
import '../../coupon/controller/coupon_controller.dart';
import '../../menu/controller/menu_controller.dart';
import '../../loyalty/provider/loyalty_provider.dart';
import '../controller/checkout_controller.dart';
import '../repository/order_repository.dart';

class CheckoutScreen extends StatelessWidget {
  final VoidCallback? onClose;

  final void Function(String orderNumber, List<CartItem> orderItems)?
  onOrderPlaced;

  final VoidCallback? onChangeAddress;
  final VoidCallback? onGuestSignup;
  final bool autoPlaceOrder;

  const CheckoutScreen({
    super.key,
    this.onClose,
    this.onOrderPlaced,
    this.onChangeAddress,
    this.onGuestSignup,
    this.autoPlaceOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutController(),
      child: _CheckoutContent(
        onClose: onClose,
        onOrderPlaced: onOrderPlaced,
        onChangeAddress: onChangeAddress,
        onGuestSignup: onGuestSignup,
        autoPlaceOrder: autoPlaceOrder,
      ),
    );
  }
}

class _CheckoutContent extends StatefulWidget {
  final VoidCallback? onClose;

  final void Function(String orderNumber, List<CartItem> orderItems)?
  onOrderPlaced;

  final VoidCallback? onChangeAddress;
  final VoidCallback? onGuestSignup;
  final bool autoPlaceOrder;

  const _CheckoutContent({
    this.onClose,
    this.onOrderPlaced,
    this.onChangeAddress,
    this.onGuestSignup,
    this.autoPlaceOrder = false,
  });

  @override
  State<_CheckoutContent> createState() => _CheckoutContentState();
}

class _CheckoutContentState extends State<_CheckoutContent> {
  final OrderRepository _orderRepository = OrderRepository();

  final TextEditingController couponTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final addressController = context.read<AddressController>();
      final menuProvider = context.read<MenuProvider>();
      final cartProvider = context.read<CartProvider>();
      final loyaltyProvider = context.read<LoyaltyProvider>();
      final authController = context.read<AuthController>();
      final couponController = context.read<CouponController>();

      final canUseCustomerFeatures =
          authController.isLoggedIn || authController.isGuest;

      if (canUseCustomerFeatures) {
        await addressController.getCustomerAddresses();

        if (!mounted) return;

        final selected = addressController.selectedAddress;

        if (selected != null) {
          context.read<CheckoutController>().setSelectedAddress(selected);

          await menuProvider.setDeliveryLocation(
            address: selected.address1,
            lat: selected.latitude,
            lng: selected.longitude,
            orderAmount: cartProvider.subtotal,
          );
        }

        final branchId =
            menuProvider.nearestBranch?.id ??
            menuProvider.menuResponse?.data.id ??
            0;

        final int? customerId = authController.isLoggedIn
            ? authController.user?.id
            : authController.isGuest
            ? authController.guestCustomerNumericId
            : null;

        if (customerId != null && branchId != 0) {
          await couponController.getCouponsByUserId(
            userId: customerId.toString(),
            branchId: branchId.toString(),
          );
        }
      }

      if (AppConstants.enableLoyaltySystem && authController.isLoggedIn) {
        await loyaltyProvider.loadWalletData();
      }

      if (menuProvider.selectedOrderType == OrderType.delivery &&
          menuProvider.selectedLat != null &&
          menuProvider.selectedLng != null) {
        await menuProvider.getDeliveryCharges(
          orderAmount: cartProvider.subtotal,
        );
      }

      if (widget.autoPlaceOrder) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _placeOrder();
          }
        });
      }
    });
  }

  String _getAddressTypeName(CustomerAddress? address) {
    if (address == null) {
      return "Delivery Address";
    }

    switch (address.addressTypeId) {
      case 3:
        return "Home";
      case 4:
        return "Flat";
      case 5:
        return "Office";
      default:
        return "Delivery Address";
    }
  }

  List<Map<String, dynamic>> _buildPromotionItems(List<CartItem> cartItems) {
    return cartItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return {
        'line_id': 'line_${index + 1}',
        'menu_id': item.menuId,
        'menu_variation_id': item.menuVariationId,
        'qty': item.quantity,
        'unit_price': item.selectedPrice,
      };
    }).toList();
  }

  Future<void> _applyCoupon() async {
    final code = couponTextController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showMessage("Please enter a coupon code.");
      return;
    }

    final authController = context.read<AuthController>();
    final menuProvider = context.read<MenuProvider>();
    final cartProvider = context.read<CartProvider>();
    final checkoutController = context.read<CheckoutController>();

    final int? customerId = authController.isLoggedIn
        ? authController.user?.id
        : authController.isGuest
        ? authController.guestCustomerNumericId
        : null;

    final branchId =
        menuProvider.nearestBranch?.id ??
        menuProvider.menuResponse?.data.id ??
        0;

    if (customerId == null) {
      _showMessage("Please login or continue as guest first.");
      return;
    }

    if (branchId == 0) {
      _showMessage("Restaurant branch is not selected.");
      return;
    }

    if (cartProvider.cartItems.isEmpty) {
      _showMessage("Your cart is empty.");
      return;
    }

    final isDelivery = menuProvider.selectedOrderType == OrderType.delivery;

    final orderTypeId = isDelivery ? 3 : 2;

    final paymentTypeId = checkoutController.selectedPayment + 1;

    final deliveryFee = isDelivery ? menuProvider.deliveryCharge : 0.0;

    final token = authController.isLoggedIn
        ? authController.token
        : authController.guestToken;

    checkoutController.clearPromotion();

    final success = await checkoutController.validatePromotion(
      branchId: branchId.toString(),
      customerId: customerId,
      couponCode: code,
      orderTypeId: orderTypeId,
      paymentTypeId: paymentTypeId,
      deliveryFee: deliveryFee,
      items: _buildPromotionItems(cartProvider.cartItems),
      token: token,
    );

    if (!mounted) return;

    if (success) {
      couponTextController.text = code;

      final discount = checkoutController.promotionDiscountAmount;

      _showMessage(
        "Coupon applied. Discount: Rs ${discount.toStringAsFixed(2)}",
      );
    } else {
      _showMessage(
        checkoutController.promotionError ?? "Coupon validation failed.",
      );
    }
  }

  void _selectCoupon(String couponCode) {
    couponTextController.text = couponCode;
    _applyCoupon();
  }

  void _removeCoupon() {
    couponTextController.clear();

    context.read<CouponController>().clearValidatedCoupon();

    context.read<CheckoutController>().clearPromotion();
  }

  Future<void> _placeOrder() async {
    final checkoutController = context.read<CheckoutController>();

    if (checkoutController.isPlacingOrder) return;

    final cartProvider = context.read<CartProvider>();
    final menuProvider = context.read<MenuProvider>();
    final authController = context.read<AuthController>();
    final addressController = context.read<AddressController>();
    final loyaltyProvider = context.read<LoyaltyProvider>();

    if (cartProvider.cartItems.isEmpty) {
      _showMessage("Your cart is empty.");
      return;
    }

    final bool isNormalUser = authController.isLoggedIn;
    final bool isGuestUser = authController.isGuest;

    if (!isNormalUser && !isGuestUser) {
      widget.onGuestSignup?.call();
      return;
    }

    final int? customerId = isNormalUser
        ? authController.user?.id
        : isGuestUser
        ? authController.guestCustomerNumericId
        : null;

    if (customerId == null || customerId == 0) {
      _showMessage("Customer information is missing. Please try again.");
      return;
    }

    final String? customerToken = isNormalUser
        ? authController.token
        : isGuestUser
        ? authController.guestToken
        : null;

    if (customerToken == null || customerToken.isEmpty) {
      _showMessage("Session expired. Please login or continue as guest again.");
      return;
    }

    final isDelivery = menuProvider.selectedOrderType == OrderType.delivery;

    final address =
        checkoutController.selectedAddress ?? addressController.selectedAddress;

    if (isDelivery && address == null) {
      _showMessage("Please select a delivery address first.");
      return;
    }

    final branchId =
        menuProvider.nearestBranch?.id ??
        menuProvider.menuResponse?.data.id ??
        0;

    if (branchId == 0) {
      _showMessage("Restaurant branch is not selected.");
      return;
    }

    final subtotal = cartProvider.subtotal;

    final deliveryCharge = isDelivery ? menuProvider.deliveryCharge : 0.0;

    final promotionDiscount = checkoutController.promotionDiscountAmount;

    final discountPer = checkoutController.promotionDiscountPercent;

    final discountId = checkoutController.promotionDiscountId ?? 0;

    final couponId = checkoutController.promotionCouponId;

    final taxBase = (subtotal - promotionDiscount).clamp(0.0, subtotal);

    final tax = taxBase * 16 / 116;

    final grandTotal = subtotal - promotionDiscount + deliveryCharge + tax;

    double walletAmount = 0.0;

    if (AppConstants.enableLoyaltySystem &&
        isNormalUser &&
        checkoutController.useWalletBalance) {
      walletAmount = loyaltyProvider.walletAmount.clamp(0.0, grandTotal);
    }

    final amountToPay = (grandTotal - walletAmount).clamp(0.0, grandTotal);

    final payload = {
      "notes": "",
      "order_resource": "3",
      "restaurant_branch_id": branchId.toString(),
      "customer_id": customerId,
      "discount_amount": promotionDiscount.toStringAsFixed(2),
      "discount_per": discountPer.toStringAsFixed(2),
      "discount_id": discountId,
      "coupon_id": couponId,
      "tax_amount": double.parse(tax.toStringAsFixed(2)),
      "tax_percent": "16.00",
      "tax_include": "1",
      "delivery_charge": deliveryCharge.toStringAsFixed(2),
      "total": grandTotal.toStringAsFixed(2),
      "cash_amount": amountToPay.toStringAsFixed(2),
      "wallet_amount": walletAmount.toStringAsFixed(2),
      "sub_total": subtotal.toStringAsFixed(2),
      "order_type_id": isDelivery ? 3 : 2,
      "payment_type_id": checkoutController.selectedPayment + 1,
      "delivery_address_id": isDelivery ? address!.id : 0,
      "order_details": cartProvider.cartItems
          .map((item) => item.toApiOrderDetail())
          .toList(),
    };

    checkoutController.setPlacingOrder(true);

    try {
      final response = await _orderRepository.placeOrder(
        payload: payload,
        token: customerToken,
      );

      final success =
          response['Success'] == true ||
          response['success'] == true ||
          response['status'] == true;

      if (!success) {
        throw Exception(
          response['Message']?.toString() ??
              response['message']?.toString() ??
              response['ErrorMessage']?.toString() ??
              "Order placement failed.",
        );
      }

      final responseData = response['Data'] ?? response['data'];

      final orderNumber = responseData is Map
          ? (responseData['order_number'] ??
                    responseData['order_no'] ??
                    responseData['order_id'] ??
                    responseData['id'] ??
                    "-")
                .toString()
          : "-";

      final orderItems = List<CartItem>.from(cartProvider.cartItems);

      await cartProvider.clearCart();

      if (AppConstants.enableLoyaltySystem &&
          isNormalUser &&
          checkoutController.useWalletBalance) {
        await loyaltyProvider.loadWalletData();
      }

      if (!mounted) return;

      widget.onOrderPlaced?.call(orderNumber, orderItems);
    } on DioException catch (error) {
      final data = error.response?.data;

      _showMessage(
        data is Map
            ? (data['ErrorMessage'] ??
                      data['Message'] ??
                      data['message'] ??
                      "Order request failed.")
                  .toString()
            : "Order request failed "
                  "(${error.response?.statusCode ?? "network error"}).",
      );
    } catch (error) {
      _showMessage(error.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        checkoutController.setPlacingOrder(false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    couponTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    final menuProvider = context.watch<MenuProvider>();

    final loyaltyProvider = context.watch<LoyaltyProvider>();

    final addressController = context.watch<AddressController>();

    final couponController = context.watch<CouponController>();

    final checkoutController = context.watch<CheckoutController>();

    final subtotal = cartProvider.subtotal;

    final isDelivery = menuProvider.selectedOrderType == OrderType.delivery;

    final deliveryCharges = isDelivery ? menuProvider.deliveryCharge : 0.0;

    final promotionDiscount = checkoutController.promotionDiscountAmount;

    final taxBase = (subtotal - promotionDiscount).clamp(0.0, subtotal);

    final tax = taxBase * 16 / 116;

    final grandTotal = subtotal - promotionDiscount + deliveryCharges + tax;

    final walletBalance = loyaltyProvider.walletAmount;

    final walletAmountUsed =
        AppConstants.enableLoyaltySystem && checkoutController.useWalletBalance
        ? walletBalance.clamp(0.0, grandTotal)
        : 0.0;

    final amountToPay = (grandTotal - walletAmountUsed).clamp(0.0, grandTotal);

    final selectedAddress =
        checkoutController.selectedAddress ?? addressController.selectedAddress;

    final promotionApplied =
        checkoutController.promotionResponse != null &&
        checkoutController.promotionDiscountAmount > 0;

    final appliedCoupon = couponController.validatedCoupon;

    final promotionCode = couponTextController.text.trim();

    final showAppliedCoupon = promotionApplied || appliedCoupon != null;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        leading: IconButton(
          onPressed: widget.onClose,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.iconPrimary,
            size: 18,
          ),
        ),

        title: const Text(
          "Checkout",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        top: false,

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Order Type",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                height: 38,
                padding: const EdgeInsets.all(4),

                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final provider = context.read<MenuProvider>();

                          await provider.changeOrderType(
                            OrderType.delivery,
                            provider.nearestBranch?.id ??
                                provider.menuResponse?.data.id ??
                                0,
                            context,
                          );

                          if (!mounted) return;

                          final checkout = context.read<CheckoutController>();

                          checkout.clearPromotion();
                        },

                        child: Container(
                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            color:
                                menuProvider.selectedOrderType ==
                                    OrderType.delivery
                                ? AppColors.primary
                                : AppColors.transparent,

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: const Text(
                            "Delivery",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final provider = context.read<MenuProvider>();

                          await provider.changeOrderType(
                            OrderType.pickup,
                            provider.nearestBranch?.id ??
                                provider.menuResponse?.data.id ??
                                0,
                            context,
                          );

                          if (!mounted) return;

                          context
                              .read<CheckoutController>()
                              .clearSelectedAddress();

                          context.read<CheckoutController>().clearPromotion();
                        },

                        child: Container(
                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            color:
                                menuProvider.selectedOrderType ==
                                    OrderType.pickup
                                ? AppColors.primary
                                : AppColors.transparent,

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: const Text(
                            "Pickup",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (isDelivery) ...[
                const Text(
                  "Delivery Address",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedAddress != null
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              _getAddressTypeName(selectedAddress),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              selectedAddress?.address1 ??
                                  "Choose your delivery location",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: widget.onChangeAddress,

                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),

                          child: Text(
                            "CHANGE",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
              ],

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),

                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: showAppliedCoupon
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,

                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),

                        const SizedBox(width: 9),

                        const Expanded(
                          child: Text(
                            "Coupon",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (showAppliedCoupon)
                          GestureDetector(
                            onTap: _removeCoupon,

                            child: const Text(
                              "REMOVE",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    if (showAppliedCoupon)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(9),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 17,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                promotionCode.isNotEmpty
                                    ? promotionCode
                                    : appliedCoupon?.couponCode ?? "Coupon",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            Text(
                              checkoutController.promotionDiscountType ==
                                      "Percentage"
                                  ? "${checkoutController.promotionDiscountPercent.toStringAsFixed(0)}% OFF"
                                  : "Rs ${checkoutController.promotionDiscountAmount.toStringAsFixed(0)} OFF",

                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,

                              child: TextField(
                                controller: couponTextController,
                                textCapitalization:
                                    TextCapitalization.characters,

                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 10,
                                ),

                                decoration: InputDecoration(
                                  hintText: "Enter coupon code",

                                  hintStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                  ),

                                  filled: true,

                                  fillColor: AppColors.background,

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 7),

                          SizedBox(
                            height: 40,

                            child: ElevatedButton(
                              onPressed:
                                  checkoutController.isValidatingPromotion
                                  ? null
                                  : _applyCoupon,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textOnPrimary,
                                elevation: 0,

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),

                              child: checkoutController.isValidatingPromotion
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    )
                                  : const Text(
                                      "Apply",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      if (couponController.coupons.isNotEmpty) ...[
                        const SizedBox(height: 9),

                        const Text(
                          "Available",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        SizedBox(
                          height: 45,

                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,

                            itemCount: couponController.coupons.take(5).length,

                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 7),

                            itemBuilder: (context, index) {
                              final coupon = couponController.coupons[index];

                              return InkWell(
                                onTap: () {
                                  _selectCoupon(coupon.couponCode);
                                },

                                borderRadius: BorderRadius.circular(9),

                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 105,
                                  ),

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: AppColors.border),
                                  ),

                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      Container(
                                        width: 27,
                                        height: 27,

                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.10,
                                          ),
                                          shape: BoxShape.circle,
                                        ),

                                        child: const Icon(
                                          Icons.local_offer_outlined,
                                          color: AppColors.primary,
                                          size: 13,
                                        ),
                                      ),

                                      const SizedBox(width: 6),

                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,

                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            coupon.couponCode,

                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          const SizedBox(height: 2),

                                          Text(
                                            coupon.discountType == "Percentage"
                                                ? "${coupon.discountValue.toStringAsFixed(0)}% OFF"
                                                : "Rs ${coupon.discountValue.toStringAsFixed(0)} OFF",

                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 7,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              if (AppConstants.enableLoyaltySystem) ...[
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: checkoutController.useWalletBalance
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),

                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,

                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "Use Wallet Balance",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              "Available: Rs. "
                              "${walletBalance.toStringAsFixed(2)}",

                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Switch(
                        value: checkoutController.useWalletBalance,

                        activeColor: AppColors.primary,

                        onChanged: walletBalance <= 0
                            ? null
                            : (value) {
                                context
                                    .read<CheckoutController>()
                                    .setWalletBalance(value);
                              },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              const Text(
                "Order Summary",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    ...cartProvider.cartItems.map((item) {
                      final price = item.selectedPrice;

                      final quantity = item.quantity;

                      final itemTotal = price * quantity;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 9),

                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),

                              child: SizedBox(
                                width: 42,
                                height: 42,

                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,

                                  errorBuilder: (_, _, _) {
                                    return Container(
                                      color: AppColors.iconSecondary,

                                      child: const Icon(
                                        Icons.fastfood,
                                        size: 22,
                                        color: AppColors.textTertiary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 9),

                            Expanded(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,

                              children: [
                                Text(
                                  "Rs "
                                  "${itemTotal.toStringAsFixed(2)}",

                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  "Quantity: "
                                  "$quantity",

                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 12, color: AppColors.border),

                    _SummaryRow(
                      title: "Subtotal",
                      value: "Rs ${subtotal.toStringAsFixed(2)}",
                    ),

                    const SizedBox(height: 8),

                    if (promotionDiscount > 0) ...[
                      _SummaryRow(
                        title: "Coupon Discount",
                        value: "- Rs ${promotionDiscount.toStringAsFixed(2)}",
                        valueColor: AppColors.primary,
                      ),

                      const SizedBox(height: 8),
                    ],

                    if (isDelivery) ...[
                      _SummaryRow(
                        title: "Delivery Fee",
                        value: "Rs ${deliveryCharges.toStringAsFixed(2)}",
                      ),

                      const SizedBox(height: 8),
                    ],

                    _SummaryRow(
                      title: "Taxes",
                      value: "Rs ${tax.toStringAsFixed(2)}",
                    ),

                    if (walletAmountUsed > 0) ...[
                      const SizedBox(height: 8),

                      _SummaryRow(
                        title: "Wallet Balance",
                        value: "- Rs ${walletAmountUsed.toStringAsFixed(2)}",
                        valueColor: AppColors.primary,
                      ),
                    ],

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Grand Total",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Text(
                          "Rs ${grandTotal.toStringAsFixed(2)}",

                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    if (walletAmountUsed > 0) ...[
                      const SizedBox(height: 8),

                      const Divider(height: 1, color: AppColors.border),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Amount to Pay",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Text(
                            "Rs ${amountToPay.toStringAsFixed(2)}",

                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),

        child: SizedBox(
          height: 50,
          width: double.infinity,

          child: ElevatedButton(
            onPressed: checkoutController.isPlacingOrder ? null : _placeOrder,

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),

            child: checkoutController.isPlacingOrder
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : const Text(
                    "Place Order",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 8),
        ),

        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textSecondary,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
