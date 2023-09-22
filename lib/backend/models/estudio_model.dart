import 'dart:math';

import 'package:agave_app/backend/models/muestreo_model.dart';
import 'package:agave_app/backend/providers/estudios_provider.dart';

class Estudio {
  int? id;
  double humedad;
  String createdAt;
  int plagaId;
  int parcelaId;
  int totalMuestras = 0;

  String modelo;
  double rango;
  double meseta;
  double pepita;
  double temperatura;
  String datosModelo;

  //Otras propiedades
  List<Muestreo> muestreos = [];
  double varianza = 0.0;
  double desviacionEstandar = 0.0;
  double media = 0.0;
  String nombrePlaga = "";
  int totalMuestreos = 0;
  int totalIncidencias = 0;

  Estudio(
      {this.id,
      required this.humedad,
      required this.createdAt,
      required this.parcelaId,
      required this.plagaId,
      required this.meseta,
      required this.rango,
      required this.pepita,
      required this.modelo,
      required this.datosModelo,
      required this.temperatura});

  factory Estudio.fromJson(Map<String, dynamic> json) => Estudio(
        id: json['id'],
        humedad: json['humedad'],
        temperatura: json['temperatura'],
        createdAt: json['createdAt'],
        plagaId: json['plagaId'],
        parcelaId: json['parcelaId'],
        meseta: json['meseta'],
        rango: json['rango'],
        pepita: json['pepita'],
        modelo: json['modelo'],
        datosModelo: json['datosModelo'],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "humedad": humedad,
        "temperatura": temperatura,
        "createdAt": createdAt,
        "plagaId": plagaId,
        "parcelaId": parcelaId,
        "meseta": meseta,
        "rango": rango,
        "pepita": pepita,
        "modelo": modelo,
        "datosModelo": datosModelo,
      };

  Future<int> hacerCalculos() async {
    media = await this.getPromedio;
    nombrePlaga = await this.getPlaga;
    totalMuestreos = await getMuestras;
    totalIncidencias = await getIncidencias;
    muestreos = await EstudiosProvider.db.getMuestreos(this.id ?? 0);
    varianza = calcularVarianza(muestreos);
    desviacionEstandar = sqrt(varianza);
    return 1;
  }

  Future<int> get getMuestras async {
    return EstudiosProvider.db.totalMuestras(this.id ?? 0);
  }

  Future<int> get getMuestreos async {
    return EstudiosProvider.db.totalMuestras(this.id ?? 0);
  }

  Future<int> get getIncidencias async {
    return EstudiosProvider.db.incidencias(this.id ?? 0);
  }

  Future<double> get getPromedio async {
    return EstudiosProvider.db.getPromedio(this.id ?? 0);
  }

  Future<String> get getPlaga async {
    return EstudiosProvider.db.getPlaga(this.plagaId);
  }

  Future<int> update() async {
    return EstudiosProvider.db.update(this);
  }

  double calcularVarianza(List<Muestreo> muestreos) {
    double suma = 0.0;

    int n = this.muestreos.length;
    if (n == 1 || n == 0) return 0.0;
    for (Muestreo muestreo in muestreos) {
      suma = suma + pow((muestreo.incidencia - media), 2);
    }
    double varianza = suma / (n);
    return varianza;
  }
}
