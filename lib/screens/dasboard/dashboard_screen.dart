import 'package:agave_app/backend/models/reportes_model.dart';
import 'package:agave_app/const/const.dart';
import 'package:agave_app/widgets/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashBoardScreen extends StatefulWidget {
  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int currentIndex = 0;
  ReportesModel reportes = new ReportesModel();
  int totalParcelas = 0;
  int totalMuestreos = 0;
  int totalIncidencias = 0;
  int totalEstudios = 0;
  List<Map<String, dynamic>> reportePlagas = [];
  List<Color> colores = [
    Color(0xff0293ee),
    Color(0xfff8b250),
    Color(0xff845bef),
    Color(0xff13d38e),
    Color(0xff805a10),
  ];
  late Size size;
  bool isLoading = true;
  int touchedIndex = 0;
  @override
  void initState() {
    this.isLoading = true;
    this.loadData();
    super.initState();
  }

  void loadData() async {
    this.totalParcelas = await reportes.totalParcelas();
    this.totalMuestreos = await reportes.totalMuestreos();
    this.totalEstudios = await reportes.totalEstudios();
    this.totalIncidencias = await reportes.totalIncidencias();
    this.reportePlagas = await reportes.reportePlagas();
    print("Total parcelas: ${this.totalParcelas}");
    setState(() {
      this.isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 10.0,
          left: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //_title(),
            SizedBox(height: 15.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Principales plagas",
                style: TextStyle(
                  fontSize: 18.0,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              decoration: BoxDecoration(),
            ),
            Divider(height: 25.0),
            _indicators(),
            SizedBox(height: 25.0),
            _graph(),
            SizedBox(height: 15.0),
            _rowReport(),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _indicators() {
    List<Widget> indicators = [];
    int i = 0;
    for (Map<String, dynamic> data in this.reportePlagas) {
      indicators.add(
        Indicator(
          color: colores[i],
          text: data['nombre'],
          isSquare: false,
          size: touchedIndex == i ? 18 : 16,
          textColor: touchedIndex == 0 ? Colors.black : Colors.grey,
        ),
      );
      i++;
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: indicators,
    );
  }

  Widget _rowReport() {
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _containerInfo(FontAwesomeIcons.bars, totalParcelas,
            totalParcelas == 1 ? "Parcela" : "Parcelas"),
        _containerInfo(FontAwesomeIcons.book, totalEstudios,
            totalEstudios == 1 ? "Estudio" : "Estudios"),
      ],
    );
    var row2 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _containerInfo(FontAwesomeIcons.clipboardList, totalMuestreos,
            totalEstudios == 1 ? "Muestreo" : "Muestreos"),
        _containerInfo(
            FontAwesomeIcons.bug,
            totalIncidencias == null ? 0 : totalIncidencias,
            totalIncidencias == 1 ? "Incidencia" : "Incidencias"),
      ],
    );
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Reporte general",
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
            decoration: BoxDecoration(),
          ),
          Divider(height: 1),
          row,
          row2,
        ],
      ),
    );
  }

  Widget _containerInfo(IconData icon, int amount, String text) {
    return Container(
      height: 75.0,
      width: size.width * 0.35,
      padding: EdgeInsets.all(5.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FaIcon(
              icon,
              size: 20.0,
              color: kTextTitle.withOpacity(0.54),
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 7.0),
                Text(
                  "$amount",
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7)
                      // color: kTextTitle,
                      ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          border: Border.all(color: Colors.black, width: 0.2),
          borderRadius: BorderRadius.circular(7.0)),
    );
  }

  Widget _graph() {
    if (reportePlagas.length == 0) {
      return Container(
        height: size.height * 0.4,
        child: Center(
          child: Text(
            "No hay suficientes datos disponibles",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(right: 10.0),
      width: double.infinity,
      height: size.height * 0.4,
      child: PieChart(
        PieChartData(
            /*  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
              setState(() {
                if (pieTouchResponse.touchInput is FlLongPressEnd ||
                    pieTouchResponse.touchInput is FlPanEnd) {
                  touchedIndex = -1;
                } else {
                  touchedIndex = pieTouchResponse.touchedSectionIndex;
                }
              });
            }), */
            startDegreeOffset: 180,
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 1.5,
            centerSpaceRadius: 0,
            sections: showingSections()),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> items = [];
    for (int i = 0; i < this.reportePlagas.length; ++i) {
      Map<String, dynamic> data = reportePlagas[i];
      items.add(PieChartSectionData(
        color: colores[i].withOpacity(0.7),
        value: double.parse(data['total'].toString()),
        title: data['total'].toString(),
        radius: 80,
        titleStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xff044d7c)),
        titlePositionPercentageOffset: 0.55,
      ));
    }
    return items;
  }

  Widget _buttonTime(bool isSelected, String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        height: 40.0,
        width: 80.0,
        child: Center(
            child: Text(
          text,
          style: TextStyle(color: kTextTitle),
        )),
        decoration: BoxDecoration(
            border: Border.all(
              color: (currentIndex == index)
                  ? kTextTitle.withOpacity(0.9)
                  : kTextTitle.withOpacity(0.1),
            ),
            borderRadius: BorderRadius.circular(
              5.0,
            )),
      ),
    );
  }

  Column _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Informe",
          style: TextStyle(
            fontFamily: 'Source Sans Pro',
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            fontSize: 30.0,
            // color: kTextTitle,
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 50.0,
          ),
          child: Text(
            "Resumido",
            style: TextStyle(
              fontFamily: 'Source Sans Pro',
              fontWeight: FontWeight.bold,
              letterSpacing: 3.0,
              fontSize: 30.0,
              //  color: kTextTitle,
            ),
          ),
        )
      ],
    );
  }
}
