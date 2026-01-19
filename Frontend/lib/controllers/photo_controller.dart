import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/photo_provider.dart';
import '../models/photo_model.dart';

class PhotoController{
  final PhotoProvider provider;
  final ImagePicker picker = ImagePicker();

  PhotoController(this.provider);

  Future<void> tomarFoto(BuildContext context) async{
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if(foto != null){
      provider.takePhoto(Photo(path: foto.path, name: "Foto", description: "Foto guardada"));
    }
  }

}