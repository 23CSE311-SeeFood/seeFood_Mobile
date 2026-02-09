import 'package:hive/hive.dart';
import 'package:seefood/store/cart/cart_item.dart';

class CartRepository {
  static const String _boxName = 'cart_items';

  Box<CartItem>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<CartItem>(_boxName);
  }

  List<CartItem> getItems() {
    _ensureReady();
    return _box!.values.toList(growable: false);
  }

  Future<void> addItem(CartItem item) async {
    _ensureReady();
    // Use itemId as the Hive key so we can update quantities without scanning.
    final existing = _box!.get(item.itemId);
    if (existing == null) {
      await _box!.put(item.itemId, item);
      return;
    }
    final updated = existing.copyWith(quantity: existing.quantity + item.quantity);
    await _box!.put(item.itemId, updated);
  }

  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    _ensureReady();
    if (quantity <= 0) {
      await _box!.delete(itemId);
      return;
    }
    final existing = _box!.get(itemId);
    if (existing == null) {
      return;
    }
    await _box!.put(itemId, existing.copyWith(quantity: quantity));
  }

  Future<void> removeItem(String itemId) async {
    _ensureReady();
    await _box!.delete(itemId);
  }

  Future<void> clear() async {
    _ensureReady();
    await _box!.clear();
  }

  void _ensureReady() {
    if (_box == null) {
      throw StateError('CartRepository not initialized. Call init() first.');
    }
  }
}
