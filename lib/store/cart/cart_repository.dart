import 'package:hive/hive.dart';
import 'package:seefood/store/cart/cart_item.dart';

class CartRepository {
  static const String _boxName = 'cart_items';
  static const String _metaBoxName = 'cart_meta';
  static const String _canteenIdKey = 'canteenId';

  Box<CartItem>? _box;
  Box<String>? _metaBox;

  Future<void> init() async {
    _box = await Hive.openBox<CartItem>(_boxName);
    _metaBox = await Hive.openBox<String>(_metaBoxName);
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

  Future<void> setCanteenId(int canteenId) async {
    _ensureReady();
    await _metaBox!.put(_canteenIdKey, canteenId.toString());
  }

  int? getCanteenId() {
    if (_metaBox == null) return null;
    final value = _metaBox!.get(_canteenIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> clear() async {
    _ensureReady();
    await _box!.clear();
    await _metaBox!.clear();
  }

  void _ensureReady() {
    if (_box == null || _metaBox == null) {
      throw StateError('CartRepository not initialized. Call init() first.');
    }
  }
}
