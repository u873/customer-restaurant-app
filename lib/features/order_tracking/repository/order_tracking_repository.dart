import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

class OrderTrackingRepository {
  final Dio _dio = DioClient(
    baseUrl: ApiConstants.baseUrlV2,
  ).dio;

  Future<Response?> getOrderTracking(String orderId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getTrackingHistory,
        queryParameters: {
          'order_id': orderId,
        },
      );

      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }
}