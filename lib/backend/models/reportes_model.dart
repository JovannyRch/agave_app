import 'package:agave_app/backend/providers/reportes_provider.dart';

class ReportesModel {
  ReportesModel();

  Future<int> totalParcelas() {
    return ReportesProvider.db.total("parcelas");
  }

  Future<int> totalMuestreos() {
    return ReportesProvider.db.total("muestreos");
  }

  Future<int> totalEstudios() {
    return ReportesProvider.db.total("estudios");
  }

  Future<int> totalIncidencias() {
    return ReportesProvider.db.totalIncidencias();
  }

  Future<List<Map<String, dynamic>>> reportePlagas() async {
    //Obtener las plagas por nivel
    return ReportesProvider.db.reportePlagas();
  }
}
