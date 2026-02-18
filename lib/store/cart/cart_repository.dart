import 'package:hive/hive.dart';
import 'package:seefood/store/cart/cart_item.dart';

class CartRepository {
  static const String _boxName = 'cart_items';
  static const String _metaBoxName = 'cart_meta';
  static const String _canteenIdKey = 'canteen_id';

  Box<CartItem>? _box;
  Box<int>? _metaBox;

  Future<void> init() async {
    _box = await Hive.openBox<CartItem>(_boxName);
    _metaBox = await Hive.openBox<int>(_metaBoxName);
  }

  List<CartItem> getItems() {
    _ensureReady();
    return _box!.values.toList(growable: false);
  }

  int? getCanteenId() {
    if (_metaBox == null) return null;
    return _metaBox!.get(_canteenIdKey);
  }

  Future<void> setCanteenId(int canteenId) async {
    _ensureReady();
    await _metaBox!.put(_canteenIdKey, canteenId);
  }

  Future<void> clearCanteenId() async {
    _ensureReady();
    await _metaBox!.delete(_canteenIdKey);
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

  Future<void> replaceItems(List<CartItem> items) async {
    _ensureReady();
    await _box!.clear();
    for (final item in items) {
      await _box!.put(item.itemId, item);
    }
  }

  Future<void> removeItem(String itemId) async {
    _ensureReady();
    await _box!.delete(itemId);
  }

  Future<void> clear() async {
    _ensureReady();
    await _box!.clear();
    await _metaBox!.delete(_canteenIdKey);
  }

  void _ensureReady() {
    if (_box == null || _metaBox == null) {
      throw StateError('CartRepository not initialized. Call init() first.');
    }
  }
}
