import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get apiBaseUrl {
    final raw = dotenv.get('API_BASE_URL');
    if (!kIsWeb && Platform.isAndroid) {
      final uri = Uri.tryParse(raw);
      if (uri != null &&
          (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        return uri.replace(host: '10.0.2.2').toString();
      }
    }
    return raw;
  }

  static String get apiKey =>
      dotenv.get('API_KEY');

  static String get razorpayKey =>
      dotenv.get('RAZORPAY_KEY');
}
