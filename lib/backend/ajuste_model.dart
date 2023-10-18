import 'dart:math';

import 'package:agave_app/backend/models/chart_data.dart';

class Ajuste {
  double rango;
  double meseta;
  double pepita;
  List<ChartData> datos;
  static String ESFERICO = "ESFERICO";
  static String EXPONENCIAL = "EXPONENCIAL";
  static String GUASSIANO = "GUASSIANO";
  static String NUGGET = "NUGGET";
  double errorCuadraticoMedio = 0.0;
  List<double> modelo = [];
  String errorMessage = "";

  Ajuste(
      {required this.meseta,
      required this.pepita,
      required this.rango,
      required this.datos});

  double fEsferico(double h) {
    if (h <= rango) {
      /* print("h <= rango : $h <= $rango"); */
      double val = meseta *
          ((1.5 * (h / rango)) - (0.5 * pow((h / rango), 3)));
      return val;
    }
    return meseta;
  }

  double fExponencial(double h) {
    return meseta * (1 - exp((-3 * h) / rango));
  }

  double fGuasianno(double h) {
    return meseta * (1 - exp((-pow(h, 2)) / pow(rango, 2)));
  }

  double fNugget(double h) {
    if (h == 0) return 0;
    return 1;
  }

  List<double> getValues(String model) {
    List<double> result = [];

    if (model == ESFERICO) {
      for (ChartData d in datos) {
        double valorRecibido = fEsferico(d.distancia);
        result.add(valorRecibido);
      }
    } else if (model == EXPONENCIAL) {
      for (ChartData d in datos) {
        result.add(fExponencial(d.distancia));
      }
    } else if (model == GUASSIANO) {
      for (ChartData d in datos) {
        result.add(fGuasianno(d.distancia));
      }
    } else {
      for (ChartData d in datos) {
        result.add(fNugget(d.distancia));
      }
    }
    modelo = result;

    return result;
  }

  bool checkModel(String model) {
    getValues(
        model); /* 
    print("Modelo: ");
    print("$model");
    print("rango: $rango");
    print("meseta: $meseta");
    print("pepita: $pepita"); */
    if (!checkMEE()) {
      errorMessage = "No pasa prueba del error MEE";
      return false;
    }

    if (!checkErrorCuadraticoMedio()) {
      errorMessage = "No pasa prueba del error cuadrático medio";
      return false;
    }

    if (!checkErrorCuadraticoMedioAdimensional()) {
      errorMessage = "No pasa prueba del error cuadrático medio adimensional";
      return false;
    }

    if (!checkErrorCuadratico()) {
      errorMessage = "No pasa prueba del error cuadrático";
      return false;
    }

    return true;
  }

  bool checkErrorCuadratico() {
    for (int i = 0; i < datos.length; i++) {
      //Error = (Yi - Zi)^2
      double difference = datos[i].semivariograma - modelo[i];
      num error = pow(difference, 2.0);
      if (error >= datos[i].semivariograma) {
        return false;
      }
    }
    return true;
  }

  bool checkMEE() {
    double suma = 0.0;
    int n = datos.length;
    print("Modelo");
    print(modelo.sublist(0, 20));
    print(datos.sublist(0, 20).map((e) => e.semivariograma).toList());
    for (int i = 0; i < n; i++) {
      double diff = (modelo[i] - datos[i].semivariograma);
      /*   if(diff < 0.0){
        diff = diff*-1;
      } */
      suma += diff;
    }
    double val = suma / n;
    print("Suma $suma");
    print("n $n");
    print("MEE: $val ");
    return val >= 0 && val <= 1.0;
  }

  bool checkErrorCuadraticoMedio() {
    double suma = 0.0;
    int n = datos.length;
    for (int i = 0; i < n; i++) {
      suma += pow(modelo[i] - datos[i].semivariograma, 2);
    }
    double val = suma / n;
    errorCuadraticoMedio = val;
    return val >= 0 && val <= 1.0;
  }

  bool checkErrorCuadraticoMedioAdimensional() {
    double suma = 0.0;
    int n = datos.length;
    double desviacionEstandar = sqrt(errorCuadraticoMedio);
    for (int i = 0; i < n; i++) {
      suma += (modelo[i] - datos[i].semivariograma) / desviacionEstandar;
    }
    double val = suma / n;
    return val >= 1.0 && val <= 2.0;
  }
}
