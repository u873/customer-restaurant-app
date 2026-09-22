class CustomerAddress {
  final int id;
  final String customerId;
  final int customerIdd;
  final String addressId;
  final int addressTypeId;
  final String addressType;
  final String address1;
  final int townId;
  final int townBlockId;
  final double latitude;
  final double longitude;
  final int isDefault;

  CustomerAddress({
    required this.id,
    required this.customerId,
    required this.customerIdd,
    required this.addressId,
    required this.addressTypeId,
    required this.addressType,
    required this.address1,
    required this.townId,
    required this.townBlockId,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] ?? 0,
      customerId: json['customer_id']?.toString() ?? '',
      customerIdd: json['customer_idd'] ?? 0,
      addressId: json['address_id']?.toString() ?? '',
      addressTypeId: json['address_type_id'] ?? 0,
      addressType: json['address_type']?.toString() ?? '',
      address1: json['address1']?.toString() ?? '',
      townId: json['town_id'] ?? 0,
      townBlockId: json['town_block_id'] ?? 0,
      latitude: double.tryParse(
        json['latitude']?.toString() ?? '',
      ) ??
          0.0,
      longitude: double.tryParse(
        json['longitude']?.toString() ?? '',
      ) ??
          0.0,
      isDefault: json['is_default'] ?? 0,
    );
  }
}