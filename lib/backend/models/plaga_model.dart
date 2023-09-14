import 'package:agave_app/backend/providers/estudios_provider.dart';
import 'package:flutter/foundation.dart';

class Plaga {
  int id;
  String nombre;

  Plaga({required this.id, required this.nombre});

  factory Plaga.fromJson(Map<String, dynamic> json) =>
      Plaga(id: json['id'], nombre: json['nombre']);

  Map<String, dynamic> toJson() => {"id": id, "nombre": nombre};

  static Future<List<Plaga>> getAll() {
    return EstudiosProvider.db.getPlagas();
  }
}
