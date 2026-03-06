import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:seefood/rooms/room_api.dart';
import 'package:seefood/rooms/room_models.dart';

void main() {
  group('RoomApi', () {
    test('createRoom returns parsed response on 201', () async {
      final sample = {
        'roomId': 1,
        'code': 'ABC123',
        'canteenId': 5,
        'expiresAt': '2026-03-05T12:00:00Z',
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/rooms/create');
        expect(request.headers['Content-Type'], 'application/json');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['ownerId'], 123);
        return http.Response(jsonEncode(sample), 201);
      });

      final api = RoomApi(client: client, baseUrl: 'http://example.com');
      final response = await api.createRoom(ownerId: 123);
      expect(response, isA<RoomCreateResponse>());
      expect(response.roomId, 1);
      expect(response.code, 'ABC123');
    });

    test('createRoom throws on non-2xx with body', () async {
      final client = MockClient((_) async => http.Response('{"error": "Invalid"}', 400));
      final api = RoomApi(client: client, baseUrl: 'http://example.com');
      expect(api.createRoom(ownerId: 123), throwsException);
    });

    test('joinRoom succeeds on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/rooms/join');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['code'], 'ABC123');
        expect(body['studentId'], 456);
        return http.Response('', 200);
      });

      final api = RoomApi(client: client, baseUrl: 'http://example.com');
      await api.joinRoom(code: 'ABC123', studentId: 456);
    });

    test('fetchRoom returns parsed model on 200', () async {
      final sample = {
        'id': 1,
        'code': 'ABC123',
        'status': 'OPEN',
        'canteenId': 5,
        'expiresAt': '2026-03-05T12:00:00Z',
        'members': [],
        'allPaid': false,
      };

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/rooms/ABC123');
        return http.Response(jsonEncode(sample), 200);
      });

      final api = RoomApi(client: client, baseUrl: 'http://example.com');
      final room = await api.fetchRoom(code: 'ABC123');
      expect(room, isA<RoomModel>());
      expect(room.code, 'ABC123');
    });

    test('createMemberPayment returns parsed response on 201', () async {
      final sample = {
        'razorpay': {
          'orderId': 'order_123',
          'amount': 1000,
          'currency': 'INR',
          'key': 'rzp_test_key',
        }
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/rooms/ABC123/pay/create');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['studentId'], 456);
        return http.Response(jsonEncode(sample), 201);
      });

      final api = RoomApi(client: client, baseUrl: 'http://example.com');
      final response = await api.createMemberPayment(code: 'ABC123', studentId: 456);
      expect(response, isA<RoomPayCreateResponse>());
      expect(response.orderId, 'order_123');
    });

    test('verifyMemberPayment succeeds on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/rooms/ABC123/pay/verify');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['studentId'], 456);
        expect(body['razorpay_order_id'], 'order_123');
        expect(body['razorpay_payment_id'], 'pay_456');
        expect(body['razorpay_signature'], 'sig_789');
        return http.Response('', 200);
      });

      final api = RoomApi(client: client, baseUrl: 'http://example.com');
      await api.verifyMemberPayment(
        code: 'ABC123',
        studentId: 456,
        orderId: 'order_123',
        paymentId: 'pay_456',
        signature: 'sig_789',
      );
    });
  });
}