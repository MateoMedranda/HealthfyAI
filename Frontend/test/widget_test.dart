// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/widgets/bot_response.dart';

/* metodo principal */
void main() {

  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');
  print('Pruebas Widgets - BotResponse');
  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');

  group('Pruebas correctas', () {
    testWidgets('Prueba - BotResponse renderiza markdown básico', (WidgetTester tester) async {
      print('\n Prueba - BotResponse renderiza markdown básico');

      // Arrange
      const md = '# Hola\n\nContenido de prueba';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BotResponse(text: md),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Contenido de prueba'), findsOneWidget);

      print('Prueba finalizada');
    });
  });

}
