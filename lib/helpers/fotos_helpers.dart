import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:mime_type/mime_type.dart'; /* 
import 'package:compressimage/compressimage.dart'; */

Future<String> subirImagen(PickedFile imagen) async {
  /* await CompressImage.compress(imageSrc: imagen.path, desiredQuality: 80); */
  final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/jovannyrch/image/upload?upload_preset=ri0byjug');
  final mimeType = mime(imagen.path)?.split('/'); //image/jpeg

  final imageUploadRequest = http.MultipartRequest('POST', url);

  final file = await http.MultipartFile.fromPath('file', imagen.path,
      contentType: MediaType(mimeType![0], mimeType[1]));

  imageUploadRequest.files.add(file);

  final streamResponse = await imageUploadRequest.send();
  final resp = await http.Response.fromStream(streamResponse);

  if (resp.statusCode != 200 && resp.statusCode != 201) {
    return "";
  }

  final respData = json.decode(resp.body);
  return respData['secure_url'];
}
