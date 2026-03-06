import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:seefood/orders/orders_api.dart';
import 'package:seefood/orders/order_models.dart';

void main() {
  group('OrdersApi', () {
    test('fetchOrders returns parsed list on 200', () async {
      final sample = [
        {
          'id': 1,
          'orderId': 'ORD1',
          'items': [
            {'id': 11, 'quantity': 1, 'name': 'Item A'}
          ]
        }
      ];

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path.contains('/orders/student/'), isTrue);
        return http.Response(jsonEncode(sample), 200);
      });

      final api = OrdersApi(client: client, baseUrl: 'http://example.com');
      final list = await api.fetchOrders(studentId: 123, token: 'abc');
      expect(list, isA<List<OrderModel>>());
      expect(list, hasLength(1));
      expect(list.first.orderId, 'ORD1');
    });

    test('fetchOrders throws on non-200', () async {
      final client = MockClient((_) async => http.Response('error', 500));
      final api = OrdersApi(client: client, baseUrl: 'http://example.com');
      expect(api.fetchOrders(studentId: 1), throwsException);
    });

    test('fetchOrderDetail returns parsed model on 200', () async {
      final sample = {
        'id': 7,
        'orderId': 'ORD7',
        'items': [
          {'id': 21, 'quantity': 2, 'name': 'Biryani'}
        ]
      };

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response(jsonEncode(sample), 200);
      });

      final api = OrdersApi(client: client, baseUrl: 'http://example.com');
      final order = await api.fetchOrderDetail(orderId: 7);
      expect(order, isA<OrderModel>());
      expect(order.id, 7);
      expect(order.items, hasLength(1));
    });

    test('fetchOrderDetail throws on invalid JSON', () async {
      final client = MockClient((_) async => http.Response('not-json', 200));
      final api = OrdersApi(client: client, baseUrl: 'http://example.com');
      expect(api.fetchOrderDetail(orderId: 1), throwsException);
    });
  });
}
