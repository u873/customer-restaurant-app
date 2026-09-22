class WalletResponse {
  final double walletAmount;
  final List<WalletTransaction> walletTransactions;

  WalletResponse({
    required this.walletAmount,
    required this.walletTransactions,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      walletAmount:
          double.tryParse(json['wallet_amount']?.toString() ?? '0') ?? 0,
      walletTransactions: (json['wallet_transactions'] as List? ?? [])
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WalletTransaction {
  WalletTransaction();

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction();
  }
}
