import 'package:agave_app/backend/models/estudio_model.dart';

class Mapa {
  late double ancho;
  late double alto;
  late Estudio estudio;
  List<List<double>> mapa = [[]];

  void crearMapa() {
    for (int i = 0; i < ancho; i++) {
      mapa[i] = [];
      for (int j = 0; j < alto; j++) {
        mapa[i].add(0);
      }
    }
  }
}
