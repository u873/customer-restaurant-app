class AuthResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['Success'] == true ||
          json['success'] == true ||
          json['status'] == true,
      message: json['Message']?.toString() ??
          json['message']?.toString() ??
          '',
      data: json['Data'] ?? json['data'],
    );
  }
}