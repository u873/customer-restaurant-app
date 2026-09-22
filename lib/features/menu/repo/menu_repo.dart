import 'package:customer_estaurant_app/core/api/api_client.dart';
import 'package:customer_estaurant_app/core/api/api_constants.dart';
import '../model/main_data_response.dart';

class MenuRepo {
  final _dio = DioClient(
    baseUrl: ApiConstants.baseUrlV2,
  ).dio;

  Future<MainDataResponse> getMenu(int branchId,
      int orderResourceId,
      ) async {

    try{
      final response = await _dio.get(
          "${ApiConstants.menu}?restaurant_branch_id=$branchId&order_resource_id=$orderResourceId",
      );

      return MainDataResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
    }
  }
