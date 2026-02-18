import 'package:flutter/foundation.dart';
import 'package:seefood/data/canteen_api/canteen_item.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_api.dart';
import 'package:seefood/store/cart/cart_item.dart';
import 'package:seefood/store/cart/cart_repository.dart';
import 'package:seefood/store/cart/server_cart_models.dart';

class CartController extends ChangeNotifier {
  CartController(
    this._repository,
    this._authRepository, {
    CartApi? api,
  }) : _api = api ?? CartApi();

  final CartRepository _repository;
  final AuthRepository _authRepository;
  final CartApi _api;

  List<CartItem> _items = const [];
  int? _canteenId;
  num? _serverTotal;
  final Map<String, int> _serverItemIds = {};

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  num get totalPrice => _serverTotal ??
      _items.fold<num>(
        0,
        (sum, item) => sum + (item.price ?? 0) * item.quantity,
      );

  int? get canteenId => _canteenId;

  bool get isLoggedIn => (_authRepository.getToken() ?? '').trim().isNotEmpty;

  int getQuantity(String itemId) {
    for (final item in _items) {
      if (item.itemId == itemId) return item.quantity;
    }
    return 0;
  }

  Future<void> load() async {
    _items = _repository.getItems();
    _canteenId = _repository.getCanteenId();
    _serverTotal = null;
    _serverItemIds.clear();

    if (isLoggedIn) {
      await _refreshFromServer();
    }
    notifyListeners();
  }

  Future<void> addItem({
    required CanteenItem item,
    required int canteenId,
    int quantity = 1,
  }) async {
    await _ensureCanteen(canteenId);

    if (isLoggedIn) {
      final token = _authRepository.getToken() ?? '';
      final studentId = _authRepository.getStudentId();
      if (token.isNotEmpty && studentId != null) {
        final cart = await _api.addItem(
          studentId: studentId,
          token: token,
          canteenId: canteenId,
          canteenItemId: item.id,
          quantity: quantity,
        );
        await _applyServerCart(cart);
        notifyListeners();
        return;
      }
    }

    await _repository.addItem(
      CartItem(
        itemId: item.id.toString(),
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        quantity: quantity,
      ),
    );
    _items = _repository.getItems();
    notifyListeners();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (isLoggedIn) {
      final token = _authRepository.getToken() ?? '';
      final studentId = _authRepository.getStudentId();
      final serverItemId = _serverItemIds[itemId];
      if (token.isNotEmpty && studentId != null && serverItemId != null) {
        try {
          final cart = quantity <= 0
              ? await _api.removeItem(
                  studentId: studentId,
                  token: token,
                  itemId: serverItemId,
                )
              : await _api.updateItemQuantity(
                  studentId: studentId,
                  token: token,
                  itemId: serverItemId,
                  quantity: quantity,
                );
          await _applyServerCart(cart);
          notifyListeners();
          return;
        } catch (e) {
          if (_isNotFound(e)) {
            await _repository.updateQuantity(itemId: itemId, quantity: quantity);
            _items = _repository.getItems();
            await _forceSyncToServer();
            notifyListeners();
            return;
          }
        }
      }
    }

    await _repository.updateQuantity(itemId: itemId, quantity: quantity);
    _items = _repository.getItems();
    notifyListeners();
  }

  Future<void> removeItem(String itemId) async {
    if (isLoggedIn) {
      final token = _authRepository.getToken() ?? '';
      final studentId = _authRepository.getStudentId();
      final serverItemId = _serverItemIds[itemId];
      if (token.isNotEmpty && studentId != null && serverItemId != null) {
        try {
          final cart = await _api.removeItem(
            studentId: studentId,
            token: token,
            itemId: serverItemId,
          );
          await _applyServerCart(cart);
          notifyListeners();
          return;
        } catch (e) {
          if (_isNotFound(e)) {
            await _repository.removeItem(itemId);
            _items = _repository.getItems();
            await _forceSyncToServer();
            notifyListeners();
            return;
          }
        }
      }
    }

    await _repository.removeItem(itemId);
    _items = _repository.getItems();
    notifyListeners();
  }

