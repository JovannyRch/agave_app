import 'package:agave_app/backend/models/muestreo_model.dart';

class Mock {
  static createMuestreo(
      double este, double norte, int incidencia, int estudioId) {
    return Muestreo(
        id: -1,
        latitud: 10.0,
        longitud: 10.0,
        norte: norte,
        este: este,
        incidencia: incidencia,
        zona: "",
        estudioId: estudioId);
  }

  static List<Muestreo> createDate(int estudioId) {
    List<Muestreo> muestreos = [
      createMuestreo(417297, 2092259, 40, estudioId),
      createMuestreo(417282, 2092255, 10, estudioId),
      createMuestreo(417277, 2092253, 0, estudioId),
      createMuestreo(417265, 2092256, 12, estudioId),
      createMuestreo(417249, 2092256, 4, estudioId),
      createMuestreo(417244, 2092257, 20, estudioId),
      createMuestreo(417221, 2092254, 0, estudioId),
      createMuestreo(417216, 2092255, 0, estudioId),
      createMuestreo(417216, 2092256, 0, estudioId),
      createMuestreo(417204, 2092254, 10, estudioId),
      createMuestreo(417204, 2092263, 12, estudioId),
      createMuestreo(417208, 2092262, 8, estudioId),
      createMuestreo(417224, 2092264, 3, estudioId),
      createMuestreo(417229, 2092263, 4, estudioId),
      createMuestreo(417246, 2092265, 28, estudioId),
      createMuestreo(417245, 2092266, 33, estudioId),
      createMuestreo(417255, 2092264, 27, estudioId),
      createMuestreo(417264, 2092260, 0, estudioId),
      createMuestreo(417298, 2092274, 0, estudioId),
      createMuestreo(417286, 2092264, 2, estudioId),
      createMuestreo(417281, 2092269, 0, estudioId),
      createMuestreo(417267, 2092269, 11, estudioId),
      createMuestreo(417262, 2092274, 10, estudioId),
      createMuestreo(417249, 2092273, 0, estudioId),
      createMuestreo(417236, 2092270, 5, estudioId),
      createMuestreo(417228, 2092271, 0, estudioId),
      createMuestreo(417214, 2092269, 7, estudioId),
      createMuestreo(417206, 2092268, 15, estudioId),
      createMuestreo(417211, 2092279, 0, estudioId),
      createMuestreo(417216, 2092279, 6, estudioId),
      createMuestreo(417297, 2092279, 0, estudioId),
      createMuestreo(417303, 2092285, 0, estudioId),
      createMuestreo(417278, 2092285, 0, estudioId),
      createMuestreo(417273, 2092283, 0, estudioId),
      createMuestreo(417261, 2092285, 0, estudioId),
      createMuestreo(417253, 2092287, 0, estudioId),
      createMuestreo(417227, 2092290, 0, estudioId),
      createMuestreo(417218, 2092287, 0, estudioId),
      createMuestreo(417218, 2092289, 15, estudioId),
      createMuestreo(417216, 2092289, 0, estudioId),
      createMuestreo(417206, 2092301, 3, estudioId),
      createMuestreo(417216, 2092298, 3, estudioId),
      createMuestreo(417232, 2092301, 0, estudioId),
      createMuestreo(417235, 2092299, 0, estudioId),
      createMuestreo(417253, 2092299, 0, estudioId),
      createMuestreo(417260, 2092294, 0, estudioId),
      createMuestreo(417273, 2092299, 0, estudioId),
      createMuestreo(417283, 2092296, 0, estudioId),
      createMuestreo(417295, 2092298, 0, estudioId),
      createMuestreo(417298, 2092297, 0, estudioId),
      createMuestreo(417229, 2092309, 0, estudioId),
      createMuestreo(417222, 2092308, 0, estudioId),
      createMuestreo(417219, 2092325, 0, estudioId),
      createMuestreo(417215, 2092316, 0, estudioId),
      createMuestreo(417243, 2092320, 0, estudioId),
      createMuestreo(417247, 2092316, 0, estudioId),
      createMuestreo(417257, 2092316, 0, estudioId),
      createMuestreo(417268, 2092315, 0, estudioId),
      createMuestreo(417275, 2092322, 0, estudioId),
      createMuestreo(417266, 2092324, 0, estudioId),
      createMuestreo(417258, 2092322, 0, estudioId),
      createMuestreo(417256, 2092325, 0, estudioId),
      createMuestreo(417240, 2092323, 0, estudioId),
      createMuestreo(417234, 2092323, 0, estudioId),
      createMuestreo(417244, 2092334, 0, estudioId),
      createMuestreo(417248, 2092334, 0, estudioId),
      createMuestreo(417259, 2092334, 20, estudioId),
      createMuestreo(417267, 2092333, 5, estudioId),
      createMuestreo(417276, 2092332, 0, estudioId),
      createMuestreo(417284, 2092335, 0, estudioId),
      createMuestreo(417289, 2092334, 0, estudioId),
      createMuestreo(417296, 2092333, 0, estudioId),
      createMuestreo(417306, 2092342, 0, estudioId),
      createMuestreo(417299, 2092345, 0, estudioId),
      createMuestreo(417289, 2092347, 0, estudioId),
      createMuestreo(417279, 2092346, 0, estudioId),
      createMuestreo(417259, 2092343, 0, estudioId),
      createMuestreo(417249, 2092347, 0, estudioId),
      createMuestreo(417222, 2092357, 12, estudioId),
      createMuestreo(417220, 2092355, 0, estudioId),
      createMuestreo(417222, 2092361, 17, estudioId),
      createMuestreo(417229, 2092354, 22, estudioId),
      createMuestreo(417256, 2092354, 36, estudioId),
      createMuestreo(417261, 2092356, 0, estudioId),
      createMuestreo(417276, 2092354, 8, estudioId),
      createMuestreo(417285, 2092355, 0, estudioId),
      createMuestreo(417292, 2092354, 0, estudioId),
      createMuestreo(417301, 2092349, 0, estudioId),
      createMuestreo(417360, 2092358, 12, estudioId),
      createMuestreo(417362, 2092363, 12, estudioId),
      createMuestreo(417360, 2092363, 20, estudioId),
      createMuestreo(417353, 2092365, 30, estudioId),
      createMuestreo(417346, 2092367, 32, estudioId),
      createMuestreo(417336, 2092366, 36, estudioId),
      createMuestreo(417332, 2092364, 39, estudioId),
      createMuestreo(417321, 2092369, 29, estudioId),
      createMuestreo(417315, 2092374, 100, estudioId),
      createMuestreo(417307, 2092376, 50, estudioId),
      createMuestreo(417303, 2092375, 50, estudioId),
      createMuestreo(417296, 2092378, 64, estudioId),
      createMuestreo(417292, 2092378, 65, estudioId),
      createMuestreo(417285, 2092379, 80, estudioId),
      createMuestreo(417285, 2092376, 90, estudioId),
      createMuestreo(417270, 2092375, 75, estudioId),
      createMuestreo(417268, 2092372, 60, estudioId),
      createMuestreo(417257, 2092372, 80, estudioId),
      createMuestreo(417254, 2092370, 88, estudioId),
      createMuestreo(417247, 2092369, 50, estudioId),
      createMuestreo(417233, 2092368, 70, estudioId),
      createMuestreo(417227, 2092368, 70, estudioId),
      createMuestreo(417223, 2092381, 45, estudioId),
      createMuestreo(417220, 2092382, 64, estudioId),
      createMuestreo(417214, 2092381, 62, estudioId),
      createMuestreo(417204, 2092383, 85, estudioId),
      createMuestreo(417201, 2092381, 70, estudioId),
      createMuestreo(417188, 2092383, 62, estudioId),
      createMuestreo(417184, 2092380, 65, estudioId),
      createMuestreo(417183, 2092383, 130, estudioId),
      createMuestreo(417174, 2092384, 130, estudioId),
      createMuestreo(417176, 2092381, 130, estudioId),
      createMuestreo(417193, 2092391, 45, estudioId),
      createMuestreo(417211, 2092394, 77, estudioId),
      createMuestreo(417214, 2092395, 0, estudioId),
      createMuestreo(417237, 2092393, 36, estudioId),
      createMuestreo(417241, 2092393, 36, estudioId),
      createMuestreo(417244, 2092389, 42, estudioId),
      createMuestreo(417247, 2092386, 40, estudioId),
      createMuestreo(417281, 2092394, 23, estudioId),
      createMuestreo(417283, 2092393, 0, estudioId),
      createMuestreo(417291, 2092390, 0, estudioId),
      createMuestreo(417293, 2092388, 0, estudioId),
      createMuestreo(417302, 2092385, 50, estudioId),
      createMuestreo(417304, 2092384, 15, estudioId),
      createMuestreo(417315, 2092384, 27, estudioId),
      createMuestreo(417312, 2092392, 0, estudioId),
      createMuestreo(417308, 2092394, 7, estudioId),
      createMuestreo(417303, 2092396, 32, estudioId),
      createMuestreo(417300, 2092395, 19, estudioId),
      createMuestreo(417288, 2092393, 7, estudioId),
      createMuestreo(417287, 2092390, 23, estudioId),
      createMuestreo(417275, 2092390, 18, estudioId),
      createMuestreo(417260, 2092394, 33, estudioId),
      createMuestreo(417256, 2092392, 8, estudioId),
      createMuestreo(417245, 2092390, 7, estudioId),
      createMuestreo(417237, 2092395, 12, estudioId),
      createMuestreo(417232, 2092402, 20, estudioId),
      createMuestreo(417213, 2092403, 44, estudioId),
      createMuestreo(417206, 2092402, 17, estudioId),
      createMuestreo(417205, 2092392, 20, estudioId),
      createMuestreo(417185, 2092399, 0, estudioId),
      createMuestreo(417196, 2092407, 18, estudioId),
      createMuestreo(417218, 2092408, 14, estudioId),
      createMuestreo(417236, 2092411, 0, estudioId),
      createMuestreo(417238, 2092415, 0, estudioId),
      createMuestreo(417262, 2092416, 17, estudioId),
      createMuestreo(417263, 2092411, 24, estudioId),
      createMuestreo(417273, 2092413, 22, estudioId),
      createMuestreo(417278, 2092410, 14, estudioId),
      createMuestreo(417297, 2092407, 22, estudioId),
      createMuestreo(417293, 2092419, 0, estudioId),
    ];

    return muestreos;
  }
}

/*

 List<Muestreo> muestreos = [
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135325,
          este: 371451.5,
          incidencia: 14,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135329.9,
          este: 371448.8,
          incidencia: 20,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135336,
          este: 371472.7,
          incidencia: 26,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135341.7,
          este: 371470,
          incidencia: 36,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135350.5,
          este: 371492,
          incidencia: 21,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135352.8,
          este: 371494.8,
          incidencia: 10,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135361.7,
          este: 371512.7,
          incidencia: 16,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135366.6,
          este: 371514.7,
          incidencia: 13,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135374.5,
          este: 371524.5,
          incidencia: 17,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135374.2,
          este: 371528.9,
          incidencia: 21,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135393.9,
          este: 371537.3,
          incidencia: 20,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135398,
          este: 371533.6,
          incidencia: 13,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135386.4,
          este: 371517.9,
          incidencia: 18,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135387.1,
          este: 371512.7,
          incidencia: 26,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135374.8,
          este: 371492.6,
          incidencia: 15,
          zona: "",
          estudioId: estudioId),
      new Muestreo(
          latitud: 10.0,
          longitud: 10.0,
          norte: 2135370.7,
          este: 371491.3,
          incidencia: 13,
          zona: "",
          estudioId: estudioId),
    ];
*/
