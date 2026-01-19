import 'package:flutter/material.dart';
import '../models/photo_model.dart';

class PhotoProvider extends ChangeNotifier {
  Photo? _foto;

  Photo? get foto => _foto;

  void takePhoto(Photo foto) {
    _foto = foto;
    notifyListeners();
  }
}
