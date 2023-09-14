import 'package:agave_app/backend/providers/parcelas_provider.dart';

class Parcela {
  int id;
  String descripcion;
  double superficie;
  int cultivoId;
  String createdAt;
  Parcela(
      {required this.id,
      required this.descripcion,
      required this.superficie,
      required this.cultivoId,
      required this.createdAt});
  factory Parcela.fromJson(Map<String, dynamic> json) => Parcela(
        id: json['id'],
        descripcion: json['descripcion'],
        superficie: json['superficie'],
        cultivoId: json['cultivoId'],
        createdAt: json['createdAt'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "descripcion": descripcion,
        "superficie": superficie,
        "cultivoId": cultivoId,
        "createdAt": createdAt,
      };

  Future<String> get ultimoMuestreo async {
    return ParcelasProvider.db.getLastMuestreo(this.id);
  }

  Future<int> get totalMuestreos async {
    return ParcelasProvider.db.getMuestreos(this.id);
  }

  Future<List<String>> get fotos async {
    return ParcelasProvider.db.getPhotos(this.id);
  }

  void agregarFoto(String url) {
    return ParcelasProvider.db.insertFoto(url, this.id);
  }

  Future<int> eliminarFoto(String url) async {
    return ParcelasProvider.db.delete(url, tabla: "fotos", campo: "url");
  }

  Future<int> get totalEstudios async {
    return ParcelasProvider.db.totalEstudios(this.id);
  }

  Future<String> get plagaPrincipal async {
    return ParcelasProvider.db.plagaPrincipal(this.id);
  }
}
