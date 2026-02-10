import 'package:flutter_test/flutter_test.dart';

import '../lib/models/message_model.dart';

/* metodo principal */
void main() {

  final servicio = null; // placeholder si se necesitara un servicio

  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');
  print('Pruebas Unitarias - Message');
  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');

  group('Pruebas correctas', () {

    // Prueba 1
    test('Prueba 1 - Message.fromJson con image_url', () {
      print('\n Prueba 1 - Message.fromJson con image_url');
      // AAA: Arrange, Act, Assert
      // Arrange
      final json = {
        'type': 'user',
        'content': 'Contenido de prueba',
        'image_url': 'https://example.com/imagen.jpg',
      };
      print('Datos de entrada -> type:user, content:Contenido de prueba, image_url:...');

      // Act
      final message = Message.fromJson(json);
      print('Resultado -> type: ${message.type}, content: ${message.content}, imageUrl: ${message.imageUrl}');

      // Assert
      expect(message.type, 'user');
      expect(message.content, 'Contenido de prueba');
      expect(message.imageUrl, 'https://example.com/imagen.jpg');

      print('Prueba 1 finalizada');
    });

    // Prueba 2
    test('Prueba 2 - Message.fromJson con campos faltantes', () {
      print('\n Prueba 2 - Message.fromJson con campos faltantes');
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final message = Message.fromJson(json);
      print('Resultado -> type: ${message.type}, content: "${message.content}", imageUrl: ${message.imageUrl}');

      // Assert
      expect(message.content, '');
      expect(message.imageUrl, isNull);

      print('Prueba 2 finalizada');
    });

  });

}
