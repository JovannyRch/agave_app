import 'dart:async';

import 'package:agave_app/backend/models/parcela_model.dart';
import 'package:agave_app/backend/providers/parcelas_provider.dart';

class ParcelasBloc {
  static final ParcelasBloc _singleton = ParcelasBloc._internal();

  factory ParcelasBloc() => _singleton;

  ParcelasBloc._internal() {
    getDatos();
  }

  final _dataController = StreamController<List<Parcela>>.broadcast();

  Stream<List<Parcela>> get parcelas => _dataController.stream;

  dispose() {
    _dataController.close();
  }

  getDatos() async {
    _dataController.sink.add(await ParcelasProvider.db.getAll());
  }

  deleteData(int id) async {
    await ParcelasProvider.db.delete("$id");
    getDatos();
  }

  deletaALl() async {
    await ParcelasProvider.db.deleteAll();
    getDatos();
  }

  create(Parcela data) async {
    await ParcelasProvider.db.insert(data);
    getDatos();
  }
}
