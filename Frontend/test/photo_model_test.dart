import 'package:flutter_test/flutter_test.dart';

import '../lib/models/photo_model.dart';

/* metodo principal */
void main() {

  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');
  print('Pruebas Unitarias - Photo');
  print('_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_');

  group('Pruebas correctas', () {

    // Prueba 3
    test('Prueba 3 - Photo.fromJson con todos los campos', () {
      print('\n Prueba 3 - Photo.fromJson con todos los campos');
      // Arrange
      final json = {
        'image_url': 'https://example.com/pic.png',
        'class_name': 'Dermatitis',
        'confidence': 0.87,
      };

      // Act
      final photo = Photo.fromJson(json);
      print('Resultado -> path: ${photo.path}, name: ${photo.name}, confidence: ${photo.confidence}');

      // Assert
      expect(photo.path, 'https://example.com/pic.png');
      expect(photo.name, 'Dermatitis');
      expect(photo.confidence, '0.87');

      print('Prueba 3 finalizada');
    });

    // Prueba 4
    test('Prueba 4 - Photo.fromJson con campos faltantes', () {
      print('\n Prueba 4 - Photo.fromJson con campos faltantes');
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final photo = Photo.fromJson(json);
      print('Resultado -> path: ${photo.path}, name: "${photo.name}", confidence: "${photo.confidence}"');

      // Assert
      expect(photo.name, '');
      expect(photo.confidence, '');

      print('Prueba 4 finalizada');
    });

  });

}
