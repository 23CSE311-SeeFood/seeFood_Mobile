import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seefood/app.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_repository.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Create mock repositories (in a real test, you'd use mocks)
    final cartRepository = CartRepository();
    final authRepository = AuthRepository();

    // Build the app
    await tester.pumpWidget(MyApp(
      cartRepository: cartRepository,
      authRepository: authRepository,
    ));

    // Just check that it builds without error
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
