import 'dart:convert';

class MainDataResponse {
  String errorMessage;
  String message;
  bool success;
  Data data;
  int status;

  MainDataResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  factory MainDataResponse.fromRawJson(String str) =>
      MainDataResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MainDataResponse.fromJson(Map<String, dynamic> json) =>
      MainDataResponse(
        errorMessage: json["ErrorMessage"],
        message: json["Message"],
        success: json["Success"],
        data: Data.fromJson(json["Data"]),
        status: json["Status"],
      );

  Map<String, dynamic> toJson() => {
    "ErrorMessage": errorMessage,
    "Message": message,
    "Success": success,
    "Data": data.toJson(),
    "Status": status,
  };
}

class Data {
  int id;
  String restaurantBranchId;
  String name;
  String address;
  bool isDelivery;
  bool isDinein;
  bool isFreedelivery;
  int isTakeaway;
  bool taxInclude;
  String taxPercent;
  String? logo;
  String logoUrl;
  String latitude;
  String longitude;
  int? townId;
  int minimumOrderValue;
  dynamic mobileNumber;
  dynamic mobileNumber2;
  dynamic mobileNumber3;
  String? phoneNumber;
  dynamic phoneNumber2;
  dynamic phoneNumber3;
  String contactEmail;
  int deliveryFee;
  int serviceFee;
  int onlineDiscountPercent;
  String currency;
  bool restaurantOpen;
  String openTime;
  String closeTime;
  int isOrderByTown;
  String? facebookProfileUrl;
  String? instagramProfileUrl;
  String? youtubeProfileUrl;
  String? tiktokProfileUrl;
  String? xProfileUrl;
  String? linkedinProfileUrl;
  String? androidAppUrl;
  String? iosAppUrl;
  int isLoyaltyPoint;
  List<RestaurantBranchMenu> restaurantBranchMenu;
  List<Banner> banners;

  Data({
    required this.id,
    required this.restaurantBranchId,
    required this.name,
    required this.address,
    required this.isDelivery,
    required this.isDinein,
    required this.isFreedelivery,
    required this.isTakeaway,
    required this.taxInclude,
    required this.taxPercent,
    required this.logo,
    required this.logoUrl,
    required this.latitude,
    required this.longitude,
    required this.townId,
    required this.minimumOrderValue,
    required this.mobileNumber,
    required this.mobileNumber2,
    required this.mobileNumber3,
    required this.phoneNumber,
    required this.phoneNumber2,
    required this.phoneNumber3,
    required this.contactEmail,
    required this.deliveryFee,
    required this.serviceFee,
    required this.onlineDiscountPercent,
    required this.currency,
    required this.restaurantOpen,
    required this.openTime,
    required this.closeTime,
    required this.isOrderByTown,
    required this.facebookProfileUrl,
    required this.instagramProfileUrl,
    required this.youtubeProfileUrl,
    required this.tiktokProfileUrl,
    required this.xProfileUrl,
    required this.linkedinProfileUrl,
    required this.androidAppUrl,
    required this.iosAppUrl,
    required this.isLoyaltyPoint,
    required this.restaurantBranchMenu,
    required this.banners,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] ?? 0,
    restaurantBranchId: json["restaurant_branch_id"]?.toString() ?? "",
    name: json["name"]?.toString() ?? "",
    address: json["address"]?.toString() ?? "",
    isDelivery: json["is_delivery"] ?? false,
    isDinein: json["is_dinein"] ?? false,
    isFreedelivery: json["is_freedelivery"] ?? false,
    isTakeaway: json["is_takeaway"] ?? 0,
    taxInclude: json["tax_include"] ?? false,
    taxPercent: json["tax_percent"]?.toString() ?? "",
    logo: json["logo"]?.toString(),
    logoUrl: json["logo_url"]?.toString() ?? "",
    latitude: json["latitude"]?.toString() ?? "",
    longitude: json["longitude"]?.toString() ?? "",
    townId: json["town_id"],
    minimumOrderValue: json["minimum_order_value"] ?? 0,

    mobileNumber: json["mobile_number"],
    mobileNumber2: json["mobile_number2"],
    mobileNumber3: json["mobile_number3"],

    phoneNumber: json["phone_number"]?.toString(),
    phoneNumber2: json["phone_number2"],
    phoneNumber3: json["phone_number3"],

    contactEmail: json["contact_email"]?.toString() ?? "",
    deliveryFee: json["delivery_fee"] ?? 0,
    serviceFee: json["service_fee"] ?? 0,
    onlineDiscountPercent: json["online_discount_percent"] ?? 0,
    currency: json["currency"]?.toString() ?? "",
    restaurantOpen: json["restaurant_open"] ?? false,
    openTime: json["open_time"]?.toString() ?? "",
    closeTime: json["close_time"]?.toString() ?? "",
    isOrderByTown: json["is_order_by_town"] ?? 0,

    facebookProfileUrl: json["facebook_profile_url"]?.toString(),
    instagramProfileUrl: json["instagram_profile_url"]?.toString(),
    youtubeProfileUrl: json["youtube_profile_url"]?.toString(),
    tiktokProfileUrl: json["tiktok_profile_url"]?.toString(),
    xProfileUrl: json["x_profile_url"]?.toString(),
    linkedinProfileUrl: json["linkedin_profile_url"]?.toString(),
    androidAppUrl: json["android_app_url"]?.toString(),
    iosAppUrl: json["ios_app_url"]?.toString(),

    isLoyaltyPoint: json["is_loyalty_point"] ?? 0,

    restaurantBranchMenu: (json["restaurant_branch_menu"] as List? ?? [])
        .map((x) => RestaurantBranchMenu.fromJson(x))
        .toList(),

    banners: (json["banners"] as List? ?? [])
        .map((x) => Banner.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_branch_id": restaurantBranchId,
    "name": name,
    "address": address,
    "is_delivery": isDelivery,
    "is_dinein": isDinein,
    "is_freedelivery": isFreedelivery,
    "is_takeaway": isTakeaway,
    "tax_include": taxInclude,
    "tax_percent": taxPercent,
    "logo": logo,
    "logo_url": logoUrl,
    "latitude": latitude,
    "longitude": longitude,
    "town_id": townId,
    "minimum_order_value": minimumOrderValue,
    "mobile_number": mobileNumber,
    "mobile_number2": mobileNumber2,
    "mobile_number3": mobileNumber3,
    "phone_number": phoneNumber,
    "phone_number2": phoneNumber2,
    "phone_number3": phoneNumber3,
    "contact_email": contactEmail,
    "delivery_fee": deliveryFee,
    "service_fee": serviceFee,
    "online_discount_percent": onlineDiscountPercent,
    "currency": currency,
    "restaurant_open": restaurantOpen,
    "open_time": openTime,
    "close_time": closeTime,
    "is_order_by_town": isOrderByTown,
    "facebook_profile_url": facebookProfileUrl,
    "instagram_profile_url": instagramProfileUrl,
    "youtube_profile_url": youtubeProfileUrl,
    "tiktok_profile_url": tiktokProfileUrl,
    "x_profile_url": xProfileUrl,
    "linkedin_profile_url": linkedinProfileUrl,
    "android_app_url": androidAppUrl,
    "ios_app_url": iosAppUrl,
    "is_loyalty_point": isLoyaltyPoint,
    "restaurant_branch_menu": List<dynamic>.from(
      restaurantBranchMenu.map((x) => x.toJson()),
    ),
    "banners": List<dynamic>.from(banners.map((x) => x.toJson())),
  };
}

class Banner {
  int id;
  String name;
  String image;
  String imageUrl;

