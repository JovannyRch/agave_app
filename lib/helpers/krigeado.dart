import 'package:agave_app/backend/ajuste_model.dart';
import 'package:linalg/linalg.dart';
import 'package:agave_app/backend/models/estudio_model.dart';
import 'package:agave_app/backend/models/muestreo_model.dart';

import '../backend/models/modelos_model.dart';
import 'calculos.dart';

enum Modelo { Esferico, Exponencial, Gaussiano, Nugget }

Modelo getModelo(String modelo) {
  if (modelo == Ajuste.ESFERICO) {
    return Modelo.Esferico;
  } else if (modelo == Ajuste.EXPONENCIAL) {
    return Modelo.Exponencial;
  } else if (modelo == Ajuste.GUASSIANO) {
    return Modelo.Gaussiano;
  } else {
    return Modelo.Nugget;
  }
}

class Krigeado {
  double rango;
  Modelo modelo;
  double meseta;
  double efectoPepita;
  Estudio estudio;
  int cantidadCercanos = 4;

  Krigeado(
      {required this.estudio,
      required this.modelo,
      required this.rango,
      required this.meseta,
      required this.efectoPepita});

  double krigeadoEnPunto(double x, double y) {
    List<MuestreoDistancia> distancias = estudio.muestreos
        .map((muestreo) => MuestreoDistancia(
            muestreo: muestreo,
            distancia: Calculos.calcularDistancia(
                x, y, muestreo.norte, muestreo.este)))
        .toList();
    distancias.sort((a, b) => a.distancia.compareTo(b.distancia));
    //Mas cercanos
    List<MuestreoDistancia> masCercanos =
        distancias.sublist(0, cantidadCercanos);
    TablaDistanciasEuclidianas tabla =
        TablaDistanciasEuclidianas(puntosMasCercanos: masCercanos, x: x, y: y);
    GammaH gamma = GammaH(
        modelo: modelo,
        tabla: tabla,
        rango: rango,
        efectoPepita: efectoPepita,
        meseta: meseta);
    Matrix c = Matrix(gamma.getMatriC());
    print("Matriz c");
    print(c);
    Matrix cInversa = c.inverse();

    Vector c0 = Vector.column(gamma.getC0());
    Matrix lambdas = cInversa * c0; // W

    double incidencia = getIncidencia(masCercanos, lambdas);
    double varianzaDelError = calcularVarianzaDelError(lambdas, meseta, c0);
    return incidencia;
  }

  double calcularVarianzaDelError(Matrix lambdas, double meseta, Vector c0) {
    double media = lambdas.rowVector(lambdas.m - 1)[0];
    double valor = 0.0;
    for (int i = 0; i < lambdas.m - 1; i++) {
      valor += (meseta - lambdas.rowVector(i)[0] * c0[i] - media);
    }
    return valor;
  }

  double getIncidencia(List<MuestreoDistancia> muestreos, Matrix lambdas) {
    int n = muestreos.length;
    double valor = 0.0;
    for (int i = 0; i < n; i++) {
      valor += muestreos[i].muestreo.incidencia * lambdas.rowVector(i)[0];
    }
    return valor;
  }
}

class MuestreoDistancia {
  Muestreo muestreo;
  double distancia;
  MuestreoDistancia({required this.distancia, required this.muestreo});
}

class TablaDistanciasEuclidianas {
  List<MuestreoDistancia> puntosMasCercanos = [];
  List<List<double>> distancias = [];
  double x;
  double y;
  TablaDistanciasEuclidianas(
      {required this.puntosMasCercanos, required this.x, required this.y}) {
    for (int i = 0; i < puntosMasCercanos.length; i++) {
      distancias.add([]);
      for (int j = 0; j < puntosMasCercanos.length + 1; j++) {
        Muestreo m1 = puntosMasCercanos[i].muestreo;

        if (j == puntosMasCercanos.length) {
          distancias[i]
              .add(Calculos.calcularDistancia(x, y, m1.norte, m1.este));
        } else {
          Muestreo m2 = puntosMasCercanos[j].muestreo;
          distancias[i].add(
              Calculos.calcularDistancia(m1.norte, m1.este, m2.norte, m2.este));
        }
      }
    }
  }
}

class GammaH {
  TablaDistanciasEuclidianas tabla;
  Modelo modelo;
  double rango;
  double meseta;
  double efectoPepita;
  List<List<double>> valores = [];

  GammaH(
      {required this.tabla,
      required this.modelo,
      required this.efectoPepita,
      required this.meseta,
      required this.rango}) {
    int size = tabla.distancias.length;

    for (int i = 0; i < size; i++) {
      valores.add([]);
      for (int j = 0; j < size + 1; j++) {
        double valor = 0.0;
        if (modelo == Modelo.Esferico) {
          valor = Modelos.fEsferico(tabla.distancias[i][j], rango, meseta);
        } else if (modelo == Modelo.Exponencial) {
          valor = Modelos.fExponencial(tabla.distancias[i][j], rango, meseta);
        } else if (modelo == Modelo.Gaussiano) {
          valor = Modelos.fGuasianno(tabla.distancias[i][j], rango, meseta);
        } else if (modelo == Modelo.Nugget) {
          valor = Modelos.fNugget(tabla.distancias[i][j]);
        }
        valores[i].add(valor);
      }
    }
  }

  List<List<double>> getMatriC() {
    List<List<double>> matriz = [];
    int size = tabla.distancias.length;

    for (int i = 0; i < size + 1; i++) {
      List<double> lista = [];
      for (int j = 0; j < size + 1; j++) {
        if (i == size || j == size) {
          if (j == size && i == size) {
            lista.add(0);
          } else if (i == size) {
            lista.add(1);
          } else if (j == size) {
            lista.add(1);
          }
        } else {
          lista.add(valores[i][j]);
        }
      }
      matriz.add(lista);
    }
    return matriz;
  }

  List<double> getC0() {
    List<double> res = [];
    int size = tabla.distancias.length;

    for (int j = 0; j < size; j++) {
      res.add(valores[j][size]);
    }
    res.add(1.0);
    return res;
  }
}
