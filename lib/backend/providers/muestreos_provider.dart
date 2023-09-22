import 'dart:io';
import 'package:agave_app/backend/models/database.dart';
import 'package:agave_app/backend/models/muestreo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class MuestreosProvider {
  static Database? _database = null;
  static final MuestreosProvider db = MuestreosProvider._();

  String dbName = kDBname;
  String tabla = "muestreos";
  MuestreosProvider._();

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

  insert(Muestreo data) async {
    final db = await database;
    data.id = await getNextId();
    return await db!.insert(tabla, data.toJson());
  }

  Future<int> getNextId() async {
    final db = await database;
    final res = await db?.rawQuery('SELECT MAX(id) as lastId FROM $tabla');
    int lasId = int.parse(((res!.first['lastId'] ?? 0).toString()));
    return lasId + 1;
  }

  Future<int> total(String table) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(*) total from $table");
    if (res.length == 0) return 0;
    return int.parse(res.first['total'].toString());
  }
}
