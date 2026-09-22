class OrderTrackingResponse {
  final String? errorMessage;
  final String? message;
  final bool? success;
  final Data? data;
  final int? status;

  OrderTrackingResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  factory OrderTrackingResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingResponse(
      errorMessage: json['ErrorMessage']?.toString(),
      message: json['Message']?.toString(),
      success: json['Success'] is bool
          ? json['Success']
          : json['Success']?.toString().toLowerCase() == 'true',
      data: json['Data'] is Map
          ? Data.fromJson(Map<String, dynamic>.from(json['Data']))
          : null,
      status: int.tryParse(json['Status']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ErrorMessage': errorMessage,
      'Message': message,
      'Success': success,
      'Data': data?.toJson(),
      'Status': status,
    };
  }
}

class Data {
  final String? startLatitude;
  final String? startLongitude;
  final String? currentLatitude;
  final String? currentLongitude;
  final String? endLatitude;
  final String? endLongitude;
  final String? address;
  final String? riderName;
  final String? riderContactno;

  Data({
    required this.startLatitude,
    required this.startLongitude,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.address,
    required this.riderName,
    required this.riderContactno,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      startLatitude: _nullableString(json['start_latitude']),
      startLongitude: _nullableString(json['start_longitude']),
      currentLatitude: _nullableString(json['current_latitude']),
      currentLongitude: _nullableString(json['current_longitude']),
      endLatitude: _nullableString(json['end_latitude']),
      endLongitude: _nullableString(json['end_longitude']),
      address: _nullableString(json['address']),
      riderName: _nullableString(json['rider_name']),
      riderContactno: _nullableString(
        json['rider_contactno'] ??
            json['rider_cell'] ??
            json['rider_phone'] ??
            json['delivery_boy_cell'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'address': address,
      'rider_name': riderName,
      'rider_contactno': riderContactno,
    };
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
