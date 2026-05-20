import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_admin_app/main.dart';
import 'package:ecommerce_admin_app/core/widgets/custom_button.dart';

void main() {
  testWidgets('Login Flow Test', (WidgetTester tester) async {
    print('Building MyApp...');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    print('Finding Sign In button...');
    final signInButton = find.widgetWithText(CustomButton, 'Sign In');
    expect(signInButton, findsOneWidget);

    print('Tapping Sign In button...');
    await tester.tap(signInButton);
    
    print('Pumping frames to simulate network call...');
    // Pump repeated times to allow timers and future delays to execute
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    await tester.pumpAndSettle();
    
    print('Verifying navigation to dashboard...');
    // Check if we can find dashboard title or MainLayout
    expect(find.text('Dashboard Overview'), findsOneWidget);
    print('Login test successful!');
  });
}
