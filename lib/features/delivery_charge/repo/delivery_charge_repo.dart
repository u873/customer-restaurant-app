import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../model/delivery_charge_response.dart';

class DeliveryChargeRepo {
  final DioClient _dioClient = DioClient();

  Future<DeliveryChargeResponse> getDeliveryCharges({
    required int branchId,
    required double latitude,
    required double longitude,
    required double orderAmount,
  }) async {
    final response = await _dioClient.dio.post(
      'https://dev-admin.cherryberrycloud.com/api/GetDeliveryCharges',
      data: {
        "branch_id": branchId.toString(),
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "order_amt": orderAmount.toString(),
      },
    );

    return DeliveryChargeResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}