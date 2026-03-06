import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seefood/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('App starts and shows login screen', (WidgetTester tester) async {
      app.main();
      
      // Pump until the app is fully settled
      await tester.pumpAndSettle();

      // Find the email hint as a reliable marker of the login page
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Validates short password input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // The login page has two _InputField widgets. We can find them by the hintText
      final emailField = find.widgetWithText(TextField, 'Enter your email');
      final passwordField = find.widgetWithText(TextField, 'Enter password');
      final signInButton = find.text('Sign In');

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(signInButton, findsOneWidget);

      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, '12');
      await tester.pumpAndSettle();

      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
    
    testWidgets('Navigates to sign up page', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final signUpButton = find.text('Sign Up');
      expect(signUpButton, findsOneWidget);
      
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      
      expect(find.text('Create an account'), findsOneWidget);
    });
  });
}