  Future<void> clear() async {
    if (isLoggedIn) {
      final token = _authRepository.getToken() ?? '';
      final studentId = _authRepository.getStudentId();
      if (token.isNotEmpty && studentId != null) {
        try {
          await _api.clearCart(studentId: studentId, token: token);
        } catch (_) {
          // ignore network failures for local clear
        }
      }
    }

    await _clearLocal();
    notifyListeners();
  }

  Future<void> syncLocalToServerIfNeeded() async {
    if (!isLoggedIn) return;
    final token = _authRepository.getToken() ?? '';
    final studentId = _authRepository.getStudentId();
    if (token.isEmpty || studentId == null) return;

    final localItems = _repository.getItems();
    final localCanteenId = _repository.getCanteenId();
    if (localItems.isEmpty || localCanteenId == null) {
      await _refreshFromServer();
      return;
    }

    final cart = await _api.syncCart(
      studentId: studentId,
      token: token,
      canteenId: localCanteenId,
      items: localItems
          .map(
            (item) => CartSyncItem(
              canteenItemId: int.tryParse(item.itemId) ?? 0,
              quantity: item.quantity,
            ),
          )
          .where((item) => item.canteenItemId != 0)
          .toList(growable: false),
    );

    await _applyServerCart(cart);
    notifyListeners();
  }

  Future<void> _forceSyncToServer() async {
    if (!isLoggedIn) return;
    final token = _authRepository.getToken() ?? '';
    final studentId = _authRepository.getStudentId();
    if (token.isEmpty || studentId == null) return;

    final localItems = _repository.getItems();
    final localCanteenId = _repository.getCanteenId();
    if (localItems.isEmpty) {
      try {
        await _api.clearCart(studentId: studentId, token: token);
      } catch (_) {
        // ignore
      }
      return;
    }
    if (localCanteenId == null) return;

    final cart = await _api.syncCart(
      studentId: studentId,
      token: token,
      canteenId: localCanteenId,
      items: localItems
          .map(
            (item) => CartSyncItem(
              canteenItemId: int.tryParse(item.itemId) ?? 0,
              quantity: item.quantity,
            ),
          )
          .where((item) => item.canteenItemId != 0)
          .toList(growable: false),
    );
    await _applyServerCart(cart);
  }

  Future<void> _refreshFromServer() async {
    final token = _authRepository.getToken() ?? '';
    final studentId = _authRepository.getStudentId();
    if (token.isEmpty || studentId == null) return;

    try {
      final cart = await _api.fetchCart(studentId: studentId, token: token);
      if (cart != null) {
        await _applyServerCart(cart);
      }
    } catch (_) {
      // keep local state if server fails
    }
  }

  Future<void> _applyServerCart(ServerCart cart) async {
    _canteenId = cart.canteenId;
    _serverTotal = cart.total;
    _serverItemIds
      ..clear()
      ..addEntries(
        cart.items.map(
          (item) => MapEntry(item.canteenItemId.toString(), item.id),
        ),
      );

    _items = cart.items
        .map(
          (item) => CartItem(
            itemId: item.canteenItemId.toString(),
            name: item.canteenItem?.name ?? 'Item',
            price: item.canteenItem?.price,
            imageUrl: item.canteenItem?.imageUrl,
            quantity: item.quantity,
          ),
        )
        .toList(growable: false);

    _serverTotal ??= _items.fold<num>(
      0,
      (sum, item) => sum + (item.price ?? 0) * item.quantity,
    );

    await _repository.replaceItems(_items);
    if (_canteenId != null) {
      await _repository.setCanteenId(_canteenId!);
    }
  }

  Future<void> _ensureCanteen(int canteenId) async {
    if (_canteenId != null && _canteenId != canteenId && _items.isNotEmpty) {
      await clear();
    }
    _canteenId = canteenId;
    await _repository.setCanteenId(canteenId);
  }

  Future<void> _clearLocal() async {
    await _repository.clear();
    _items = [];
    _serverTotal = null;
    _serverItemIds.clear();
    _canteenId = null;
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  bool _isNotFound(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('404') || message.contains('not found');
  }
}
