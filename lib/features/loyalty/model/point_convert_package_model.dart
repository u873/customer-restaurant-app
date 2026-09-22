class PointConvertPackage {
  final String loyaltyWalletPackageId;
  final String name;
  final double points;
  final double amount;
  final int restaurantId;

  PointConvertPackage({
    required this.loyaltyWalletPackageId,
    required this.name,
    required this.points,
    required this.amount,
    required this.restaurantId,
  });

  factory PointConvertPackage.fromJson(Map<String, dynamic> json) {
    return PointConvertPackage(
      loyaltyWalletPackageId:
          json['loyalty_wallet_package_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      points: double.tryParse(json['points']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      restaurantId: int.tryParse(json['restaurant_id']?.toString() ?? '0') ?? 0,
    );
  }
}
