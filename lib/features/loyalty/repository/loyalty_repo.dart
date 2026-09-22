import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../model/loyalty_transaction_model.dart';
import '../model/point_convert_package_model.dart';
import '../model/wallet_model.dart';

class LoyaltyRepo {
  final _dio = DioClient().dio;

  Future<LoyaltyResponse> getLoyaltyTransactions() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrlV2}${ApiConstants.getLoyaltyTransactions}',
      );

      return LoyaltyResponse.fromJson(response.data['Data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PointConvertPackage>> getPointConvertPackages() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrlV2}${ApiConstants.getPointConvertPackages}',
      );

      final List data = response.data['Data'] ?? [];

      return data
          .map(
            (e) => PointConvertPackage.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> convertLoyaltyPointsToWallet(
      String packageId,
      ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrlV2}${ApiConstants.convertLoyaltyPointsToWallet}',
        data: {
          'loyalty_wallet_package_id': packageId,
        },
      );

      return response.data['Success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<WalletResponse> getWalletTransactions() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrlV2}${ApiConstants.getWalletTransactions}',
      );

      return WalletResponse.fromJson(response.data['Data']);
    } catch (e) {
      rethrow;
    }
  }
}