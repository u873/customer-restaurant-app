class UserModel {
  final int id;
  final String customerId;
  final String name;
  final String email;
  final String phone;
  final String token;
  final int restaurantId;
  final String restaurantName;

  final String? gender;
  final String? dateBirth;

  UserModel({
    required this.id,
    required this.customerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.token,
    required this.restaurantId,
    required this.restaurantName,
    this.gender,
    this.dateBirth,
  });

  factory UserModel.fromJson(
      Map<String, dynamic> json, {
        String fallbackToken = '',
      }) {
    return UserModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['cell_num'] ?? '',
      token: json['token'] ?? fallbackToken,
      restaurantId: json['restaurant_id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      gender: json['gender'],
      dateBirth: json['date_birth'],
    );
  }

  UserModel copyWith({
    int? id,
    String? customerId,
    String? name,
    String? email,
    String? phone,
    String? token,
    int? restaurantId,
    String? restaurantName,
    String? gender,
    String? dateBirth,
  }) {
    return UserModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      gender: gender ?? this.gender,
      dateBirth: dateBirth ?? this.dateBirth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'name': name,
      'email': email,
      'cell_num': phone,
      'token': token,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'gender': gender,
      'date_birth': dateBirth,
    };
  }
}