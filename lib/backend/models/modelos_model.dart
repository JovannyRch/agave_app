

import 'dart:math';

class Modelos {
  
  static double fEsferico(double h, double rango, double meseta){
   if (h <= rango) {

      /* print("h <= rango : $h <= $rango"); */
      double val =  meseta *
          ((1.5 * (h / rango)) - (0.5 * pow((h / rango),3)));
      return val;
    }
    return meseta;
  }


  static double fExponencial(double h, double rango, double meseta){
     return meseta * (1 - exp((-3 * h) / rango));
  }

  static double fGuasianno(double h, double rango, double meseta){
    return meseta * (1 - exp((-pow(h, 2)) / pow(rango, 2)));
  }

  static double fNugget(double h){
    if (h == 0) return 0;
    return 1;
  }

  
}