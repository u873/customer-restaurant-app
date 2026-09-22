import 'dart:convert';

class BranchResponse {
  String errorMessage;
  String message;
  bool success;
  List<BranchModel> data;
  int status;

  BranchResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  factory BranchResponse.fromRawJson(String str) =>
      BranchResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BranchResponse.fromJson(Map<String, dynamic> json) => BranchResponse(
    errorMessage: json["ErrorMessage"],
    message: json["Message"],
    success: json["Success"],
    data: List<BranchModel>.from(
      json["Data"].map((x) => BranchModel.fromJson(x)),
    ),
    status: json["Status"],
  );

  Map<String, dynamic> toJson() => {
    "ErrorMessage": errorMessage,
    "Message": message,
    "Success": success,
    "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    "Status": status,
  };
}

class BranchModel {
  int id;
  String name;
  String logo;
  String restaurantName;
  String latitude;
  String longitude;
  String address;
  String contactEmail;
  String contactNumber;
  String openTime;
  String closeTime;
  String restaurantBranchId;
  bool restaurantOpen;

  BranchModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.restaurantName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.contactEmail,
    required this.contactNumber,
    required this.openTime,
    required this.closeTime,
    required this.restaurantBranchId,
    required this.restaurantOpen,
  });

  factory BranchModel.fromRawJson(String str) =>
      BranchModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
    id: json["id"],
    name: json["name"],
    logo: json["logo"],
    restaurantName: json["restaurant_name"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    address: json["address"],
    contactEmail: json["contact_email"],
    contactNumber: json["contact_number"],
    openTime: json["open_time"],
    closeTime: json["close_time"],
    restaurantBranchId: json["restaurant_branch_id"],
    restaurantOpen: json["restaurant_open"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "logo": logo,
    "restaurant_name": restaurantName,
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
    "contact_email": contactEmail,
    "contact_number": contactNumber,
    "open_time": openTime,
    "close_time": closeTime,
    "restaurant_branch_id": restaurantBranchId,
    "restaurant_open": restaurantOpen,
  };
}
