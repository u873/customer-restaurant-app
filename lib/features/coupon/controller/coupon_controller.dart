import 'package:flutter/material.dart';

import '../model/coupon_model.dart';
import '../repository/coupon_repository.dart';

class CouponController extends ChangeNotifier {
  final CouponRepository _couponRepository;

  CouponController({
    CouponRepository? couponRepository,
  }) : _couponRepository =
      couponRepository ?? CouponRepository();

  List<CouponModel> _coupons = [];

  CouponModel? _validatedCoupon;

  bool _isLoading = false;
  bool _isValidating = false;

  String? _errorMessage;

  List<CouponModel> get coupons => _coupons;

  CouponModel? get validatedCoupon => _validatedCoupon;

  bool get isLoading => _isLoading;

  bool get isValidating => _isValidating;

  String? get errorMessage => _errorMessage;

  bool get hasCoupons => _coupons.isNotEmpty;

  Future<bool> getCouponsByUserId({
    required String userId,
    required String branchId,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _coupons = await _couponRepository.getCouponsByUserId(
        userId: userId,
        branchId: branchId,
      );

      return true;
    } catch (e) {
      _coupons = [];

      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validateCoupon({
    required String userId,
    required String branchId,
    required String couponCode,
  }) async {
    _isValidating = true;
    _errorMessage = null;
    _validatedCoupon = null;

    notifyListeners();

    try {
      final coupon = await _couponRepository.validateCoupon(
        userId: userId,
        branchId: branchId,
        couponCode: couponCode.trim(),
      );

      _validatedCoupon = coupon;

      if (coupon == null) {
        _errorMessage = 'Invalid coupon';
        return false;
      }

      return true;
    } catch (e) {
      _validatedCoupon = null;

      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  void clearValidatedCoupon() {
    _validatedCoupon = null;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}