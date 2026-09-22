class OrderHistoryResponse {
  final List<OrderHistory> orders;

  OrderHistoryResponse({required this.orders});

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List data = json['Data'] ?? [];
    return OrderHistoryResponse(
      orders: data
          .map((e) => OrderHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderHistory {
  final int id;
  final String orderId;
  final String? orderNo;
  final int customerId;
  final int statusId;
  final DateTime? orderDate;
  final int dailyOrderId;
  final double subTotal;
  final double deliveryCharge;
  final double serviceCharge;
  final double discountPer;
  final double discountAmount;
  final bool taxInclude;
  final double taxPercent;
  final double taxAmount;
  final double walletAmount;
  final double total;
  final String? notes;
  final RestaurantBranch restaurantBranch;
  final OrderType orderType;
  final PaymentType paymentType;
  final OrderStatus orderStatus;
  final OrderAddress? address;
  final List<OrderDetail> orderDetails;

  OrderHistory({
    required this.id,
    required this.orderId,
    required this.orderNo,
    required this.customerId,
    required this.statusId,
    required this.orderDate,
    required this.dailyOrderId,
    required this.subTotal,
    required this.deliveryCharge,
    required this.serviceCharge,
    required this.discountPer,
    required this.discountAmount,
    required this.taxInclude,
    required this.taxPercent,
    required this.taxAmount,
    required this.walletAmount,
    required this.total,
    required this.notes,
    required this.restaurantBranch,
    required this.orderType,
    required this.paymentType,
    required this.orderStatus,
    required this.address,
    required this.orderDetails,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id']?.toString() ?? '',
      orderNo: json['order_no']?.toString(),
      customerId: int.tryParse(json['customer_id']?.toString() ?? '0') ?? 0,
      statusId: int.tryParse(json['status_id']?.toString() ?? '0') ?? 0,
      orderDate: DateTime.tryParse(json['order_date']?.toString() ?? ''),
      dailyOrderId: int.tryParse(json['dailyorder_id']?.toString() ?? '0') ?? 0,
      subTotal: _toDouble(json['sub_total']),
      deliveryCharge: _toDouble(json['delivery_charge']),
      serviceCharge: _toDouble(json['service_charge']),
      discountPer: _toDouble(json['discount_per']),
      discountAmount: _toDouble(json['discount_amount']),
      taxInclude:
          json['tax_include'] == true || json['tax_include']?.toString() == '1',
      taxPercent: _toDouble(json['tax_percent']),
      taxAmount: _toDouble(json['tax_amount']),
      walletAmount: _toDouble(json['wallet_amount']),
      total: _toDouble(json['total']),
      notes: json['notes']?.toString(),
      restaurantBranch: RestaurantBranch.fromJson(
        json['restaurant_branch'] ?? {},
      ),
      orderType: OrderType.fromJson(json['order_type'] ?? {}),
      paymentType: PaymentType.fromJson(json['payment_type'] ?? {}),
      orderStatus: OrderStatus.fromJson(json['order_status'] ?? {}),
      address: json['address'] is Map
          ? OrderAddress.fromJson(json['address'])
          : null,
      orderDetails: (json['order_details'] as List? ?? [])
          .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

class RestaurantBranch {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;

  RestaurantBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });

  factory RestaurantBranch.fromJson(Map<String, dynamic> json) {
    return RestaurantBranch(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
    );
  }
}

class OrderType {
  final int id;
  final String type;

  OrderType({required this.id, required this.type});

  factory OrderType.fromJson(Map<String, dynamic> json) {
    return OrderType(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? '',
    );
  }
}

class PaymentType {
  final int id;
  final String type;
  final String description;

  PaymentType({
    required this.id,
    required this.type,
    required this.description,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class OrderStatus {
  final int id;
  final String name;
  final int priority;

  OrderStatus({required this.id, required this.name, required this.priority});

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      priority: int.tryParse(json['priority']?.toString() ?? '0') ?? 0,
    );
  }
}

class OrderAddress {
  final int id;
  final String address1;
  final String addressType;
  final String latitude;
  final String longitude;

  OrderAddress({
    required this.id,
    required this.address1,
    required this.addressType,
    required this.latitude,
    required this.longitude,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      address1: json['address1']?.toString() ?? '',
      addressType: json['address_type']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
    );
  }
}

class OrderDetail {
  final int id;
  final int menuId;
  final String menuName;
  final double price;
  final double quantity;
  final String? note;
  final int orderDetailStatusId;
  final String orderDetailStatus;
  final MenuVariation? menuVariation;
  final List<OrderChoice> choices;
  final List<DealDetail> dealDetails;

  OrderDetail({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.quantity,
    required this.note,
    required this.orderDetailStatusId,
    required this.orderDetailStatus,
    required this.menuVariation,
    required this.choices,
    required this.dealDetails,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      menuId: int.tryParse(json['menu_id']?.toString() ?? '0') ?? 0,
      menuName: json['menu_name']?.toString() ?? '',
      price: _toDouble(json['price']),
      quantity: _toDouble(json['quantity']),
      note: json['note']?.toString(),
      orderDetailStatusId:
          int.tryParse(json['order_detail_status_id']?.toString() ?? '0') ?? 0,
      orderDetailStatus: json['order_detail_status']?.toString() ?? '',
      menuVariation: json['menu_variation'] is Map
          ? MenuVariation.fromJson(json['menu_variation'])
          : null,
      choices: (json['order_detail_choice'] as List? ?? [])
          .map((e) => OrderChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      dealDetails: (json['deal_details'] as List? ?? [])
          .map((e) => DealDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

class MenuVariation {
  final int id;
  final String name;
  final double price;
  final double takeAwayPrice;
  final double deliveryPrice;

  MenuVariation({
    required this.id,
    required this.name,
    required this.price,
    required this.takeAwayPrice,
    required this.deliveryPrice,
  });

  factory MenuVariation.fromJson(Map<String, dynamic> json) {
    return MenuVariation(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      price: _toDouble(json['price']),
      takeAwayPrice: _toDouble(json['take_away_price']),
      deliveryPrice: _toDouble(json['delivery_price']),
    );
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

class OrderChoice {
  final int id;
  final String choiceName;
  final int choiceId;
  final double price;

  OrderChoice({
    required this.id,
    required this.choiceName,
    required this.choiceId,
    required this.price,
  });

  factory OrderChoice.fromJson(Map<String, dynamic> json) {
    return OrderChoice(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      choiceName: json['choice_name']?.toString() ?? '',
      choiceId: int.tryParse(json['choice_id']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}

class DealDetail {
  final int id;
  final int menuId;
  final String menuName;
  final double price;
  final double quantity;

  DealDetail({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.quantity,
  });

  factory DealDetail.fromJson(Map<String, dynamic> json) {
    return DealDetail(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      menuId: int.tryParse(json['menu_id']?.toString() ?? '0') ?? 0,
      menuName: json['menu_name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    );
  }
}
