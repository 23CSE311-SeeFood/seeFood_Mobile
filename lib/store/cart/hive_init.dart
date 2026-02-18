import 'package:hive_flutter/hive_flutter.dart';
import 'package:seefood/store/cart/cart_item.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CartItemAdapter());
  }
}
