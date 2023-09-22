import 'dart:math';

import 'package:agave_app/backend/ajuste_model.dart';
import 'package:agave_app/backend/models/chart_data.dart';
import 'package:agave_app/backend/models/estudio_model.dart';
import 'package:agave_app/backend/models/muestreo_model.dart';
import 'package:agave_app/backend/models/renglon.dart';
import 'package:agave_app/const/const.dart';
import 'package:agave_app/helpers/utils.dart';
import 'package:agave_app/screens/parcelas/ajuste_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SemivariogramScreen extends StatefulWidget {
  Estudio estudio;

  SemivariogramScreen(@required this.estudio);

  @override
  _SemivariogramScreenState createState() => _SemivariogramScreenState();
}

class _SemivariogramScreenState extends State<SemivariogramScreen> {
  //TODO: Fix refresh and calculate semivariogram

  List<Color> gradientColors = [
    const Color(0xff02d39a),
    const Color(0xff02d39a),
  ];

  List<Color> redGradiant = [
    Colors.red,
    Colors.redAccent,
  ];

  List<Renglon> tabla = [];
  int currentPage = 0;
  late Size size;
  TextEditingController pepita = new TextEditingController();
  TextEditingController rango = new TextEditingController();
  TextEditingController meseta = new TextEditingController();
  String modeloDropdownValue = Ajuste.ESFERICO;
  List<ChartData> data = [];
  List<DataRow> rows = [];

  List<double> distanciasSemivariograma = [];
  List<double> incidenciaSemivariograma = [];
  List<double> valoresModelo = [];

  bool isAjustado = false;

  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    isAjustado = this.widget.estudio.modelo != null;

