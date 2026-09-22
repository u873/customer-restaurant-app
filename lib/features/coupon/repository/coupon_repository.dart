import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../model/coupon_model.dart';

class CouponRepository {
  final DioClient _dioClient;

  CouponRepository({
    DioClient? dioClient,
  }) : _dioClient = dioClient ?? DioClient();

  Future<List<CouponModel>> getCouponsByUserId({
    required String userId,
    required String branchId,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        'GetCouponsByUserId',
        queryParameters: {
          'user_id': userId,
          'branch_id': branchId,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid coupons response');
      }

      final success = data['Success'] == true;

      if (!success) {
        throw Exception(
          data['Message']?.toString() ??
              data['ErrorMessage']?.toString() ??
              'Failed to fetch coupons',
        );
      }

      final couponData = data['Data'];

      if (couponData is! List) {
        return [];
      }

      return couponData
          .map(
            (item) => CouponModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? e.response?.data['Message']?.toString() ??
            'Failed to fetch coupons'
            : e.message ?? 'Failed to fetch coupons',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CouponModel?> validateCoupon({
    required String userId,
    required String branchId,
    required String couponCode,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'GetValidateCoupon',
        data: {
          'user_id': userId,
          'branch_id': branchId,
          'coupon_code': couponCode,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid coupon response');
      }

      final success = data['Success'] == true;

      if (!success) {
        throw Exception(
          data['Message']?.toString() ??
              data['ErrorMessage']?.toString() ??
              'Invalid coupon',
        );
      }

      final couponData = data['Data'];

      if (couponData == null) {
        return null;
      }

      return CouponModel.fromJson(
        Map<String, dynamic>.from(couponData),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? e.response?.data['Message']?.toString() ??
            'Failed to validate coupon'
            : e.message ?? 'Failed to validate coupon',
      );
    } catch (e) {
      rethrow;
    }
  }
}