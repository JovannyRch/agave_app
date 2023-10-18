import 'package:agave_app/backend/ajuste_model.dart';
import 'package:agave_app/backend/models/chart_data.dart';
import 'package:agave_app/backend/models/muestreo_model.dart';
import 'package:agave_app/helpers/calculos.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sample_statistics/sample_statistics.dart';

class AjusteScreen extends StatefulWidget {
  final Ajuste ajuste;
  final String modelo;
  final List<Muestreo> muestreos;
  final List<double> distanciasSemivariograma;
  final List<double> incidenciaSemivariograma;
  final List<double> valoresModelo;
  List<ChartData> chartData = [];

  AjusteScreen({super.key, 
    required this.ajuste,
    required this.modelo,
    required this.muestreos,
    required this.distanciasSemivariograma,
    required this.incidenciaSemivariograma,
    required this.chartData,
    required this.valoresModelo,
  });

  @override
  _AjusteScreenState createState() => _AjusteScreenState();
}

class _AjusteScreenState extends State<AjusteScreen> {
  bool isFixing = false;
  bool isValid = true;
  String message = "";
  List<double> datos = [];
  late Coeficientes coeficientes;
  late Size size;
  List<double> valoresModelos2 = [];
  double maxMeseta = 500;
  double maxRango = 500;

  List<FlSpot> graphData = [];

  List<Color> gradientColors = [
    const Color(0xff02d39a),
    const Color(0xff02d39a),
  ];

  List<Color> gradientColors2 = [
    Colors.red,
    Colors.redAccent,
  ];

  List<Color> gradientColorsYelow = [
    Colors.yellow,
    Colors.yellowAccent,
  ];

  List<Color> gradientColorsPink = [
    Colors.pink,
    Colors.pinkAccent,
  ];

  List<Color> gradientColorsWhite = [
    Colors.white,
    Colors.white,
  ];

  void setIsFixing(bool val) {
    setState(() {
      isFixing = val;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    /* 
    isValid = widget.ajuste.checkModel(widget.modelo);
    if(!isValid){
      message = widget.ajuste.errorMessage;
    }
     */

    valoresModelos2 = [...widget.valoresModelo];
    graphData = getGraphData();
    setIsFixing(true);
    hacerCalculos();
    setIsFixing(false);
  }

  void hacerCalculos() {
    Calculos calculos = Calculos();
    List<double> incidencias =
        widget.muestreos.map((e) => e.incidencia.toDouble()).toList();
    Stats distanciaStats =
        Stats(widget.chartData.map((e) => e.distancia).toList());
    Stats semivariogramaStats =
        Stats(widget.chartData.map((e) => e.semivariograma).toList());
    maxMeseta = semivariogramaStats.max.toDouble();
    maxRango = distanciaStats.max.toDouble();

    coeficientes = calculos.mainCalculo(widget.distanciasSemivariograma,
        widget.incidenciaSemivariograma, incidencias);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajuste"),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (isFixing) {
      return _loading();
    }

    if (!isValid) {
      return _noValid();
    }

    List<num> cuartiles = [
      coeficientes.stats.quartile1,
      coeficientes.stats.median,
      coeficientes.stats.quartile3
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cardDetail(
                    "${formatNumber(coeficientes.curtosis)}", "C. Curtosis"),
                _cardDetail(
                    "${formatNumber(coeficientes.varianza)}", "C. Variación"),
                _cardDetail(
                    "${formatNumber(coeficientes.asimetria)}", "C. Asimetría"),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cardDetail(
                    "${formatNumber(coeficientes.covarianza)}", "Covarianza"),
                _cardDetail(
                    "${formatNumber(coeficientes.stats.median.toDouble())}",
                    "Mediana"),
                _cardDetail("${0.0}", "Moda"), //FIX: Mode
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cardDetail("${cuartiles[0]}", "1er Cuartil"),
                _cardDetail("${cuartiles[2]}", "3er Cuartil"),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cardDetail("${formatNumber(coeficientes.stats.max)}", "Max"),
                _cardDetail("${formatNumber(coeficientes.stats.min)}", "Min"),
              ],
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Ecuación de Regresión líneal = "),
                Text(
                    "${formatNumber(coeficientes.regresionLineal.a)} + ${formatNumber(coeficientes.regresionLineal.b)}X")
              ],
            ),
            _grafica(),
            _details(),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  Widget _details() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cardDetail(widget.modelo, "Modelo"),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cardDetail("${widget.ajuste.rango}", "Rango"),
              _cardDetail("${widget.ajuste.meseta}", "Meseta"),
              _cardDetail("${widget.ajuste.pepita}", "Pepita"),
            ],
          )
        ],
      ),
    );
  }

  Widget _cardDetail(String main, String secondary) {
    return Container(
      width: 120,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            main,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5.0),
          Text(
            secondary,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.0),
          ),
        ],
      ),
    );
  }

  Widget _noValid() {
    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Ajuste no válido"),
          Text(message),
        ],
      )),
    );
  }

  Widget _loading() {
    return Container(
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: const FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
        )),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
        )),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      lineBarsData: [
        /*   LineChartBarData(
          spots: widget.chartData
              .map((e) => new FlSpot(e.distancia, e.semivariograma))
              .toList(),
          isCurved: false,
          colors: gradientColors2,
          barWidth: 0.0,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true,
          ),
        ), */
        LineChartBarData(
          gradient: LinearGradient(
            colors: gradientColors.toList(),
          ),
          spots: graphData,
          isCurved: true,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
        /* LineChartBarData(
          spots: mesetaDataGraph(),
          isCurved: false,
          colors: gradientColorsYelow,
          barWidth: 0.0,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true,
          ),
        ),
        LineChartBarData(
          spots: rangoDataGraph(),
          isCurved: false,
          colors: gradientColorsPink,
          barWidth: 0.0,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true,
          ),
        ),
        LineChartBarData(
          spots: getGraphData2(),
          isCurved: false,
          colors: gradientColorsWhite,
          barWidth: 0.0,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
        ), */
      ],
    );
  }

  List<FlSpot> getGraphData() {
    List<FlSpot> result = [];
    int n = widget.chartData.length;
    for (int i = 0; i < n; i++) {
      double y = widget.valoresModelo[i];
      double x = widget.chartData[i].distancia;
      result.add(FlSpot(x, y));
    }

    return result;
  }

  List<FlSpot> getGraphData2() {
    List<FlSpot> result = [];
    int n = widget.chartData.length;
    for (int i = 0; i < n; i++) {
      double y = valoresModelos2[i];
      double x = widget.chartData[i].distancia;
      result.add(FlSpot(x, y));
    }

    return result;
  }

  List<FlSpot> mesetaDataGraph() {
    List<FlSpot> result = [];
    int n = widget.chartData.length;
    for (int i = 0; i < n; i++) {
      double y = widget.ajuste.meseta;
      double x = widget.chartData[i].distancia;
      result.add(FlSpot(x, y));
    }
    return result;
  }

  List<FlSpot> rangoDataGraph() {
    List<FlSpot> result = [];
    int n = widget.chartData.length;
    for (int i = 0; i < n; i++) {
      double x = widget.ajuste.rango;
      double y = widget.valoresModelo[i];
      result.add(FlSpot(x, y));
    }

    return result;
  }

  Widget _grafica() {
    var stack = Stack(
      children: <Widget>[
        Container(
          height: size.height * 0.8,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: Color(0xff232d37),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                right: 18.0, left: 12.0, top: 44, bottom: 12),
            child: LineChart(mainData()),
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            stack,
          ],
        ),
      ),
    );
  }
}
