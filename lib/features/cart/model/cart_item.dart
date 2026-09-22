import 'dart:convert';

class CartChoice {
  final int id;
  final int? groupId;
  final String name;
  final double price;
  final double takeAwayPrice;
  final double deliveryPrice;

  CartChoice({
    required this.id,
    this.groupId,
    required this.name,
    required this.price,
    required this.takeAwayPrice,
    required this.deliveryPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'name': name,
      'price': price,
      'take_away_price': takeAwayPrice,
      'delivery_price': deliveryPrice,
    };
  }

  factory CartChoice.fromMap(Map<String, dynamic> map) {
    return CartChoice(
      id: (map['id'] as num).toInt(),
      groupId: (map['group_id'] as num?)?.toInt(),
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      takeAwayPrice: (map['take_away_price'] as num?)?.toDouble() ?? 0,
      deliveryPrice: (map['delivery_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CartDealItem {
  final int id;
  final String menuId;
  final String name;
  final int quantity;
  final String imageUrl;
  final int? variationId;
  final String? variationName;
  final double? variationPrice;
  final List<CartChoice> selectedChoices;

  CartDealItem({
    required this.id,
    required this.menuId,
    required this.name,
    required this.quantity,
    required this.imageUrl,
    this.variationId,
    this.variationName,
    this.variationPrice,
    this.selectedChoices = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menu_id': menuId,
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl,
      'variation_id': variationId,
      'variation_name': variationName,
      'variation_price': variationPrice,
      'selected_choices': selectedChoices
          .map((choice) => choice.toMap())
          .toList(),
    };
  }

  factory CartDealItem.fromMap(Map<String, dynamic> map) {
    final choicesRaw = map['selected_choices'];

    List<dynamic> choices = [];

    if (choicesRaw is List) {
      choices = choicesRaw;
    } else if (choicesRaw != null && choicesRaw.toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(choicesRaw.toString());

        if (decoded is List) {
          choices = decoded;
        }
      } catch (_) {
        choices = [];
      }
    }

    return CartDealItem(
      id: (map['id'] as num).toInt(),
      menuId: map['menu_id'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: map['image_url'] ?? '',
      variationId: map['variation_id'] != null
          ? (map['variation_id'] as num).toInt()
          : null,
      variationName: map['variation_name'],
      variationPrice: (map['variation_price'] as num?)?.toDouble(),
      selectedChoices: choices
          .map(
            (choice) => CartChoice.fromMap(Map<String, dynamic>.from(choice)),
          )
          .toList(),
    );
  }

  CartDealItem copyWith({
    int? id,
    String? menuId,
    String? name,
    int? quantity,
    String? imageUrl,
    int? variationId,
    String? variationName,
    double? variationPrice,
    List<CartChoice>? selectedChoices,
  }) {
    return CartDealItem(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      variationId: variationId ?? this.variationId,
      variationName: variationName ?? this.variationName,
      variationPrice: variationPrice ?? this.variationPrice,
      selectedChoices: selectedChoices ?? this.selectedChoices,
    );
  }
}

class CartItem {
  final int? id;
  final int menuId;
  final String name;
  final int quantity;

  final double selectedPrice;
  final double deliveryPrice;
  final double takeAwayPrice;

  final String orderType;
  final String imageUrl;

  final int? menuVariationId;
  final String? menuVariationName;

  final bool isDeal;

  final List<CartChoice> selectedChoices;
  final List<CartDealItem> dealItems;

  CartItem({
    this.id,
    required this.menuId,
    required this.name,
    required this.quantity,
    required this.selectedPrice,
    required this.deliveryPrice,
    required this.takeAwayPrice,
    required this.orderType,
    required this.imageUrl,
    this.menuVariationId,
    this.menuVariationName,
    this.isDeal = false,
    this.selectedChoices = const [],
    this.dealItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menu_id': menuId,
      'name': name,
      'quantity': quantity,
      'selected_price': selectedPrice,
      'delivery_price': deliveryPrice,
      'take_away_price': takeAwayPrice,
      'order_type': orderType,
      'image_url': imageUrl,
      'menu_variation_id': menuVariationId,
      'menu_variation_name': menuVariationName,
      'is_deal': isDeal ? 1 : 0,
      'selected_choices': jsonEncode(
        selectedChoices.map((choice) => choice.toMap()).toList(),
      ),
      'deal_items': jsonEncode(
        dealItems.map((dealItem) => dealItem.toMap()).toList(),
      ),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toApiOrderDetail() {
    final choicesTotal = selectedChoices.fold<double>(
      0,
          (total, choice) => total +
          (orderType == "delivery"
              ? choice.deliveryPrice
              : choice.takeAwayPrice),
    );

    final variationPrice = menuVariationId == null
        ? 0.0
        : selectedPrice - choicesTotal;

    return {
      "menu_id": menuId.toString(),
      "menu_name": name,
      "price": selectedPrice.toStringAsFixed(2),
      "quantity": quantity,
      "menu_variation": {
        "id": menuVariationId?.toString() ?? "",
        "name": menuVariationName ?? "",
        "price": variationPrice.toStringAsFixed(2),
        "note": "",
      },
      "order_detail_choice": selectedChoices.map((choice) {
        return {
          "choice_id": choice.id,
          "choice_name": choice.name,
          "price": choice.price.toStringAsFixed(2),
          "choice_group_id": choice.groupId?.toString() ?? "0",
        };
      }).toList(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    final choicesRaw = map['selected_choices'];

    List<dynamic> choices = [];

    if (choicesRaw is List) {
      choices = choicesRaw;
    } else if (choicesRaw != null && choicesRaw.toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(choicesRaw.toString());

        if (decoded is List) {
          choices = decoded;
        }
      } catch (_) {
        choices = [];
      }
    }

    final dealsRaw = map['deal_items'];

    List<dynamic> deals = [];

    if (dealsRaw is List) {
      deals = dealsRaw;
    } else if (dealsRaw != null && dealsRaw.toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(dealsRaw.toString());

        if (decoded is List) {
          deals = decoded;
        }
      } catch (_) {
        deals = [];
      }
    }

    return CartItem(
      id: map['id'] != null ? (map['id'] as num).toInt() : null,
      menuId: (map['menu_id'] as num).toInt(),
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      selectedPrice: (map['selected_price'] as num?)?.toDouble() ?? 0,
      deliveryPrice: (map['delivery_price'] as num?)?.toDouble() ?? 0,
      takeAwayPrice: (map['take_away_price'] as num?)?.toDouble() ?? 0,
      orderType: map['order_type'] ?? '',
      imageUrl: map['image_url'] ?? '',
      menuVariationId: map['menu_variation_id'] != null
          ? (map['menu_variation_id'] as num).toInt()
          : null,
      menuVariationName: map['menu_variation_name'],
      isDeal: map['is_deal'] == 1,
      selectedChoices: choices.map((choice) {
        return CartChoice.fromMap(Map<String, dynamic>.from(choice));
      }).toList(),
      dealItems: deals.map((deal) {
        return CartDealItem.fromMap(Map<String, dynamic>.from(deal));
      }).toList(),
    );
  }

  CartItem copyWith({
    int? id,
    int? menuId,
    String? name,
    int? quantity,
    double? selectedPrice,
    double? deliveryPrice,
    double? takeAwayPrice,
    String? orderType,
    String? imageUrl,
    int? menuVariationId,
    String? menuVariationName,
    bool? isDeal,
    List<CartChoice>? selectedChoices,
    List<CartDealItem>? dealItems,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      selectedPrice: selectedPrice ?? this.selectedPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      takeAwayPrice: takeAwayPrice ?? this.takeAwayPrice,
      orderType: orderType ?? this.orderType,
      imageUrl: imageUrl ?? this.imageUrl,
      menuVariationId: menuVariationId ?? this.menuVariationId,
      menuVariationName: menuVariationName ?? this.menuVariationName,
      isDeal: isDeal ?? this.isDeal,
      selectedChoices: selectedChoices ?? this.selectedChoices,
      dealItems: dealItems ?? this.dealItems,
    );
  }
}
