import 'dart:math';
import 'package:agave_app/backend/models/chart_data.dart';
import 'package:sample_statistics/sample_statistics.dart';

import '../backend/models/estudio_model.dart';
import '../backend/models/muestreo_model.dart';

class Calculos {
  List<double> getCuadrados(List<double> datos) {
    List<double> resultado = [];
    for (double dato in datos) {
      resultado.add(dato * dato);
    }
    return resultado;
  }

  static double calcularDistancia(double x1, double y1, double x2, double y2) {
    num p = pow(x1 - x2, 2) + pow(y1 - y2, 2);
    return sqrt(p);
  }

  List<double> getMultiplicacion(List<double> xs, List<double> ys) {
    List<double> resultado = [];
    for (int i = 0; i < xs.length; i++) {
      resultado.add(xs[i] * ys[i]);
    }
    return resultado;
  }

  double getSumatoria(List<double> datos) {
    double suma = 0.0;
    for (double dato in datos) {
      suma += dato;
    }
    return suma;
  }

  MCO getMCO(List<double> xs, List<double> ys) {
    List<double> x2 = getCuadrados(xs);
    /*  List<double> y2 = getCuadrados(ys); */
    List<double> xy = getMultiplicacion(xs, ys);

    double sumatoriaX = getSumatoria(xs);
    double sumatoriaY = getSumatoria(ys);

    double sumatoriaX2 = getSumatoria(x2);
    /*  double sumatoriaY2 = getSumatoria(y2); */

    double sumatoriaXY = getSumatoria(xy);

    int n = xs.length;

    double b = (n * (sumatoriaXY) - (sumatoriaY * sumatoriaX)) /
        (n * (sumatoriaX2) - pow(sumatoriaX, 2));
    double a = (sumatoriaY / n) - (b * sumatoriaX) / n;
    return MCO(a: a, b: b);
  }

  List<double> getRectaEstimada(MCO mco, List<double> xs) {
    List<double> resultado = [];
    for (int i = 0; i < xs.length; i++) {
      resultado.add(mco.a + mco.b * xs[i]);
    }
    return resultado;
  }

  double getSumaDeCuadrados(List<double> y, List<double> yEstimada) {
    double suma = 0.0;
    for (int i = 0; i < y.length; i++) {
      suma += pow(y[i] - yEstimada[i], 2);
    }
    return suma;
  }

  //s => Significancia Estadistica
  double getS(double sumaDeCuadrados, int n) {
    return sqrt(sumaDeCuadrados / (n - 2));
  }

  // distanciasOrdenadas => xs
  double getVarianza(List<double> datos) {
    double media = getMedia(datos);
    int n = datos.length;
    if (n == 1 || n == 0) return 0.0;
    double suma = 0.0;
    for (double dato in datos) {
      suma = suma + pow((dato - media), 2);
    }
    double varianza = suma / n;
    return varianza;
  }

  double getMedia(List<double> datos) {
    double suma = 0.0;
    int n = datos.length;
    for (double dato in datos) {
      suma += dato;
    }
    double media = suma / n;
    return media;
  }

  double getDesviacionEstandar(List<double> datos) {
    double varianza = getVarianza(datos);
    return sqrt(varianza);
  }

  //s => Significancia Estadistica
  double getT(List<double> xs, double b, double s) {
    double desviacionEstandar = getDesviacionEstandar(xs);
    double t = (desviacionEstandar * b) / s;
    return t;
  }

