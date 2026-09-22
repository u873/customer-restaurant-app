import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../model/branch_response.dart';

class BranchRepo {
  final _dio = DioClient().dio;

  Future<BranchResponse> getBranches() async {
    try {
      final response = await _dio.get(ApiConstants.branches);

      return BranchResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}