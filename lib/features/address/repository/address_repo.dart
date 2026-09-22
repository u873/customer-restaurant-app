import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/shared_pref_service.dart';
import '../model/add_edit_address_response.dart';
import '../model/customer_addresses_response.dart';

class AddressRepo {
  final DioClient _dioClient = DioClient();

  Future<Options?> _getAuthOptions() async {
    final isGuest = await SharedPrefService.getGuestStatus();

    final token = isGuest
        ? await SharedPrefService.getGuestToken()
        : await SharedPrefService.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<String?> _getCustomerUuid() async {
    final isGuest = await SharedPrefService.getGuestStatus();

    if (isGuest) {
      return await SharedPrefService.getGuestCustomerUuid();
    }

    return await SharedPrefService.getCustomerUuid();
  }

  Future<CustomerAddressesResponse> getCustomerAddresses() async {
    final options = await _getAuthOptions();

    final response = await _dioClient.dio.get(
      'https://dev-admin.cherryberrycloud.com/v2/api/onlineapp/get_customer_addresses',
      options: options,
    );

    return CustomerAddressesResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AddEditAddressResponse> addEditCustomerAddress({
    required String addressId,
    required int addressTypeId,
    required String address,
    required int townId,
    required int townBlockId,
    required double latitude,
    required double longitude,
    required int isDefault,
  }) async {
    final customerId = await _getCustomerUuid();

    if (customerId == null || customerId.isEmpty) {
      throw Exception(
        "Customer ID not found. Please login or continue as guest.",
      );
    }

    final options = await _getAuthOptions();

    final response = await _dioClient.dio.post(
      'https://dev-admin.cherryberrycloud.com/v2/api/onlineapp/add_edit_customer_address',
      data: {
        "address_id": addressId,
        "customer_id": customerId,
        "address_type_id": addressTypeId,
        "address1": address,
        "town_id": townId,
        "town_block_id": townBlockId,
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "is_default": isDefault,
      },
      options: options,
    );

    return AddEditAddressResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}
