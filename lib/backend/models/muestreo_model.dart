import 'package:agave_app/backend/providers/muestreos_provider.dart';

class Muestreo {
  int id;
  double latitud;
  double longitud;
  double norte;
  double este;
  String zona;
  int incidencia;
  int estudioId;

  Muestreo(
      {required this.id,
      required this.latitud,
      required this.longitud,
      required this.norte,
      required this.este,
      required this.zona,
      required this.incidencia,
      required this.estudioId});

  factory Muestreo.fromJson(Map<String, dynamic> json) => Muestreo(
        id: json['id'],
        latitud: json['latitud'],
        longitud: json['longitud'],
        norte: json['norte'],
        este: json['este'],
        zona: json['zona'],
        incidencia: json['incidencia'],
        estudioId: json['estudioId'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "latitud": latitud,
        "longitud": longitud,
        "norte": norte,
        "este": este,
        "zona": zona,
        "incidencia": incidencia,
        "estudioId": estudioId,
      };

  static create(Muestreo m) {
    MuestreosProvider.db.insert(m);
  }
}