  // ys => incidencias semivariograma
  // xs => distancias
  Coeficientes mainCalculo(
      List<double> xs, List<double> ys, List<double> incidencias) {
    MCO mco = getMCO(xs, ys);
    int n = xs.length;
    List<double> yEstimada = getRectaEstimada(mco, xs);
    double sumaDeCuadrados = getSumaDeCuadrados(ys, yEstimada);

    double s = getS(sumaDeCuadrados, n);
    //T
    double t = getT(xs, mco.b, s);

    double mediaY = getMedia(ys);

    double sumaDatoParticularMenosYEstimada =
        getsumaDatoParticularMenosYEstimada(ys, yEstimada);
    double sumatoriaYEstimadaMenosMediaY =
        getSumatoriaYEstimadaMenosMediaY(yEstimada, mediaY);
    double r2 = sumatoriaYEstimadaMenosMediaY /
        (sumaDatoParticularMenosYEstimada + sumatoriaYEstimadaMenosMediaY);
    double r = sqrt(r2);

    double mediaIncidencias = getMedia(incidencias);
    double desviacionEstandarIncidencias = getDesviacionEstandar(incidencias);
    double mediaDistancias = getMedia(xs);

    double coeficienteDeAsimetria = getCoeficienteDeAsimetria(
        incidencias, desviacionEstandarIncidencias, mediaIncidencias);
    double coeficienteDeCurtosis = getCoeficienteDeCurtosis(
        incidencias, desviacionEstandarIncidencias, mediaIncidencias);
    double coeficienteDeVariacion =
        getCoefienteVariacion(desviacionEstandarIncidencias, mediaIncidencias);
    double coeficienteDeCorrelacion = getCoeficienteDeCorrelacion(
        xs, incidencias, desviacionEstandarIncidencias, mediaIncidencias);
    double covarianza =
        getCovarianza(xs, incidencias, mediaIncidencias, mediaDistancias);

    double desviacionEstandarXs = getDesviacionEstandar(xs);

    RegresionLineal rl = getRegresionLineal(
        coeficienteDeCorrelacion,
        desviacionEstandarIncidencias,
        desviacionEstandarXs,
        mediaIncidencias,
        mediaDistancias);

    return new Coeficientes(
      covarianza: covarianza,
      curtosis: coeficienteDeCurtosis,
      varianza: coeficienteDeVariacion,
      asimetria: coeficienteDeAsimetria,
      regresionLineal: rl,
    );
    //T y R mostrarlo junto con el semivariograma

    //Boton "Datos estadisticos"
    // ...
    // De las incidencias, calcular
    // -> Mediana
    // -> Moda
    // -> Quartil 1,3
    // -> Valor max y min
  }

  double getCovarianza(List<double> distancias, List<double> incidencias,
      double mediaIncidencias, double mediaDistancias) {
    int n = distancias.length;
    double suma = 0.0;
    double mediaX = mediaDistancias;
    double mediaY = mediaIncidencias;
    for (int i = 0; i < n; i++) {
      double xi = distancias[i];
      double yi = incidencias[i];
      suma += (xi - mediaX) * (yi - mediaY);
    }
    double covarianza = suma / n;
    return covarianza;
  }

  double getsumaDatoParticularMenosYEstimada(
      List<double> ys, List<double> yEstimada) {
    double suma = 0.0;
    for (int i = 0; i < ys.length; i++) {
      suma += pow(ys[i] - yEstimada[i], 2);
    }
    return suma;
  }

  double getCoeficienteDeCorrelacion(
      List<double> distancias,
      List<double> incidencias,
      double desviacionEstandarIncidencias,
      double mediaIncidencias) {
    double mediaY = mediaIncidencias;
    double desviacionEstandarY = desviacionEstandarIncidencias;

    double mediaX = getMedia(distancias);
    double dEX = getDesviacionEstandar(incidencias);
    int n = distancias.length;
    double suma = 0.0;
    for (int i = 0; i < n; i++) {
      double xi = distancias[i];
      double yi = incidencias[i];
      suma += (xi - mediaX) * (yi - mediaY);
    }
    double coeficiente = (suma / n) / (desviacionEstandarY * dEX);
    return coeficiente;
  }

  double getSumatoriaYEstimadaMenosMediaY(
      List<double> rectaEstimada, double mediaY) {
    double suma = 0.0;
    for (double dato in rectaEstimada) {
      suma += pow(dato - mediaY, 2);
    }
    return suma;
  }

  // X => distancias
  double getCoeficienteDeAsimetria(
      List<double> incidencias, double desviacionEstandar, double media) {
    double suma = 0.0;
    for (double xi in incidencias) {
      suma += pow(xi - media, 3);
    }
    int n = incidencias.length;
    double coeficienteDeAsimetria = ((suma / n) / pow(desviacionEstandar, 3));
    return coeficienteDeAsimetria;
  }

