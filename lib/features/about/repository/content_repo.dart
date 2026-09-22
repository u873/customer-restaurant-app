import 'package:dio/dio.dart';

import '../model/content_model.dart';

class ContentRepo {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dev-admin.cherryberrycloud.com/v2/api/onlineapp/',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<ContentModel> getContent({required int restaurantId}) async {
    final response = await _dio.get(
      'get_restaurant_content',
      queryParameters: {'restaurant_id': restaurantId},
    );

    final data = response.data;

    if (data is! Map<String, dynamic> ||
        data['Success'] != true ||
        data['Data'] is! Map<String, dynamic>) {
      throw Exception(
        data is Map
            ? data['Message']?.toString() ?? 'Unable to fetch content.'
            : 'Invalid response from server.',
      );
    }

    return ContentModel.fromJson(data['Data'] as Map<String, dynamic>);
  }
}
