import 'dart:async';
import 'dart:math';

class MockApiService {
  static const bool _simulateDelay = true;
  static const int _delayMs = 400; // Fast for responsive feel, yet realistic

  static Future<void> simulateNetworkCall() async {
    if (_simulateDelay) {
      await Future.delayed(
        Duration(milliseconds: _delayMs + Random().nextInt(200)),
      );
    }
  }
}
