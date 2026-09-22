import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

class OrderRepository {
  final DioClient _dioClient = DioClient(baseUrl: ApiConstants.baseUrlV2);

  final DioClient _promotionClient = DioClient(
    baseUrl: 'https://admin.cherryberryrms.com/v2/api/',
  );

  Future<Map<String, dynamic>> placeOrder({
    required Map<String, dynamic> payload,
    String? token,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.addEditOrder,
      data: payload,
      options: token != null && token.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> validatePromotion({
    required String branchId,
    required int customerId,
    required String couponCode,
    required int orderTypeId,
    required int paymentTypeId,
    required num deliveryFee,
    required List items,
    String? token,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://dev-admin.cherryberrycloud.com/v2/api/',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final body = {
      'branch_id': branchId,
      'customer_id': customerId,
      'code': couponCode,
      'channel': 'mobile',
      'order_type_id': orderTypeId,
      'payment_type_id': paymentTypeId,
      'delivery_fee': deliveryFee,
      'items': items,
    };

    final response = await dio.post(
      'promotions/validate',
      data: body,
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}
