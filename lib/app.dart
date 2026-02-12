import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/pages/homePage.dart';
import 'package:seefood/pages/loginPage.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/store/cart/cart_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.cartRepository,
    required this.authRepository,
  });

  final CartRepository cartRepository;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CartRepository>.value(value: cartRepository),
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider<CartController>(
          create: (_) => CartController(cartRepository)..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _AuthGate(authRepository: authRepository),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    final token = authRepository.getToken();
    if (token != null && token.isNotEmpty) {
      return const Homepage();
    }
    return const LoginPage();
  }
}
