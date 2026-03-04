import 'package:flutter_test/flutter_test.dart';
import 'package:seefood/orders/order_models.dart';

void main() {
  test('OrderItem.fromJson parses nested canteenItem and fields', () {
    final json = {
      'id': 5,
      'quantity': 2,
      'name': 'Custom Name',
      'price': 30,
      'total': 60,
      'canteenItem': {
        'name': 'Canteen Name',
        'price': 25,
        'category': 'Snacks',
        'foodType': 'VEG',
      },
      'status': 'READY',
    };

    final item = OrderItem.fromJson(json);
    expect(item.id, 5);
    expect(item.quantity, 2);
    expect(item.name, 'Custom Name');
    expect(item.canteenItemName, 'Canteen Name');
    expect(item.price, 30);
    expect(item.category, 'Snacks');
    expect(item.foodType, 'VEG');
    expect(item.status, 'READY');
  });

  test('OrderModel.fromJson parses items, canteen and createdAt', () {
    final json = {
      'id': 42,
      'orderId': 'ORD-42',
      'status': 'COMPLETED',
      'total': 120,
      'currency': 'INR',
      'studentId': 7,
      'canteen': {'name': 'Main Canteen'},
      'tokenNumber': 10,
      'createdAt': '2026-03-03T12:34:56.000Z',
      'items': [
        {
          'id': 1,
          'quantity': 1,
          'name': 'Samosa',
        }
      ],
    };

    final order = OrderModel.fromJson(json);
    expect(order.id, 42);
    expect(order.orderId, 'ORD-42');
    expect(order.status, 'COMPLETED');
    expect(order.canteenName, 'Main Canteen');
    expect(order.tokenNumber, 10);
    expect(order.createdAt, isA<DateTime>());
    expect(order.items, hasLength(1));
    expect(order.items.first.name, 'Samosa');
  });
}
