class CouponModel {
  final int couponId;
  final String couponCode;
  final bool isActive;
  final String validFrom;
  final String validTill;
  final double maxOrderAmount;
  final double minOrderAmount;
  final int? noOfOrderAllow;
  final String couponType;
  final int discountId;
  final String discountName;
  final String discountType;
  final double discountValue;
  final bool discountActive;
  final int branchId;
  final int restaurantId;

  CouponModel({
    required this.couponId,
    required this.couponCode,
    required this.isActive,
    required this.validFrom,
    required this.validTill,
    required this.maxOrderAmount,
    required this.minOrderAmount,
    this.noOfOrderAllow,
    required this.couponType,
    required this.discountId,
    required this.discountName,
    required this.discountType,
    required this.discountValue,
    required this.discountActive,
    required this.branchId,
    required this.restaurantId,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      couponId: int.tryParse(
        json['coupon_id']?.toString() ?? '0',
      ) ??
          0,

      couponCode: json['coupon_code']?.toString() ?? '',

      isActive: json['is_active'] == true,

      validFrom: json['valid_from']?.toString() ?? '',

      validTill: json['valid_till']?.toString() ?? '',

      maxOrderAmount: double.tryParse(
        json['max_order_amount']?.toString() ?? '0',
      ) ??
          0.0,

      minOrderAmount: double.tryParse(
        json['min_order_amount']?.toString() ?? '0',
      ) ??
          0.0,

      noOfOrderAllow: json['no_of_order_allow'] == null
          ? null
          : int.tryParse(
        json['no_of_order_allow'].toString(),
      ),

      couponType: json['coupon_type']?.toString() ?? '',

      discountId: int.tryParse(
        json['discount_id']?.toString() ?? '0',
      ) ??
          0,

      discountName: json['discount_name']?.toString() ?? '',

      discountType: json['discount_type']?.toString() ?? '',

      discountValue: double.tryParse(
        json['discount_value']?.toString() ?? '0',
      ) ??
          0.0,

      discountActive: json['discount_active'] == true,

      branchId: int.tryParse(
        json['branch_id']?.toString() ?? '0',
      ) ??
          0,

      restaurantId: int.tryParse(
        json['restaurant_id']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}