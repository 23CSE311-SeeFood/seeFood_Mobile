import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seefood/store/cart/cart_repository.dart';
import 'package:seefood/store/cart/hive_init.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initHive();
  final cartRepository = CartRepository();
  await cartRepository.init();
  runApp(MyApp(cartRepository: cartRepository));
}
