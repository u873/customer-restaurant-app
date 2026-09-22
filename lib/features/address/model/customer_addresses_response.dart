import 'customer_address.dart';

class CustomerAddressesResponse {
  final String errorMessage;
  final String message;
  final bool success;
  final List<CustomerAddress> data;
  final int status;

  CustomerAddressesResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  factory CustomerAddressesResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return CustomerAddressesResponse(
      errorMessage:
      json['ErrorMessage']?.toString() ?? '',
      message:
      json['Message']?.toString() ?? '',
      success:
      json['Success'] == true,
      data: (json['Data'] as List? ?? [])
          .map(
            (item) => CustomerAddress.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      status:
      json['Status'] ?? 0,
    );
  }
}