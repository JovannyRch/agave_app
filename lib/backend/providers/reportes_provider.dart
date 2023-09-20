import 'dart:io';
import 'package:agave_app/backend/models/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ReportesProvider {
  static Database? _database;
  static final ReportesProvider db = ReportesProvider._();

  String dbName = kDBname;
  String tabla = "parcelas";
  ReportesProvider._();

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

  Future<int> total(String table) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(*) total from $table");

    if (res.isEmpty) return 0;
    return int.parse(res.first['total'].toString());
  }

  Future<int> totalIncidencias() async {
    try {
      final db = await database;
      final res =
          await db!.rawQuery("SELECT sum(incidencia) total from muestreos");

      if (res.isEmpty) return 0;
      return int.parse(res.first['total'].toString());
    } catch (e) {
      print("Error en totalIncidencias ${e.toString()}");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> reportePlagas() async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT plagas.nombre,(SELECT sum(muestreos.incidencia) from muestreos where muestreos.estudioId in "
        "(SELECT estudios.id from estudios where estudios.plagaId = plagas.id)"
        ") total from plagas where total > 0 LIMIT 5");
    /*  print("Reporte de plagas");
    print(res); */
    return res;
  }
}
