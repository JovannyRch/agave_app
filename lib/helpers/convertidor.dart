import 'dart:math' as Math;

class Convertidor {
  double? K0;
  double? E;
  double? E2;
  double? E3;
  double? E_P2;

  double? SQRT_E;
  double? _E;
  double? _E2;
  double? _E3;
  double? _E4;
  double? _E5;

  double? M1;
  double? M2;
  double? M3;
  double? M4;

  double? P2;
  double? P3;
  double? P4;
  double? P5;
  double? R = 6378137;

  String ZONE_LETTERS = 'CDEFGHJKLMNPQRSTUVWXX';

  Convertidor() {
    K0 = 0.9996;

    E = 0.00669438;
    E2 = Math.pow(E!, 2).toDouble();
    E3 = Math.pow(E!, 3).toDouble();
    E_P2 = E! / (1 - E!);

    SQRT_E = Math.sqrt(1 - E!);
    _E = (1 - SQRT_E!) / (1 + SQRT_E!);
    _E2 = Math.pow(_E!, 2).toDouble();
    _E3 = Math.pow(_E!, 3).toDouble();
    _E4 = Math.pow(_E!, 4).toDouble();
    _E5 = Math.pow(_E!, 5).toDouble();

    M1 = 1 - E! / 4 - 3 * E2! / 64 - 5 * E3! / 256;
    M2 = 3 * E! / 8 + 3 * E2! / 32 + 45 * E3! / 1024;
    M3 = 15 * E2! / 256 + 45 * E3! / 1024;
    M4 = 35 * E3! / 3072;

    P2 = 3 / 2 * _E! - 27 / 32 * _E3! + 269 / 512 * _E5!;
    P3 = 21 / 16 * _E2! - 55 / 32 * _E4!;
    P4 = 151 / 96 * _E3! - 417 / 128 * _E5!;
    P5 = 1097 / 512 * _E4!;
    R = 6378137;

    ZONE_LETTERS = 'CDEFGHJKLMNPQRSTUVWXX';
  }

  Map toLatLon(easting, northing, zoneNum, zoneLetter, northern, strict) {
    strict = strict ?? true;

    if (!zoneLetter && northern == null) {
      throw Error();
    } else if (zoneLetter && northern != null) {
      throw Error();
    }

    if (strict) {
      if (easting < 100000 || 1000000 <= easting) {
        throw RangeError(
            'easting out of range (must be between 100 000 m and 999 999 m)');
      }
      if (northing < 0 || northing > 10000000) {
        throw RangeError(
            'northing out of range (must be between 0 m and 10 000 000 m)');
      }
    }
    if (zoneNum < 1 || zoneNum > 60) {
      throw RangeError(
          'zone number out of range (must be between 1 and 60)');
    }
    if (zoneLetter) {
      zoneLetter = zoneLetter.toUpperCase();
      if (zoneLetter.length != 1 || !ZONE_LETTERS.contains(zoneLetter)) {
        throw RangeError(
            'zone letter out of range (must be between C and X)');
      }
      northern = zoneLetter >= 'N';
    }

    var x = easting - 500000;
    var y = northing;

    if (!northern) y -= 1e7;

    var m = y / K0;
    var mu = m / (R! * M1!);

    var pRad = mu +
        P2! * Math.sin(2 * mu) +
        P3! * Math.sin(4 * mu) +
        P4! * Math.sin(6 * mu) +
        P5! * Math.sin(8 * mu);

    var pSin = Math.sin(pRad);
    var pSin2 = Math.pow(pSin, 2);

    var pCos = Math.cos(pRad);

    var pTan = Math.tan(pRad);
    var pTan2 = Math.pow(pTan, 2);
    var pTan4 = Math.pow(pTan, 4);

    var epSin = 1 - E! * pSin2;
    var epSinSqrt = Math.sqrt(epSin);

    var n = R! / epSinSqrt;
    var r = (1 - E!) / epSin;

    var c = _E! * pCos * pCos;
    var c2 = c * c;

    var d = x / (n * K0!);
    var d2 = Math.pow(d, 2);
    var d3 = Math.pow(d, 3);
    var d4 = Math.pow(d, 4);
    var d5 = Math.pow(d, 5);
    var d6 = Math.pow(d, 6);

    var latitude = pRad -
        (pTan / r) *
            (d2 / 2 - d4 / 24 * (5 + 3 * pTan2 + 10 * c - 4 * c2 - 9 * E_P2!)) +
        d6 /
            720 *
            (61 + 90 * pTan2 + 298 * c + 45 * pTan4 - 252 * E_P2! - 3 * c2);
    var longitude = (d -
            d3 / 6 * (1 + 2 * pTan2 + c) +
            d5 /
                120 *
                (5 - 2 * c + 28 * pTan2 - 3 * c2 + 8 * E_P2! + 24 * pTan4)) /
        pCos;

    return {
      'latitude': toDegrees(latitude),
      'longitude': toDegrees(longitude) + zoneNumberToCentralLongitude(zoneNum)
    };
  }

