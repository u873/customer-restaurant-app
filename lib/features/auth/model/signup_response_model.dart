class SignupResponseModel {
  final bool success;
  final String message;
  final dynamic data;
  final String? customerId;

  SignupResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.customerId,
  });

  factory SignupResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final data = json['Data'] ?? json['data'];

    String? customerId;

    if (data is Map<String, dynamic>) {
      // Backend verify_otp API expects the 6-digit `id`
      customerId = data['id']?.toString();
    }

    return SignupResponseModel(
      success: json['Success'] == true ||
          json['success'] == true ||
          json['status'] == true,
      message: json['Message']?.toString() ??
          json['message']?.toString() ??
          '',
      data: data,
      customerId: customerId,
    );
  }
}