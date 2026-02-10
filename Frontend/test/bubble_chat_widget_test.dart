import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/widgets/bubble_chat.dart';

/* metodo principal */
void main() {

  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');
  print('Pruebas Widgets - BubbleChat');
  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');

  group('Pruebas correctas', () {

    testWidgets('Prueba 1 - BubbleChat muestra texto y contenedor de imagen', (WidgetTester tester) async {
      print('\n Prueba 1 - BubbleChat muestra texto y contenedor de imagen');

      // Arrange
      final widget = MaterialApp(
        home: Scaffold(
          body: BubbleChat(
            text: 'Hola mundo',
            color: Colors.green,
            textColor: Colors.white,
            imageUrl: 'https://example.com/x.png',
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hola mundo'), findsOneWidget);
      expect(find.byType(ClipRRect), findsWidgets);

      print('Prueba 1 finalizada');
    });

  });

}
