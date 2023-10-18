import 'dart:io';
import 'package:agave_app/backend/models/muestreo_model.dart';
import 'package:agave_app/backend/models/database.dart';
import 'package:agave_app/backend/models/estudio_model.dart';
import 'package:agave_app/backend/models/plaga_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EstudiosProvider {
  static Database? _database;
  static final EstudiosProvider db = EstudiosProvider._();

  String dbName = kDBname;
  String tabla = "estudios";
  EstudiosProvider._();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, '$dbName.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      List<String> tablas = kTables;
      for (String tabla in tablas) {
        await db.execute(tabla);
      }
    });
  }

  insert(Estudio scan) async {
    final db = await database;
    return await db?.insert(tabla, scan.toJson());
  }

  Future<Estudio?> getById(int id) async {
    final db = await database;
    final res = await db?.query(tabla, where: 'id = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Estudio.fromJson(res.first) : null;
  }

  Future<List<Estudio>> getAll() async {
    final db = await database;
    final res = await db?.query(tabla);
    return res!.isEmpty
        ? []
        : res.map((registro) => Estudio.fromJson(registro)).toList();
  }

  Future<List<Estudio>> getAllByParcela(int parcelaId) async {
    final db = await database;
    final res = await db!
        .rawQuery("SELECT * from estudios where parcelaId = $parcelaId");
    return res.isEmpty
        ? []
        : res.map((registro) => Estudio.fromJson(registro)).toList();
  }

  Future<int> update(Estudio data) async {
    final db = await database;
    final res = await db!
        .update(tabla, data.toJson(), where: 'id = ?', whereArgs: [data.id]);
    return res;
  }

  Future<int> delete(String id, {tabla = "estudios", campo = "id"}) async {
    final db = await database;
    final res = await db!.delete(tabla, where: '$campo = ?', whereArgs: [id]);
    return res;
  }

  Future<int> deleteAll() async {
    final db = await database;
    final res = await db!.rawDelete("DELETE from $tabla");
    return res;
  }

  Future<int> insertPlaga(String nombre) async {
    final db = await database;
    Map<String, dynamic> data = {'nombre': nombre};
    return await db!.insert("plagas", data);
  }

  Future<List<Plaga>> getPlagas() async {
    final db = await database;
    var res = await db!.query("plagas");

    if (res.isEmpty) {
      for (String plaga in males) {
        await insertPlaga(plaga);
      }
      res = await db.query("plagas");
    }
    return res.isEmpty
        ? []
        : res.map((registro) => Plaga.fromJson(registro)).toList();
  }

  Future<int> totalMuestras(int estudioId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT count(*) total from muestreos where estudioId = $estudioId");

    if (res.isEmpty) return 0;
    return int.parse(res.first['total'].toString());
  }

  Future<int> incidencias(int estudioId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT sum(incidencia) suma from muestreos where estudioId = $estudioId");
    return res.first['suma'] == null
        ? 0
        : int.parse(res.first['suma'].toString());
  }

  Future<double> getPromedio(int estudioId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT avg(incidencia) promedio from muestreos where estudioId = $estudioId");

    return res.first['promedio'] == null
        ? 0
        : double.parse(
            double.parse(res.first['promedio'].toString()).toStringAsFixed(1));
  }

  Future<String> getPlaga(int plagaId) async {
    final db = await database;
    final res =
        await db!.rawQuery("SELECT nombre from plagas where id = $plagaId");
    if (res.isEmpty) return "--";
    return res.first['nombre'].toString();
  }

  Future<List<Muestreo>> getMuestreos(int estudioId) async {
    final db = await database;
    final res = await db!
        .rawQuery("SELECT * from muestreos where estudioId = $estudioId");
    List<Muestreo> muestreos = [];
    for (var item in res) {
      muestreos.add(Muestreo.fromJson(item));
    }

    return muestreos;
  }

  Future<Map<String, double>> getMinMaxNorte(int estudioId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT min(norte) minimo, max(norte) maximo from muestreos where estudioId = $estudioId");
    final minimo = double.parse(res.first['minimo'].toString()) ?? 0.0;
    final maximo = double.parse(res.first['maximo'].toString()) ?? 0.0;
    return {'minimo': minimo, 'maximo': maximo};
  }

  Future<Map<String, double>> getMinMaxEste(int estudioId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT min(este) minimo, max(este) maximo from muestreos where estudioId = $estudioId");
    double minimo = double.parse(res.first['minimo'].toString()) ?? 0.0;
    double maximo = double.parse(res.first['maximo'].toString()) ?? 0.0;
    return {'minimo': minimo, 'maximo': maximo};
  }

  Future<int> getMaxIncidencia(int estudioId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT max(incidencia) maximo from muestreos where estudioId = $estudioId");
    final maximo = int.parse(res.first['maximo'].toString()) ?? 1;
    return maximo;
  }

  Future<int> getNextId() async {
    final db = await database;
    final res = await db?.rawQuery('SELECT MAX(id) as lastId FROM $tabla');
    int lasId = int.parse(((res!.first['lastId'] ?? 0).toString()));
    return lasId + 1;
  }
}