  Map fromLatLon(latitude, longitude, forceZoneNum) {
    if (latitude > 84.0 || latitude < -80.0) {
      throw RangeError(
          'latitude out of range (must be between 80 deg S and 84 deg N)');
    }
    if (longitude > 180.0 || longitude < -180.0) {
      throw RangeError(
          'longitude out of range (must be between 180 deg W and 180 deg E)');
    }

    var latRad = toRadians(latitude);
    var latSin = Math.sin(latRad);
    var latCos = Math.cos(latRad);

    var latTan = Math.tan(latRad);
    var latTan2 = Math.pow(latTan, 2);
    var latTan4 = Math.pow(latTan, 4);

    var zoneNum;

    if (forceZoneNum == null) {
      zoneNum = latLonToZoneNumber(latitude, longitude);
    } else {
      zoneNum = forceZoneNum;
    }

    String zoneLetter = latitudeToZoneLetter(latitude);

    var lonRad = toRadians(longitude);

    var centralLon = zoneNumberToCentralLongitude(zoneNum);

    var centralLonRad = toRadians(centralLon);

    var n = R! / Math.sqrt(1 - E! * latSin * latSin);

    var c = E_P2! * latCos * latCos;

    var a = latCos * (lonRad - centralLonRad);
    var a2 = Math.pow(a, 2);
    var a3 = Math.pow(a, 3);
    var a4 = Math.pow(a, 4);
    var a5 = Math.pow(a, 5);
    var a6 = Math.pow(a, 6);

    var m = R! *
        (M1! * latRad -
            M2! * Math.sin(2 * latRad) +
            M3! * Math.sin(4 * latRad) -
            M4! * Math.sin(6 * latRad));
    var easting = K0! *
            n *
            (a +
                a3 / 6 * (1 - latTan2 + c) +
                a5 / 120 * (5 - 18 * latTan2 + latTan4 + 72 * c - 58 * E_P2!)) +
        500000;
    var northing = K0! *
        (m +
            n *
                latTan *
                (a2 / 2 +
                    a4 / 24 * (5 - latTan2 + 9 * c + 4 * c * c) +
                    a6 /
                        720 *
                        (61 - 58 * latTan2 + latTan4 + 600 * c - 330 * E_P2!)));
    if (latitude < 0) northing += 1e7;

    return {
      "este": easting,
      "norte": northing,
      "zona": zoneNum,
      "letra": zoneLetter
    };
  }

  String latitudeToZoneLetter(latitude) {
    if (-80 <= latitude && latitude <= 84) {
      double calc = ((latitude + 80) / 8);
      return ZONE_LETTERS[calc.toInt().floor()];
    } else {
      return "";
    }
  }

  int latLonToZoneNumber(double latitude, double longitude) {
    if (56.0 <= latitude &&
        latitude < 64.0 &&
        3.0 <= longitude &&
        longitude < 12.0) if (72.9 <=
            latitude &&
        latitude <= 84.0 &&
        longitude >= 0.0) {
      if (longitude < 9) return 31;
      if (longitude < 21) return 33;
      if (longitude < 33) return 35;
      if (longitude < 42) return 37;
    }

    return floor((longitude + 180) / 6) + 1;
  }

  int floor(double n) {
    return n.toInt().floor();
  }

  zoneNumberToCentralLongitude(zoneNum) {
    return (zoneNum - 1) * 6 - 180 + 3;
  }

  toDegrees(rad) {
    return rad / Math.pi * 180;
  }

  toRadians(deg) {
    return deg * Math.pi / 180;
  }
}
