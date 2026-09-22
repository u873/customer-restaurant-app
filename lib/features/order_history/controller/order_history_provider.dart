import 'package:flutter/foundation.dart';

import '../model/order_history_model.dart';
import '../repository/order_history_repo.dart';

class OrderHistoryProvider extends ChangeNotifier {
  final OrderHistoryRepo _repo = OrderHistoryRepo();

  bool _isLoading = false;
  String? _errorMessage;
  List<OrderHistory> _orders = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<OrderHistory> get orders => _orders;

  Future<void> loadOrderHistory({required int restaurantId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _repo.getOrderHistory(restaurantId: restaurantId);

      // Latest / newest order first
      _orders.sort((a, b) {
        final dateA = a.orderDate;
        final dateB = b.orderDate;

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({required int restaurantId}) async {
    await loadOrderHistory(restaurantId: restaurantId);
  }
}