  Banner({
    required this.id,
    required this.name,
    required this.image,
    required this.imageUrl,
  });

  factory Banner.fromRawJson(String str) => Banner.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    id: json["id"] ?? 0,
    name: json["name"]?.toString() ?? "",
    image: json["image"]?.toString() ?? "",
    imageUrl: json["image_url"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "image_url": imageUrl,
  };
}

class RestaurantBranchMenu {
  String menuCategoryId;
  String name;
  String image;
  String imageUrl;
  List<Menu> menu;

  RestaurantBranchMenu({
    required this.menuCategoryId,
    required this.name,
    required this.image,
    required this.imageUrl,
    required this.menu,
  });

  factory RestaurantBranchMenu.fromRawJson(String str) =>
      RestaurantBranchMenu.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RestaurantBranchMenu.fromJson(Map<String, dynamic> json) =>
      RestaurantBranchMenu(
        menuCategoryId: json["menu_category_id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        image: json["image"]?.toString() ?? "",
        imageUrl: json["image_url"]?.toString() ?? "",
        menu: (json["menu"] as List? ?? [])
            .map((x) => Menu.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    "menu_category_id": menuCategoryId,
    "name": name,
    "image": image,
    "image_url": imageUrl,
    "menu": List<dynamic>.from(menu.map((x) => x.toJson())),
  };
}

class Menu {
  int id;
  String? menuId;
  String name;
  String? price;
  String? takeAwayPrice;
  String? deliveryPrice;
  String? image;
  String imageUrl;
  String? description;
  dynamic ingridient;
  bool? isDeal;
  List<MenuVariation>? menuVariations;
  List<ChoiceGroup> choiceGroup;
  List<Menu>? dealMenuDetails;
  int? quantity;
  MenuVariation? menuVariation;

  Menu({
    required this.id,
    required this.menuId,
    required this.name,
    required this.price,
    required this.takeAwayPrice,
    required this.deliveryPrice,
    required this.image,
    required this.imageUrl,
    required this.description,
    required this.ingridient,
    this.isDeal,
    this.menuVariations,
    required this.choiceGroup,
    this.dealMenuDetails,
    this.quantity,
    this.menuVariation,
  });

  factory Menu.fromRawJson(String str) => Menu.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
    id: json["id"],
    menuId: json["menu_id"]?.toString(),
    name: json["name"] ?? "",
    price: json["price"]?.toString(),
    takeAwayPrice: json["take_away_price"]?.toString(),
    deliveryPrice: json["delivery_price"]?.toString(),
    image: json["image"]?.toString(),
    imageUrl: json["image_url"]?.toString() ?? "",
    description: json["description"],
    ingridient: json["ingridient"],
    isDeal: json["is_deal"],
    menuVariations: json["menu_variations"] == null
        ? []
        : List<MenuVariation>.from(
            json["menu_variations"]!.map((x) => MenuVariation.fromJson(x)),
          ),
    choiceGroup: List<ChoiceGroup>.from(
      json["choice_group"].map((x) => ChoiceGroup.fromJson(x)),
    ),
    dealMenuDetails: json["deal_menu_details"] == null
        ? []
        : List<Menu>.from(
            json["deal_menu_details"]!.map((x) => Menu.fromJson(x)),
          ),
    quantity: json["quantity"],
    menuVariation: json["menu_variation"] == null
        ? null
        : MenuVariation.fromJson(json["menu_variation"]),
  );

  // for add to cart
  Menu copyWith({
    int? id,
    String? menuId,
    String? name,
    String? price,
    String? takeAwayPrice,
    String? deliveryPrice,
    String? image,
    String? imageUrl,
    String? description,
    dynamic ingridient,
    bool? isDeal,
    List<MenuVariation>? menuVariations,
    List<ChoiceGroup>? choiceGroup,
    List<Menu>? dealMenuDetails,
    int? quantity,
    MenuVariation? menuVariation,
  }) {
    return Menu(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      name: name ?? this.name,
      price: price ?? this.price,
      takeAwayPrice: takeAwayPrice ?? this.takeAwayPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      ingridient: ingridient ?? this.ingridient,
      isDeal: isDeal ?? this.isDeal,
      menuVariations: menuVariations ?? this.menuVariations,
      choiceGroup: choiceGroup ?? this.choiceGroup,
      dealMenuDetails: dealMenuDetails ?? this.dealMenuDetails,
      quantity: quantity ?? this.quantity,
      menuVariation: menuVariation ?? this.menuVariation,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "menu_id": menuId,
    "name": name,
    "price": price,
    "take_away_price": takeAwayPrice,
    "delivery_price": deliveryPrice,
    "image": image,
    "image_url": imageUrl,
    "description": description,
    "ingridient": ingridient,
    "is_deal": isDeal,
    "menu_variations": menuVariations == null
        ? []
        : List<dynamic>.from(menuVariations!.map((x) => x.toJson())),
    "choice_group": List<dynamic>.from(choiceGroup.map((x) => x.toJson())),
    "deal_menu_details": dealMenuDetails == null
        ? []
        : List<dynamic>.from(dealMenuDetails!.map((x) => x.toJson())),
    "quantity": quantity,
    "menu_variation": menuVariation?.toJson(),
  };
}

class MenuVariation {
  int id;
  String name;
  String price;
  String takeAwayPrice;
  String deliveryPrice;
  List<ChoiceGroup>? choiceGroups;

  MenuVariation({
    required this.id,
    required this.name,
    required this.price,
    required this.takeAwayPrice,
    required this.deliveryPrice,
    this.choiceGroups,
  });

  factory MenuVariation.fromRawJson(String str) =>
      MenuVariation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MenuVariation.fromJson(Map<String, dynamic> json) => MenuVariation(
    id: json["id"],
    name: json["name"],
    price: json["price"],
    takeAwayPrice: json["take_away_price"],
    deliveryPrice: json["delivery_price"],
    choiceGroups: json["choice_groups"] == null
        ? []
        : List<ChoiceGroup>.from(
            json["choice_groups"]!.map((x) => ChoiceGroup.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "take_away_price": takeAwayPrice,
    "delivery_price": deliveryPrice,
    "choice_groups": choiceGroups == null
        ? []
        : List<dynamic>.from(choiceGroups!.map((x) => x.toJson())),
  };
}

class ChoiceGroup {
  int id;
  String name;
  int minChoices;
  int maxChoices;
  List<MenuVariation> choices;

  ChoiceGroup({
    required this.id,
    required this.name,
    required this.minChoices,
    required this.maxChoices,
    required this.choices,
  });

  factory ChoiceGroup.fromRawJson(String str) =>
      ChoiceGroup.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChoiceGroup.fromJson(Map<String, dynamic> json) => ChoiceGroup(
    id: json["id"],
    name: json["name"],
    minChoices: json["min_choices"],
    maxChoices: json["max_choices"],
    choices: List<MenuVariation>.from(
      json["choices"].map((x) => MenuVariation.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "min_choices": minChoices,
    "max_choices": maxChoices,
    "choices": List<dynamic>.from(choices.map((x) => x.toJson())),
  };
}
