import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../address/model/customer_address.dart';
import '../repository/order_repository.dart';

class CheckoutController extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  int _selectedPayment = 0;
  bool _isPlacingOrder = false;
  bool _useWalletBalance = false;
  bool _isValidatingPromotion = false;

  CustomerAddress? _selectedAddress;

  Map<String, dynamic>? _promotionResponse;
  String? _promotionError;

  int get selectedPayment => _selectedPayment;

  bool get isPlacingOrder => _isPlacingOrder;

  bool get useWalletBalance => _useWalletBalance;

  CustomerAddress? get selectedAddress => _selectedAddress;

  bool get isValidatingPromotion => _isValidatingPromotion;

  Map<String, dynamic>? get promotionResponse => _promotionResponse;

  String? get promotionError => _promotionError;

  Map<String, dynamic>? get promotionData {
    final data = _promotionResponse?['Data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  int? get promotionCouponId {
    final value = promotionData?['legacy_compat']?['coupon_id'];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  int? get promotionDiscountId {
    final value = promotionData?['legacy_compat']?['discount_id'];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  double get promotionDiscountAmount {
    final value = promotionData?['legacy_compat']?['discount_amount'];

    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  double get promotionDiscountPercent {
    final value = promotionData?['legacy_compat']?['discount_per'];

    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  String? get promotionDiscountType {
    return promotionData?['legacy_compat']?['discount_type']?.toString();
  }
  String? get promotionCode {
    final promotions = promotionData?['promotions'];

    if (promotions is List && promotions.isNotEmpty) {
      final first = promotions.first;

      if (first is Map) {
        return first['code']?.toString();
      }
    }

    return null;
  }

  void setSelectedPayment(int value) {
    if (_selectedPayment == value) return;

    _selectedPayment = value;
    notifyListeners();
  }

  void setPlacingOrder(bool value) {
    if (_isPlacingOrder == value) return;

    _isPlacingOrder = value;
    notifyListeners();
  }

  void setWalletBalance(bool value) {
    if (_useWalletBalance == value) return;

    _useWalletBalance = value;
    notifyListeners();
  }

  void setSelectedAddress(CustomerAddress? address) {
    if (_selectedAddress == address) return;

    _selectedAddress = address;
    notifyListeners();
  }

  void clearSelectedAddress() {
    if (_selectedAddress == null) return;

    _selectedAddress = null;
    notifyListeners();
  }

  Future<bool> validatePromotion({
    required String branchId,
    required int customerId,
    required String couponCode,
    required int orderTypeId,
    required int paymentTypeId,
    required num deliveryFee,
    required List items,
    String? token,
  }) async {
    if (_isValidatingPromotion) return false;

    _isValidatingPromotion = true;
    _promotionError = null;
    notifyListeners();

    try {
      final response = await _orderRepository.validatePromotion(
        branchId: branchId,
        customerId: customerId,
        couponCode: couponCode,
        orderTypeId: orderTypeId,
        paymentTypeId: paymentTypeId,
        deliveryFee: deliveryFee,
        items: items,
        token: token,
      );

      _promotionResponse = response;

      final success =
          response['Success'] == true || response['success'] == true;

      if (!success) {
        _promotionError =
            response['Message']?.toString() ??
            response['message']?.toString() ??
            response['ErrorMessage']?.toString() ??
            'Coupon validation failed.';

        return false;
      }

      final data = response['Data'];

      if (data is Map) {
        final innerSuccess = data['success'];

        if (innerSuccess == false) {
          _promotionError =
              data['error']?.toString() ??
              data['messages']?.toString() ??
              'Coupon validation failed.';

          return false;
        }
      }

      return true;
    } on DioException catch (error) {
      final data = error.response?.data;

      _promotionError = data is Map
          ? (data['Message'] ??
                    data['message'] ??
                    data['ErrorMessage'] ??
                    'Promotion validation failed.')
                .toString()
          : 'Promotion validation failed.';

      return false;
    } catch (error) {
      _promotionError = error.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      _isValidatingPromotion = false;
      notifyListeners();
    }
  }

  void clearPromotion() {
    _promotionResponse = null;
    _promotionError = null;
    notifyListeners();
  }
}
