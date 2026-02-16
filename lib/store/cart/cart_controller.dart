import 'package:flutter/foundation.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_api.dart';
import 'package:seefood/store/cart/cart_item.dart';
import 'package:seefood/store/cart/cart_repository.dart';
import 'package:seefood/store/cart/server_cart_models.dart';

class CartController extends ChangeNotifier {
  CartController(this._localRepository, this._authRepository)
      : _api = CartApi();

  final CartRepository _localRepository;
  final AuthRepository _authRepository;
  final CartApi _api;
  List<CartItem> _items = const [];
  List<ServerCartItem> _serverItems = const [];
  int? _canteenId;
  num? _serverTotal;

  List<CartItem> get items => List.unmodifiable(_items);

  int? get canteenId => _canteenId;

  bool get isLoggedIn =>
      (_authRepository.getToken() ?? '').trim().isNotEmpty;

  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  num get totalPrice =>
      _serverTotal ??
      _items.fold(0, (sum, item) => sum + (item.price ?? 0) * item.quantity);

  int getQuantity(String itemId) {
    for (final item in _items) {
      if (item.itemId == itemId) {
        return item.quantity;
      }
    }
    return 0;
  }

  Future<void> load() async {
    if (isLoggedIn) {
      final studentId = _authRepository.getStudentId();
      if (studentId != null) {
        final cart = await _api.getCart(studentId);
        if (cart == null) {
          _items = const [];
          _serverItems = const [];
          _serverTotal = 0;
          _canteenId = null;
        } else {
          _applyServerCart(cart);
        }
        notifyListeners();
        return;
      }
    }
    _serverTotal = null;
    _serverItems = const [];
    _canteenId = _localRepository.getCanteenId();
    _items = _localRepository.getItems();
    notifyListeners();
  }

  Future<void> addItem({
    required CartItem item,
    required int canteenId,
  }) async {
    if (isLoggedIn) {
      final studentId = _authRepository.getStudentId();
      if (studentId != null) {
        if (_canteenId != null && _canteenId != canteenId) {
          await _api.clearCart(studentId);
        }
        final cart = await _api.addItem(
          studentId: studentId,
          canteenId: canteenId,
          canteenItemId: int.parse(item.itemId),
          quantity: item.quantity,
        );
        _applyServerCart(cart);
        notifyListeners();
        return;
      }
    }

    final existingCanteenId = _localRepository.getCanteenId();
    if (existingCanteenId != null && existingCanteenId != canteenId) {
      await _localRepository.clear();
    }
    await _localRepository.setCanteenId(canteenId);
    await _localRepository.addItem(item);
    _items = _localRepository.getItems();
    _serverTotal = null;
    _canteenId = _localRepository.getCanteenId();
    notifyListeners();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (isLoggedIn) {
      final studentId = _authRepository.getStudentId();
      if (studentId != null) {
        final canteenItemId = int.tryParse(itemId);
        if (canteenItemId == null) return;

        final serverItem = _serverItems.firstWhere(
          (item) => item.canteenItemId == canteenItemId,
          orElse: () => ServerCartItem(
            id: -1,
            canteenItemId: canteenItemId,
            quantity: 0,
            canteenItem: ServerCanteenItem(
              id: canteenItemId,
              name: '',
              price: 0,
            ),
          ),
        );

        if (serverItem.id == -1) {
          if (quantity > 0 && _canteenId != null) {
            final cart = await _api.addItem(
              studentId: studentId,
              canteenId: _canteenId!,
              canteenItemId: canteenItemId,
              quantity: quantity,
            );
            _applyServerCart(cart);
            notifyListeners();
          }
          return;
        }

        if (quantity <= 0) {
          final cart = await _api.removeItem(
            studentId: studentId,
            cartItemId: serverItem.id,
          );
          _applyServerCart(cart);
          notifyListeners();
          return;
        }

        final cart = await _api.updateQuantity(
          studentId: studentId,
          cartItemId: serverItem.id,
          quantity: quantity,
        );
        _applyServerCart(cart);
        notifyListeners();
        return;
      }
    }

    await _localRepository.updateQuantity(itemId: itemId, quantity: quantity);
    _items = _localRepository.getItems();
    _serverTotal = null;
    _canteenId = _localRepository.getCanteenId();
    notifyListeners();
  }

  Future<void> removeItem(String itemId) async {
    if (isLoggedIn) {
      final studentId = _authRepository.getStudentId();
      if (studentId != null) {
        final canteenItemId = int.tryParse(itemId);
        if (canteenItemId == null) return;
        final serverItem = _serverItems.firstWhere(
          (item) => item.canteenItemId == canteenItemId,
          orElse: () => ServerCartItem(
            id: -1,
            canteenItemId: canteenItemId,
            quantity: 0,
            canteenItem: ServerCanteenItem(
              id: canteenItemId,
              name: '',
              price: 0,
            ),
          ),
        );
        if (serverItem.id == -1) return;

        final cart = await _api.removeItem(
          studentId: studentId,
          cartItemId: serverItem.id,
        );
        _applyServerCart(cart);
        notifyListeners();
        return;
      }
    }

    await _localRepository.removeItem(itemId);
    _items = _localRepository.getItems();
    _serverTotal = null;
    _canteenId = _localRepository.getCanteenId();
    notifyListeners();
  }

  Future<void> clear() async {
    if (isLoggedIn) {
      final studentId = _authRepository.getStudentId();
      if (studentId != null) {
        await _api.clearCart(studentId);
        _items = const [];
        _serverItems = const [];
        _serverTotal = 0;
        _canteenId = null;
        notifyListeners();
        return;
      }
    }

    await _localRepository.clear();
    _items = const [];
    _serverTotal = null;
    _canteenId = null;
    notifyListeners();
  }

  Future<void> syncLocalToServerIfNeeded() async {
    if (!isLoggedIn) return;
    final studentId = _authRepository.getStudentId();
    if (studentId == null) return;

    final localItems = _localRepository.getItems();
    if (localItems.isEmpty) return;
    final localCanteenId = _localRepository.getCanteenId();
    if (localCanteenId == null) return;

    final items = localItems
        .map((item) => {
              'canteenItemId': int.parse(item.itemId),
              'quantity': item.quantity,
            })
        .toList();

    final cart = await _api.syncCart(
      studentId: studentId,
      canteenId: localCanteenId,
      items: items,
    );
    await _localRepository.clear();
    _applyServerCart(cart);
    notifyListeners();
  }

  void _applyServerCart(ServerCart cart) {
    _serverItems = cart.items;
    _serverTotal = cart.total;
    _canteenId = cart.canteenId;
    _items = cart.items
        .map(
          (item) => CartItem(
            itemId: item.canteenItemId.toString(),
            name: item.canteenItem.name,
            price: item.canteenItem.price,
            quantity: item.quantity,
          ),
        )
        .toList(growable: false);
  }
}
