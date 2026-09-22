class LoyaltyResponse {
  final double loyaltyPoints;
  final List<LoyaltyTransaction> loyaltyTransactions;

  LoyaltyResponse({
    required this.loyaltyPoints,
    required this.loyaltyTransactions,
  });

  factory LoyaltyResponse.fromJson(Map<String, dynamic> json) {
    return LoyaltyResponse(
      loyaltyPoints:
      double.tryParse(json['loyalty_points']?.toString() ?? '0') ?? 0,
      loyaltyTransactions: (json['loyalty_transactions'] as List? ?? [])
          .map(
            (e) => LoyaltyTransaction.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class LoyaltyTransaction {
  LoyaltyTransaction();

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction();
  }
}