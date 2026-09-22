class DeliveryChargeResponse {
  final String errorMessage;
  final String message;
  final bool success;
  final String data;
  final int status;

  DeliveryChargeResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  factory DeliveryChargeResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryChargeResponse(
      errorMessage: json['ErrorMessage']?.toString() ?? '',
      message: json['Message']?.toString() ?? '',
      success: json['Success'] == true,
      data: json['Data']?.toString() ?? '0',
      status: json['Status'] ?? 0,
    );
  }

  double get deliveryCharge {
    return double.tryParse(data) ?? 0.0;
  }
}