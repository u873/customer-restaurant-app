import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../model/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  Future<void> loadCart() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'cartitems',
      orderBy: 'id DESC',
    );

    _cartItems
      ..clear()
      ..addAll(
        result.map(
              (map) => CartItem.fromMap(map),
        ),
      );

    notifyListeners();
  }


  int get totalItems {
    int total = 0;

    for (final item in _cartItems) {
      total += item.quantity;
    }

    return total;
  }

  double _choicePrice(
      CartChoice choice,
      String orderType,
      ) {
    if (orderType == "delivery") {
      return choice.deliveryPrice;
    }

    return choice.takeAwayPrice;
  }

  double _selectedChoicesTotal(
      CartItem item,
      ) {
    double total = 0;

    for (final choice in item.selectedChoices) {
      total += _choicePrice(
        choice,
        item.orderType,
      );
    }

    return total;
  }
  double _dealItemsTotal(
      CartItem item,
      ) {
    double total = 0;

    for (final dealItem in item.dealItems) {
      for (final choice in dealItem.selectedChoices) {
        total += _choicePrice(
          choice,
          item.orderType,
        );
      }
    }

    return total;
  }

  double itemTotal(
      CartItem item,
      ) {
    double total = item.selectedPrice;

    // Normal product choices
    total += _selectedChoicesTotal(item);

    // Deal selected choices
    if (item.isDeal) {
      total += _dealItemsTotal(item);
    }

    return total * item.quantity;
  }

  double get subtotal {
    double total = 0;
    for (final item in _cartItems) {
      total += itemTotal(item);
    }
    return total;
  }

  Future<void> addToCart(
      CartItem item,
      ) async {
    final db = await DatabaseHelper.instance.database;

    final existingIndex = _cartItems.indexWhere(
          (cartItem) =>
      cartItem.menuId == item.menuId &&
          cartItem.menuVariationId == item.menuVariationId &&
          cartItem.orderType == item.orderType &&
          _sameChoices(
            cartItem.selectedChoices,
            item.selectedChoices,
          ),
    );

    if (existingIndex != -1) {
      final oldItem = _cartItems[existingIndex];

      final updatedItem = oldItem.copyWith(
        quantity: oldItem.quantity + item.quantity,
      );

      await db.update(
        'cartitems',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [oldItem.id],
      );

      _cartItems[existingIndex] = updatedItem;
    }

    else {
      final id = await db.insert(
        'cartitems',
        item.toMap(),
      );

      final newItem = item.copyWith(
        id: id,
      );

      _cartItems.insert(
        0,
        newItem,
      );
    }

    notifyListeners();
  }


  bool _sameChoices(
      List<CartChoice> first,
      List<CartChoice> second,
      ) {
    if (first.length != second.length) {
      return false;
    }

    final firstIds =
    first.map((e) => e.id).toList()..sort();

    final secondIds =
    second.map((e) => e.id).toList()..sort();

    for (int i = 0; i < firstIds.length; i++) {
      if (firstIds[i] != secondIds[i]) {
        return false;
      }
    }

    return true;
  }

  Future<void> increaseQuantity(
      int index,
      ) async {
    if (index < 0 ||
        index >= _cartItems.length) {
      return;
    }
    final item = _cartItems[index];

    final updatedItem = item.copyWith(
      quantity: item.quantity + 1,
    );

    final db = await DatabaseHelper.instance.database;

    await db.update(
      'cartitems',
      updatedItem.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );

    _cartItems[index] = updatedItem;

    notifyListeners();
  }
  Future<void> decreaseQuantity(
      int index,
      ) async {
    if (index < 0 ||
        index >= _cartItems.length) {
      return;
    }

    final item = _cartItems[index];

    final db = await DatabaseHelper.instance.database;

    // Quantity > 1
    if (item.quantity > 1) {
      final updatedItem = item.copyWith(
        quantity: item.quantity - 1,
      );

      await db.update(
        'cartitems',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      _cartItems[index] = updatedItem;
    }

    else {
      await db.delete(
        'cartitems',
        where: 'id = ?',
        whereArgs: [item.id],
      );

      _cartItems.removeAt(index);
    }

    notifyListeners();
  }
  Future<void> removeFromCart(
      int index,
      ) async {
    if (index < 0 ||
        index >= _cartItems.length) {
      return;
    }

    final item = _cartItems[index];

    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'cartitems',
      where: 'id = ?',
      whereArgs: [item.id],
    );

    _cartItems.removeAt(index);

    notifyListeners();
  }
  Future<void> clearCart() async {
    final db = await DatabaseHelper.instance.database;

    await db.delete('cartitems');
    _cartItems.clear();
    notifyListeners();
  }
  Future<void> updatePricesForOrderType({
    required String orderType,
  }) async {
    final db = await DatabaseHelper.instance.database;

    for (int i = 0;
    i < _cartItems.length;
    i++) {
      final item = _cartItems[i];
      double newPrice;

      if (orderType == "delivery") {
        newPrice = item.deliveryPrice;
      } else if (orderType == "takeaway") {
        newPrice = item.takeAwayPrice;
      } else if (orderType == "dinein") {
        newPrice = item.takeAwayPrice;
      } else {
        continue;
      }

      final updatedItem = item.copyWith(
        selectedPrice: newPrice,
        orderType: orderType,
      );

      await db.update(
        'cartitems',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      _cartItems[i] = updatedItem;
    }

    notifyListeners();
  }

  bool containsItem(
      int menuId,
      ) {
    return _cartItems.any(
          (item) => item.menuId == menuId,
    );
  }
  void setCartItems(
      List<CartItem> items,
      ) {
    _cartItems
      ..clear()..addAll(items);

    notifyListeners();
  }
}