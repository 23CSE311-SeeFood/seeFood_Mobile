import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL');

  static String get apiKey =>
      dotenv.get('API_KEY');

  static String get razorpayKey =>
      dotenv.get('RAZORPAY_KEY');
}
