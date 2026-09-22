import '../../../core/database/database_helper.dart';
import '../model/cart_item.dart';

class CartRepo {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Get all cart items
  Future<List<CartItem>> getCartItems() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'cartitems',
      orderBy: 'id DESC',
    );

    return result.map((map) {
      return CartItem.fromMap(map);
    }).toList();
  }

  // Insert cart item
  Future<int> insertCartItem(CartItem item) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'cartitems',
      item.toMap(),
    );
  }

  // Update cart item
  Future<int> updateCartItem(CartItem item) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'cartitems',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete cart item
  Future<int> deleteCartItem(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete(
      'cartitems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear cart
  Future<int> clearCart() async {
    final db = await _databaseHelper.database;

    return await db.delete('cartitems');
  }

  Future<int> updatePricesByOrderType({
    required String orderType,
    required double price,
  }) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'cartitems',
      {
        'selected_price': price,
        'order_type': orderType,
      },
    );
  }
}