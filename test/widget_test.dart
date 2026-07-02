import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youbike_android/main.dart';
import 'package:youbike_android/services/app_state.dart';

void main() {
  testWidgets('App boots successfully with AppState', (WidgetTester tester) async {
    // Wrap the app with the required AppState provider
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const YouBikeApp(),
      ),
    );

    // Verify that the HomeScreen (or a part of it) is present
    // We search for a text that's likely on the screen or just check that no exceptions occurred
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
