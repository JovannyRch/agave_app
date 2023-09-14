import 'dart:async';

import 'package:agave_app/backend/models/estudio_model.dart';
import 'package:agave_app/backend/models/plaga_model.dart';
import 'package:agave_app/backend/providers/estudios_provider.dart';

class EstudiosBloc {
  static final EstudiosBloc _singleton = EstudiosBloc._internal();
  int parcelasId = 0;
  factory EstudiosBloc() => _singleton;

  EstudiosBloc._internal() {
    getDatos();
  }

  final _dataController = StreamController<List<Estudio>>.broadcast();

  Stream<List<Estudio>> get estudios => _dataController.stream;

  dispose() {
    _dataController?.close();
  }

  getDatos() async {
    _dataController.sink.add(parcelasId == null
        ? await EstudiosProvider.db.getAll()
        : await EstudiosProvider.db.getAllByParcela(parcelasId));
  }

  deleteData(int id) async {
    await EstudiosProvider.db.delete("$id");
    getDatos();
  }

  deletaALl() async {
    await EstudiosProvider.db.deleteAll();
    getDatos();
  }

  create(Estudio data) async {
    await EstudiosProvider.db.insert(data);
    getDatos();
  }

  Future<List<Plaga>> getPlagas() {
    return EstudiosProvider.db.getPlagas();
  }
}
