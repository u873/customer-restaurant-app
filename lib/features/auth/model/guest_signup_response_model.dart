class GuestSignupResponseModel {
  final String errorMessage;
  final String message;
  final bool success;
  final GuestUserData? data;
  final int status;

  GuestSignupResponseModel({
    required this.errorMessage,
    required this.message,
    required this.success,
    this.data,
    required this.status,
  });

  factory GuestSignupResponseModel.fromJson(Map<String, dynamic> json) {
    return GuestSignupResponseModel(
      errorMessage: json['ErrorMessage']?.toString() ?? '',
      message: json['Message']?.toString() ?? '',
      success: json['Success'] == true,
      data: json['Data'] != null
          ? GuestUserData.fromJson(Map<String, dynamic>.from(json['Data']))
          : null,
      status: json['Status'] is int
          ? json['Status']
          : int.tryParse(json['Status']?.toString() ?? '') ?? 0,
    );
  }
}

class GuestUserData {
  final int id;
  final String customerId;
  final String name;
  final String email;
  final String cellNum;
  final String token;
  final int restaurantId;
  final String restaurantName;
  final int isGuest;

  GuestUserData({
    required this.id,
    required this.customerId,
    required this.name,
    required this.email,
    required this.cellNum,
    required this.token,
    required this.restaurantId,
    required this.restaurantName,
    required this.isGuest,
  });

  factory GuestUserData.fromJson(Map<String, dynamic> json) {
    return GuestUserData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,

      customerId: json['customer_id']?.toString() ?? '',

      name: json['name']?.toString() ?? '',

      email: json['email']?.toString() ?? '',

      cellNum: json['cell_num']?.toString() ?? '',

      token: json['token']?.toString() ?? '',

      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id']
          : int.tryParse(json['restaurant_id']?.toString() ?? '') ?? 0,

      restaurantName: json['restaurant_name']?.toString() ?? '',

      isGuest: json['is_guest'] is int
          ? json['is_guest']
          : int.tryParse(json['is_guest']?.toString() ?? '') ?? 0,
    );
  }
}
