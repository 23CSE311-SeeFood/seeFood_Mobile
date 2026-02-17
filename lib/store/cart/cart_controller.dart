import 'package:flutter/foundation.dart';
import 'package:seefood/store/cart/cart_item.dart';
import 'package:seefood/store/cart/cart_repository.dart';

class CartController extends ChangeNotifier {
  CartController(this._repository);

  final CartRepository _repository;
  List<CartItem> _items = const [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  num get totalPrice => _items.fold(
        0,
        (sum, item) => sum + (item.price ?? 0) * item.quantity,
      );

  int getQuantity(String itemId) {
    for (final item in _items) {
      if (item.itemId == itemId) {
        return item.quantity;
      }
    }
    return 0;
  }

  Future<void> load() async {
    _items = _repository.getItems();
    notifyListeners();
  }

  Future<void> addItem(CartItem item) async {
    await _repository.addItem(item);
    await load();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    await _repository.updateQuantity(itemId: itemId, quantity: quantity);
    await load();
  }

  Future<void> removeItem(String itemId) async {
    await _repository.removeItem(itemId);
    await load();
  }

  Future<void> clear() async {
    await _repository.clear();
    await load();
  }
}
