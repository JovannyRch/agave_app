import 'package:agave_app/backend/models/estudio_model.dart';
import 'package:agave_app/backend/providers/estudios_provider.dart';
import 'package:agave_app/helpers/krigeado.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'dart:convert';

class HeatMap extends StatefulWidget {
  Estudio estudio;
  Modelo modelo;
  HeatMap(this.estudio, this.modelo, {super.key});

  @override
  _HeatMapState createState() => _HeatMapState();
}

class _HeatMapState extends State<HeatMap> {
  int maxIncidencia = 200;

  int maxNorte = 0;

  int maxEste = 0;

  int minNorte = 0;

  int minEste = 0;

  int contador0 = 0;

  List<int> rangoNorte = [];

  List<int> rangoEste = [];

  List<int> incidencias = [];
  String dataString = '';

  bool isLoading = false;
  late Krigeado krigeado;

  double porcentajeInfestacion = 0.0;

  late Size _size;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    final limitesNorte =
        await EstudiosProvider.db.getMinMaxNorte(widget.estudio.id ?? 0);
    final limitesEste =
        await EstudiosProvider.db.getMinMaxEste(widget.estudio.id ?? 0);
    maxIncidencia =
        await EstudiosProvider.db.getMaxIncidencia(widget.estudio.id ?? 0);
    maxNorte = limitesNorte['maximo']!.ceil();
    minNorte = limitesNorte['minimo']!.floor();

    maxEste = limitesEste['maximo']!.ceil();
    minEste = limitesEste['minimo']!.floor();

    rangoEste = getRango(minEste, maxEste);
    rangoNorte = getRango(minNorte, maxNorte);

    final xData = [];
    final yData = [];
    List<List<double>> data = [];
    for (var i = minNorte; i <= maxNorte; i++) {
      data.add([]);
      for (var j = minEste; j <= maxEste; j++) {
        yData.add(j - minEste);
        data[i - minNorte].add(0);
      }
      xData.add(i - minNorte);
    }
    contador0 = 0;
    print("Cantidad de incidencias: ${widget.estudio.muestreos.length}");
    for (var f in widget.estudio.muestreos) {
      var indexX = f.norte.round() - minNorte;
      var indexy = f.este.round() - minEste;
      data[indexX][indexy] = f.incidencia.toDouble();
    }

    Krigeado k = Krigeado(
        estudio: widget.estudio,
        modelo: widget.modelo,
        meseta: widget.estudio.meseta,
        rango: widget.estudio.rango,
        efectoPepita: widget.estudio.pepita);

    //Calcular krigeado para cada punto con valor de incidencia = 0
    print("calculando krigeado");
    for (var i = minNorte; i <= maxNorte; i++) {
      for (var j = minEste; j <= maxEste; j++) {
        int iX = i - minNorte;
        int jX = j - minEste;
        if (data[iX][jX] == 0) {
          data[iX][jX] = k.krigeadoEnPunto(i.toDouble(), j.toDouble());
          if (data[iX][jX] == 0.0) {
            contador0++;
          }
        }
      }
    }
    print("fin del krigeado");

    dataString = "[";
    for (var i = minNorte; i <= maxNorte; i++) {
      for (var j = minEste; j <= maxEste; j++) {
        dataString = "$dataString[${i - minNorte}, ${j - minEste}, ${data[i - minNorte][j - minEste]}],";
      }
    }
    dataString = dataString.substring(0, dataString.length - 1);
    dataString = "$dataString]";

    porcentajeInfestacion = calcularPorcentajeInfestacion();

    setState(() {
      isLoading = false;
    });
  }

  List<int> getRango(int min, int max) {
    List<int> res = [];
    for (int i = min; i <= max; i++) {
      res.add(i);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de densidad"),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _renderChart(),
        _porcentajeInfestacion(),
      ],
    );
  }

  Widget _porcentajeInfestacion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          const Text(
            "% infestación: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(porcentajeInfestacion.toStringAsFixed(2))
        ],
      ),
    );
  }

  double calcularPorcentajeInfestacion() {
    double porcentaje = 0.0;

    int width = maxNorte - minNorte;
    int height = maxEste - minEste;

    int area = height * width;

    porcentaje = (contador0 * 100 / area);
    porcentaje = 100.0 - porcentaje;
    return porcentaje;
  }

  Widget _renderChart() {
    if (dataString == null) {
      return Container();
    }

    return Center(
      child: SizedBox(
        height: _size.height * 0.83,
        width: _size.width,
        child: Echarts(
          captureAllGestures: true,
          option: '''
                       {
        tooltip: {},
        xAxis: {
            type: 'category',
            data: ${jsonEncode(rangoEste)}
        },
        yAxis: {
            type: 'category',
            data: ${jsonEncode(rangoNorte)}
        },
        visualMap: {
            min: 0,
            max: $maxIncidencia,
            calculable: true,
            realtime: false,
            inRange: {
                color: ['#e4ffc4', '#a1db3b', '#aedb3b', '#bbdb3b', '#c8db3b', '#d8db3b', '#dbd33b', '#dbc83b', '#dbbb3b', '#dbb03b','#db9b3b','#db8b3b','#db7b3b','#db5e3b', '#db3b3b']
            }
        },
        series: [{
            name: 'Incidencias',
            type: 'heatmap',
            data: $dataString,
            emphasis: {
                itemStyle: {
                    borderColor: '#333',
                    borderWidth: 1
                }
            },
            progressive: 100,
            animation: true
        }]
}
                      ''',
        ),
      ),
    );
  }
}
