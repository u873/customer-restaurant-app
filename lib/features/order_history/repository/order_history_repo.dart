import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/storage/shared_pref_service.dart';
import '../model/order_history_model.dart';

class OrderHistoryRepo {
  final _dio = DioClient().dio;

  Future<Options?> _getAuthOptions() async {
    final isGuest = await SharedPrefService.getGuestStatus();

    final token = isGuest
        ? await SharedPrefService.getGuestToken()
        : await SharedPrefService.getToken();

    print("========== ORDER HISTORY AUTH ==========");
    print("IS GUEST: $isGuest");
    print("TOKEN: $token");
    print("TOKEN EXISTS: ${token != null && token.isNotEmpty}");

    if (token == null || token.isEmpty) {
      print("NO TOKEN FOUND");
      return null;
    }
    print("AUTHORIZATION WILL BE SENT");

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<OrderHistory>> getOrderHistory({
    required int restaurantId,
  }) async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '${ApiConstants.baseUrlV2}${ApiConstants.getOrderHistory}',
      queryParameters: {'restaurant_id': restaurantId},
      options: options,
    );
    return OrderHistoryResponse.fromJson(response.data).orders;
  }
}