    data = this.calcularSemivariograma(widget.estudio);
    if (isAjustado) {
      pepita.text = this.widget.estudio.pepita.toString();
      rango.text = this.widget.estudio.rango.toString();
      meseta.text = this.widget.estudio.meseta.toString();
      modeloDropdownValue = this.widget.estudio.modelo.isEmpty
          ? Ajuste.ESFERICO
          : this.widget.estudio.modelo;

      Ajuste ajuste = new Ajuste(
        meseta: this.widget.estudio.meseta,
        pepita: this.widget.estudio.pepita,
        rango: this.widget.estudio.rango,
        datos: data,
      );
      setState(() {
        this.valoresModelo = ajuste.getValues(modeloDropdownValue);
        print("model values length ${valoresModelo.length}");
      });
    } else {
      pepita.text = "0.0";
      rango.text = "7.2";
      meseta.text = "360.8";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text("Semivariograma"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        currentIndex: currentPage,
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartLine),
            label: "Gráfica",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.table),
            label: "Tabla",
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: IndexedStack(
            index: currentPage,
            children: <Widget>[
              _grafica(),
              Container(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[_tabla()],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabla() {
    distanciasSemivariograma.clear();
    incidenciaSemivariograma.clear();

    tabla.forEach((r) {
      DataCell c0 = DataCell(Text(r.n.toString()));
      DataCell c1 = DataCell(Text(r.distancia.toString()));
      /*  DataCell c2 = DataCell(Text(r.suma.toString())); */
      DataCell c3 = DataCell(Text(r.yh.toString()));
      rows.add(DataRow(cells: [c0, c1, c3]));
      distanciasSemivariograma.add(r.distancia);
      incidenciaSemivariograma.add(r.yh);
    });
    return SingleChildScrollView(
      child: DataTable(
        columns: <DataColumn>[
          DataColumn(label: Text('n')),
          DataColumn(label: Text('Distancias')),
          /*   DataColumn(label: Text('Suma')), */
          DataColumn(label: Text('y(h)')),
        ],
        rows: rows,
      ),
    );
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
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            stack,
            SizedBox(
              height: 10.0,
            ),
            _rowInput(),
          ],
        ),
      ),
    );
  }

  Widget _rowInput() {
    var dropDown = DropdownButton<String>(
      value: modeloDropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      underline: Container(
        height: 2,
        color: kPrimaryColor,
      ),
      onChanged: (String? newValue) {
        setState(() {
          modeloDropdownValue = newValue ?? '';
        });
      },
      items: <String>[
        Ajuste.ESFERICO,
        Ajuste.EXPONENCIAL,
        Ajuste.GUASSIANO,
        Ajuste.NUGGET
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    /* Create new dropdown of Ajuste's values */

    ElevatedButton ajustarButton = ElevatedButton(
      onPressed: handleAjustarClick,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return kPrimaryColor;
          },
        ),
      ),
      child: Text(
        isAjustado ? "Volver a ajustar" : "Ajustar",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      /*  color: kPrimaryColor, */
    );

    ElevatedButton siguienteButton = ElevatedButton(
      onPressed: this.valoresModelo.isEmpty ? null : handleSiguienteClick,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return kPrimaryColor;
          },
        ),
      ),
      child: Text(
        "Siguiente",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      /*  color: kPrimaryColor, */
    );

    var row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 100.0,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: pepita,
            decoration: InputDecoration(
              labelText: "Pepita",
            ),
          ),
        ),
        Container(
          width: 100.0,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: meseta,
            decoration: InputDecoration(
              labelText: "Meseta",
            ),
          ),
        ),
        Container(
          width: 100.0,
          child: TextField(
            controller: rango,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Rango",
            ),
          ),
        ),
      ],
    );
    return Column(
      children: [
        row,
        dropDown,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ajustarButton,
            SizedBox(width: 10.0),
            siguienteButton,
          ],
        )
      ],
    );
  }

  void handleSiguienteClick() {
    double pepitaValue = double.parse(pepita.text ?? "0.0");
    double rangoValue = double.parse(rango.text ?? "0.0");
    double mesetaValue = double.parse(meseta.text ?? "0.0");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjusteScreen(
          modelo: modeloDropdownValue,
          ajuste: new Ajuste(
            meseta: mesetaValue,
            pepita: pepitaValue,
            rango: rangoValue,
            datos: data,
          ),
          muestreos: widget.estudio.muestreos,
          distanciasSemivariograma: distanciasSemivariograma,
          incidenciaSemivariograma: incidenciaSemivariograma,
          chartData: data,
          valoresModelo: valoresModelo,
        ),
      ),
    );
  }

  void handleAjustarClick() async {
    double pepitaValue = double.parse(pepita.text ?? "0.0");
    double rangoValue = double.parse(rango.text ?? "0.0");
    double mesetaValue = double.parse(meseta.text ?? "0.0");
    List<Muestreo> muestreos = [...widget.estudio.muestreos];
    String modelo = modeloDropdownValue;

    this.widget.estudio.pepita = pepitaValue;
    this.widget.estudio.rango = rangoValue;
    this.widget.estudio.meseta = mesetaValue;
    this.widget.estudio.modelo = modelo;

    await this.widget.estudio.update();

    Ajuste ajuste = new Ajuste(
      meseta: mesetaValue,
      pepita: pepitaValue,
      rango: rangoValue,
      datos: data,
    );

    if (!this.isAjustado) {
      this.isAjustado = true;
    }

    setState(() {
      this.valoresModelo = ajuste.getValues(modelo);
    });

    showSnackBar(context, "Ajuste completado");
  }

  LineChartData mainData() {
    List<LineChartBarData> charts = [
      LineChartBarData(
        spots: data.map((e) => FlSpot(e.distancia, e.semivariograma)).toList(),
        isCurved: false,
        gradient: LinearGradient(
          colors: gradientColors.toList(),
        ),
        barWidth: 0.0,
        isStrokeCapRound: false,
        dotData: FlDotData(
          show: true,
        ),
      )
    ];

    if (this.isAjustado) {
      charts.add(LineChartBarData(
        spots: getModelGraphData(),
        isCurved: false,
        gradient: LinearGradient(
          colors: redGradiant.toList(),
        ),
        barWidth: 0.0,
        isStrokeCapRound: false,
        dotData: FlDotData(
          show: true,
        ),
      ));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
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
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      lineBarsData: charts,
    );
  }

  List<FlSpot> getModelGraphData() {
    List<FlSpot> result = [];
    int n = data.length;
    for (int i = 0; i < n; i++) {
      double y = 0.0;
      if (i < this.valoresModelo.length) {
        y = this.valoresModelo[i];
      }
      double x = this.data[i].distancia;
      result.add(new FlSpot(x, y));
    }

    return result;
  }

  //Distancias
  List<ChartData> calcularSemivariograma(Estudio estudio) {
    List<int> incidencias = estudio.muestreos.map((e) => e.incidencia).toList();
    List<double> semivariogramaIncidencias =
        calcularSemivariogramaIncidenciasOrdendas(incidencias);
    List<double> distancias = calcularDistanciasOrdenadas(estudio.muestreos);

    double amplitud = distancias.last / 2;
    distancias = filtrarDistancias(distancias, amplitud);

    this.tabla.clear();
    List<ChartData> semivariograma2 = [];
    for (int i = 0; i < distancias.length; i++) {
      double incidencia = semivariogramaIncidencias[i];
      double distancia = distancias[i];
      distancia = double.parse(distancia.toStringAsFixed(2));
      incidencia = double.parse(incidencia.toStringAsFixed(2));
      final cD = new ChartData(distancia, incidencia);
      semivariograma2.add(cD);
      this.tabla.add(new Renglon(i, distancia, incidencia));
    }

    return semivariograma2;
  }

  List<double> filtrarDistancias(List<double> distancias, double umbral) {
    List<double> resultado = [];

    for (double d in distancias) {
      if (d <= umbral) {
        resultado.add(d);
      }
    }

    return resultado;
  }

  List<double> calcularSemivariogramaIncidenciasOrdendas(
      List<int> incidencias) {
    int numeroIncidencias = incidencias.length;
    int h = 1; //Distancia
    int numeroPares = incidencias.length - 1;
    List<double> semivariograma = [0];

    for (int i = 1; i <= numeroIncidencias - 1; i++) {
      int suma = 0;
      for (int j = 0; j < numeroPares; j++) {
        int resta = incidencias[j + h] - incidencias[j];
        num potencia = pow(resta, 2);
        suma = suma + potencia.toInt();
      }

      double resultado =
          double.parse((suma / (2 * numeroPares)).toStringAsFixed(2));
      semivariograma.add(resultado);
      /*   this.tabla.add(new Renglon(i, numeroPares, suma, resultado)); */
      numeroPares = numeroPares - 1;
      h = h + 1;
    }
    semivariograma.sort();
    return semivariograma;
  }

  List<double> calcNumeroParesPuntos(List<double> distancias) {
    List<double> hs = [];

    for (int i = 1; i < distancias.length; i++) {
      double sumas = 0;
      int numeroPares = distancias.length - i;
      for (int j = 0; j < numeroPares; j++) {
        sumas = sumas + pow(distancias[i + j] - distancias[j], 2);
      }
      hs.add(sumas / (numeroPares * 2));
    }
    return hs;
  }

  List<double> calcularDistanciasOrdenadas(List<Muestreo> registros) {
    List<double> distancias = [0];
    for (int i = 0; i < registros.length - 1; i++) {
      Muestreo regActual = registros[i];
      Muestreo regSiguiente = registros[i + 1];
      double d = distancia(
        regActual.este,
        regSiguiente.este,
        regActual.norte,
        regSiguiente.norte,
      );
      distancias.add(d);
    }
    distancias.sort();
    return distancias;
  }

  double distancia(double x1, double x2, double y1, double y2) {
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }
}
