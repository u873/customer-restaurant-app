import 'package:customer_estaurant_app/core/api/api_client.dart';
import 'package:customer_estaurant_app/core/api/api_constants.dart';
import 'package:flutter/cupertino.dart';
import '../model/main_data_response.dart';

class MenuRepo {
  final _dio = DioClient(baseUrl: ApiConstants.baseUrlV2).dio;

  Future<MainDataResponse> getMenu(int branchId, int orderResourceId) async {
    try {
      debugPrint('========== MENU API REQUEST ==========');

      debugPrint('branchId: $branchId');

      debugPrint('orderResourceId: $orderResourceId');

      final response = await _dio.get(
        "${ApiConstants.menu}"
        "?restaurant_branch_id=$branchId"
        "&order_resource_id=$orderResourceId",
      );

      final parsedResponse = MainDataResponse.fromJson(response.data);

      debugPrint('========== API CATEGORY ORDER ==========');

      for (
        int i = 0;
        i < parsedResponse.data.restaurantBranchMenu.length;
        i++
      ) {
        final category = parsedResponse.data.restaurantBranchMenu[i];

        debugPrint(
          'API INDEX $i | '
          'ID: ${category.menuCategoryId} | '
          'NAME: ${category.name} | '
          'ITEMS: ${category.menu.length}',
        );
      }

      return parsedResponse;
    } catch (e) {
      rethrow;
    }
  }
}
