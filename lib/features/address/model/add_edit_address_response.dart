import 'customer_address.dart';

class AddEditAddressResponse {
  final String errorMessage;
  final String message;
  final bool success;
  final CustomerAddress? data;
  final int status;

  AddEditAddressResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  factory AddEditAddressResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return AddEditAddressResponse(
      errorMessage:
      json['ErrorMessage']?.toString() ?? '',
      message:
      json['Message']?.toString() ?? '',
      success:
      json['Success'] == true,
      data: json['Data'] != null
          ? CustomerAddress.fromJson(
        Map<String, dynamic>.from(json['Data']),
      )
          : null,
      status:
      json['Status'] ?? 0,
    );
  }
}