  double getCoeficienteDeCurtosis(
      List<double> incidencias, double desviacionEstandar, double media) {
    double suma = 0.0;
    for (double xi in incidencias) {
      suma += pow(xi - media, 4);
    }
    int n = incidencias.length;
    double coeficiente = ((suma / n) / pow(desviacionEstandar, 4)) - 3;
    return coeficiente;
  }

  double getCoefienteVariacion(double desviacionEstandar, double media) {
    return desviacionEstandar / media;
  }

  static List<ChartData> calcularSemivariograma(Estudio estudio) {
    List<int> incidencias = estudio.muestreos.map((e) => e.incidencia).toList();
    List<double> semivariogramaIncidencias =
        calcularSemivariogramaIncidenciasOrdendas(incidencias);
    List<double> distancias = calcularDistanciasOrdenadas(estudio.muestreos);

    double amplitud = distancias.last / 2;
    distancias = filtrarDistancias(distancias, amplitud);

    List<ChartData> semivariograma2 = [];
    for (int i = 0; i < distancias.length; i++) {
      double incidencia = semivariogramaIncidencias[i];
      double distancia = distancias[i];
      distancia = double.parse(distancia.toStringAsFixed(2));
      incidencia = double.parse(incidencia.toStringAsFixed(2));
      final cD = new ChartData(distancia, incidencia);
      semivariograma2.add(cD);
    }

    return semivariograma2;
  }

  static List<double> calcularDistanciasOrdenadas(List<Muestreo> registros) {
    List<double> distancias = [0];
    for (int i = 0; i < registros.length - 1; i++) {
      Muestreo regActual = registros[i];
      Muestreo regSiguiente = registros[i + 1];
      double d = distancia(
        regActual.este,
        regSiguiente.este,
        regActual.norte,
        regSiguiente.norte,
      );
      distancias.add(d);
    }
    distancias.sort();
    return distancias;
  }

  static double distancia(double x1, double x2, double y1, double y2) {
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }

  static List<double> calcularSemivariogramaIncidenciasOrdendas(
      List<int> incidencias) {
    int numeroIncidencias = incidencias.length;
    int h = 1; //Distancia
    int numeroPares = incidencias.length - 1;
    List<double> semivariograma = [0];

    for (int i = 1; i <= numeroIncidencias - 1; i++) {
      int suma = 0;
      for (int j = 0; j < numeroPares; j++) {
        int resta = incidencias[j + h] - incidencias[j];
        int potencia = pow(resta, 2).toInt();
        suma = suma + potencia;
      }

      double resultado =
          double.parse((suma / (2 * numeroPares)).toStringAsFixed(2));
      semivariograma.add(resultado);
      /*   this.tabla.add(new Renglon(i, numeroPares, suma, resultado)); */
      numeroPares = numeroPares - 1;
      h = h + 1;
    }
    semivariograma.sort();
    return semivariograma;
  }

  static List<double> filtrarDistancias(
      List<double> distancias, double umbral) {
    List<double> resultado = [];

    for (double d in distancias) {
      if (d <= umbral) {
        resultado.add(d);
      }
    }

    return resultado;
  }

  RegresionLineal getRegresionLineal(double coeficienteDeCorrelacion,
      double dEY, double dEX, double mediaY, double mediaX) {
    double a = coeficienteDeCorrelacion * (dEY / dEX);
    double b = mediaY - a * mediaX;
    return RegresionLineal(a: a, b: b);
  }
}

class MCO {
  double a;
  double b;

  MCO({required this.a, required this.b});
}

class RegresionLineal {
  double a;
  double b;

  RegresionLineal({required this.a, required this.b});
}

class Coeficientes {
  double curtosis;
  double asimetria;
  double covarianza;
  double varianza;
  RegresionLineal regresionLineal = RegresionLineal(a: 0.0, b: 0.0);
  Stats<double> stats = Stats([]);

  Coeficientes(
      {this.covarianza = 0.0,
      this.curtosis = 0.0,
      this.asimetria = 0.0,
      this.varianza = 0.0,
      required this.regresionLineal});
}

double formatNumber(double val) {
  if (val == null) return 0.0;
  return double.parse(val.toStringAsFixed(2));
}
