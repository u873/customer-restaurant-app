import 'package:flutter/foundation.dart';

import '../model/loyalty_transaction_model.dart';
import '../model/point_convert_package_model.dart';
import '../model/wallet_model.dart';
import '../repository/loyalty_repo.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyRepo _repo = LoyaltyRepo();

  bool _isLoading = false;
  bool _isRedeeming = false;

  String? _errorMessage;
  String? _successMessage;

  double _loyaltyPoints = 0;
  double _walletAmount = 0;

  List<LoyaltyTransaction> _loyaltyTransactions = [];
  List<PointConvertPackage> _packages = [];
  List<WalletTransaction> _walletTransactions = [];

  bool get isLoading => _isLoading;

  bool get isRedeeming => _isRedeeming;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  double get loyaltyPoints => _loyaltyPoints;

  double get walletAmount => _walletAmount;

  List<LoyaltyTransaction> get loyaltyTransactions => _loyaltyTransactions;

  List<PointConvertPackage> get packages => _packages;

  List<WalletTransaction> get walletTransactions => _walletTransactions;

  Future<void> loadLoyaltyData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repo.getLoyaltyTransactions();

      _loyaltyPoints = response.loyaltyPoints;
      _loyaltyTransactions = response.loyaltyTransactions;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _packages = await _repo.getPointConvertPackages();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> redeemPackage(String packageId) async {
    _isRedeeming = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await _repo.convertLoyaltyPointsToWallet(packageId);

      if (success) {
        _successMessage = 'Loyalty points converted to wallet successfully.';

        // Refresh both balances after redemption.
        await loadLoyaltyData();
        await loadWalletData();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isRedeeming = false;
      notifyListeners();
    }
  }

  Future<void> loadWalletData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repo.getWalletTransactions();

      _walletAmount = response.walletAmount;
      _walletTransactions = response.walletTransactions;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
