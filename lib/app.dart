import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/pages/loginPage.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/store/cart/cart_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.cartRepository});

  final CartRepository cartRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CartRepository>.value(value: cartRepository),
        ChangeNotifierProvider<CartController>(
          create: (_) => CartController(cartRepository)..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}
