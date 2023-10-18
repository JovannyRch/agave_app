import 'dart:io';
import 'package:agave_app/backend/models/database.dart';
import 'package:agave_app/backend/models/parcela_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ParcelasProvider {
  static Database? _database;
  static final ParcelasProvider db = ParcelasProvider._();

  String dbName = kDBname;
  String tabla = "parcelas";
  ParcelasProvider._();

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

  insert(Parcela scan) async {
    final db = await database;
    return await db!.insert(tabla, scan.toJson());
  }

  Future<Parcela?> getById(int id) async {
    final db = await database;
    final res = await db!.query(tabla, where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? Parcela.fromJson(res.first) : null;
  }

  Future<List<Parcela>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    return res.isEmpty
        ? []
        : res.map((registro) => Parcela.fromJson(registro)).toList();
  }

  Future<int> update(Parcela tajeta) async {
    final db = await database;
    final res = await db!.update(tabla, tajeta.toJson(),
        where: 'id = ?', whereArgs: [tajeta.id]);
    return res;
  }

  Future<int> delete(String id, {tabla = "parcelas", campo = "id"}) async {
    final db = await database;
    final res = await db!.delete(tabla, where: '$campo = ?', whereArgs: [id]);
    return res;
  }

  Future<int> deleteAll() async {
    final db = await database;
    final res = await db!.rawDelete("DELETE from $tabla");
    return res;
  }

  Future<int> getTotal() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(id) total from $tabla");
    print(res);
    return res.first['total'] == null
        ? 0
        : int.parse(res.first['total'].toString());
  }

  Future<int> getMuestreos(int parcelaId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT count(id) total from estudios where parcelaId = $parcelaId");

    return res.isEmpty ? 0 : int.parse(res.first['total'].toString());
  }

  Future<String> getLastMuestreo(int parcelaId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT createdAt from estudios where parcelaId = $parcelaId order by createdAt desc limit 1 ");
    return res.isEmpty ? "--" : res.first['createdAt'].toString();
  }

  Future<List<String>> getPhotos(int parcelaId) async {
    final db = await database;
    final res = await db!
        .rawQuery("SELECT url from fotos where parcelaId = $parcelaId");
    List<String> arr = [];
    for (var row in res) {
      arr.add(row['url'].toString());
    }
    return arr;
  }

  insertFoto(String foto, int parcelaId) async {
    final db = await database;
    Map<String, dynamic> data = {'url': foto, 'parcelaId': parcelaId};
    return await db!.insert('fotos', data);
  }

  Future<int> totalEstudios(int parcelaId) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT count(*) total from estudios where parcelaId = $parcelaId");

    if (res.isEmpty) return 0;

    return int.parse(res.first['total'].toString());
  }

  Future<String> plagaPrincipal(int parcelaId) async {
    final db = await database;
    try {
      final res = await db!.rawQuery("SELECT plagas.nombre, "
          "(SELECT sum(incidencia) total from muestreos where muestreos.estudioId in "
          "(SELECT estudios.id from estudios where estudios.parcelaId = $parcelaId and "
          "estudios.plagaid = plagas.id)"
          " ) total from plagas where total > 0 order by total desc");
      //print(res);
      if (res.isEmpty) return "--";
      return res.first['nombre'].toString();
    } catch (e) {
      print(e.toString());
      return "--";
    }
  }

  //Plaga principal

  /* Future<String> plagaPrincipal(int parcelaId) async {
    final db = await database;
    final res = db!.rawQuery("SELECT nombre from plagas where id in "
    "( SELECT SUM())"
    );
  } */
}
