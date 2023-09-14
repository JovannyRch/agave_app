import 'package:agave_app/backend/models/plaga_model.dart';

final String kDBname = "ahuacatl_database";
List<String> males = [
  'Araña Roja',
  'Barrenador de la rama',
  'Barrenador del fruto',
  'Minador de la hoja',
  'Mosca Blanca',
  'Mosca Verde',
  'Gusano arrollador de la hoja',
  'Escama',
  'Escama Armada',
  'Thrips',
  'Pudrición de la raíz',
  'Cancro',
  'Marchitamiento',
  'Antracnosis',
  'Roña',
  'Cercosporiosis',
  'Mildeu',
  'Fusariosis',
];

final tablaCultivos = "CREATE TABLE  IF NOT EXISTS cultivos"
    "(id INEGER PRIMARY KEY,"
    "nombre TEXT"
    ")";
final queryAguacate = "INSERT INTO cultivos(id, nombre) VALUES(1,'Aguacate')";

final tablaParcelas = "CREATE TABLE  IF NOT EXISTS parcelas"
    "(id INTEGER PRIMARY KEY,"
    "descripcion TEXT,"
    "cultivoId INTEGER default 1,"
    "createdAt TEXT,"
    "superficie REAL,"
    "FOREIGN KEY(cultivoId) REFERENCES cultivos(id) ON DELETE CASCADE"
    ")";

final tablaFotos = "CREATE TABLE IF NOT EXISTS fotos"
    "(id INTEGER PRIMARY KEY,"
    "url TEXT,"
    "parcelaId INTEGER,"
    "FOREIGN KEY(parcelaId) REFERENCES parcelas(id) ON DELETE CASCADE"
    ")";

final tablaPlagas = "CREATE TABLE  IF NOT EXISTS plagas"
    "(id INTEGER PRIMARY KEY,"
    "nombre TEXT"
    ")";

final tablaEstudios = "CREATE TABLE IF NOT EXISTS estudios"
    "(id INTEGER PRIMARY KEY,"
    "createdAt TEXT,"
    "temperatura REAL,"
    "humedad REAL,"
    "parcelaId INTEGER,"
    "plagaId INTEGER,"
    "modelo TEXT,"
    "rango REAL,"
    "meseta REAL,"
    "pepita REAL,"
    "datosModelo Text,"
    "FOREIGN KEY(parcelaId) REFERENCES parcelas(id) ON DELETE CASCADE,"
    "FOREIGN KEY(plagaId) REFERENCES plagas(id) ON DELETE CASCADE"
    ")";

final tablaMuestreos = "CREATE TABLE IF NOT EXISTS muestreos"
    "(id INTEGER PRIMARY KEY,"
    "latitud REAL,"
    "longitud REAL,"
    "norte REAL,"
    "este REAL,"
    "zona TEXT,"
    "estudioId INTEGER,"
    "incidencia INTEGER,"
    "fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
    "FOREIGN KEY(estudioId) REFERENCES estudios(id) ON DELETE CASCADE"
    ")";

final List<String> kTables = [
  tablaCultivos,
  queryAguacate,
  tablaFotos,
  tablaParcelas,
  tablaPlagas,
  tablaEstudios,
  tablaMuestreos,
  ...males.map((e) => "INSERT INTO plagas(nombre) VALUES('$e')").toList()
];

List<Plaga> getPlagas() {
  List<Plaga> res = [];
  for (var i = 1; i < males.length; i++) {
    res.add(Plaga(id: i + 1, nombre: males[i]));
  }
  return res;
}
