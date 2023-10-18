import 'package:agave_app/backend/ajuste_model.dart';
import 'package:agave_app/backend/bloc/estudios_bloc.dart';
import 'package:agave_app/backend/models/chart_data.dart';
import 'package:agave_app/backend/models/estudio_model.dart';
import 'package:agave_app/backend/models/mock_data.dart';
import 'package:agave_app/backend/models/muestreo_model.dart';
import 'package:agave_app/backend/models/parcela_model.dart';
import 'package:agave_app/const/const.dart';
import 'package:agave_app/helpers/calculos.dart';
import 'package:agave_app/helpers/convertidor.dart';
import 'package:agave_app/helpers/krigeado.dart';
import 'package:agave_app/helpers/utils.dart';
import 'package:agave_app/screens/parcelas/ajuste_screen.dart';
import 'package:agave_app/screens/parcelas/heat_map.dart';
import 'package:agave_app/screens/parcelas/semivariograma_screen.dart';

import 'package:flutter/material.dart';
/* import 'package:flutter_svg/flutter_svg.dart'; */
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';


/* 
import 'package:geolocator/geolocator.dart'; */

class EstudiosDetail extends StatefulWidget {
  Estudio estudio;
  Parcela parcela;
  EstudiosDetail(@required this.estudio, @required this.parcela, {super.key});

  @override
  _EstudiosDetailState createState() => _EstudiosDetailState();
}

class _EstudiosDetailState extends State<EstudiosDetail> {
  late Estudio estudio;
  late Parcela parcela;
  late BuildContext globalContext;
  int currentTabe = 0;
  final key = GlobalKey<ScaffoldState>();
  EstudiosBloc estudiosBloc = EstudiosBloc();
  @override
  void initState() {
    super.initState();
    estudio = widget.estudio;
    parcela = widget.parcela;
    loadData();
  }

  void loadData() async {
    await estudio.hacerCalculos();
    setState(() {});
  }

  late Size size;
  @override
  Widget build(BuildContext context) {
    globalContext = this.context;
    size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () async {
          //Obtener ubicacion
          final res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _FullScreenDialog(estudio),
                fullscreenDialog: true,
              ));
          if (res != null && res) {
            loadData();
          }
        },
        child: const FaIcon(
          FontAwesomeIcons.searchLocation,
        ),
      ),
      key: key,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  _cardEstudio(context),
                  rowButtons(),
                ],
              ),
              const SizedBox(height: 20.0),
              _cuerpo(),
            ],
          ),
        ),
      ),
    );
  }

  void saveData() {}

  Widget _cuerpo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _info(),
          const SizedBox(height: 17.0),
          Text(
            "Tabla de registros",
            style: TextStyle(color: kTextTitle.withOpacity(0.7)),
          ),
          const Divider(),
          _tabla(),
        ],
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        btnShare(),
        Text(
          "Detalles",
          style: TextStyle(color: kTextTitle.withOpacity(0.7)),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _card("${estudio.totalMuestreos}", "Muestreos"),
            _card("${estudio.totalIncidencias}", "Incidencias"),
          ],
        ),
        const SizedBox(height: 17.0),
        Text(
          "Datos estadísticos",
          style: TextStyle(color: kTextTitle.withOpacity(0.7)),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _card("${estudio.media}", "Media"),
            _card("${formatNumber(estudio.varianza)}", "Varianza"),
            _card("${formatNumber(estudio.desviacionEstandar)}",
                "Desviación estándar"),
          ],
        ),
        const SizedBox(height: 17.0),
        Text(
          "Modelado",
          style: TextStyle(color: kTextTitle.withOpacity(0.7)),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: estudio.modelo == null
              ? [
                  const Text(
                    "Estudio no ajustado",
                    style: TextStyle(color: Colors.grey),
                  ),
                ]
              : <Widget>[
                  _card("${formatNumber(estudio.meseta)}", "Meseta"),
                  _card("${formatNumber(estudio.rango)}", "Rango"),
                ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: estudio.modelo == null
              ? []
              : <Widget>[
                  _card("${formatNumber(estudio.pepita)}", "Efecto pepita"),
                  _card(estudio.modelo, "Modelo"),
                ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: estudio.modelo == null
              ? []
              : <Widget>[
                  _card(
                      labelNivelDependendencia(formatNumber(estudio.pepita / estudio.meseta)),
                      "Nivel de dependencia espacial"),
                ],
        ),
      ],
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String nombre = "estudio_${estudio.id}";
    filePath = '$path/$nombre.csv';
    return File('$path/$nombre.csv').create();
  }

  String formatName(String s) {
    return s.replaceAll(' ', "_").trim();
  }

  String filePath = "";

  getCsv() async {
    List<List<dynamic>> rows = [];

    rows.add([
      "Norte",
      "Este",
      "Incidencias",
    ]);

    if (estudio.muestreos.isNotEmpty) {
      for (int i = 0; i < estudio.muestreos.length; i++) {
        List<dynamic> row = [];
        row.add(estudio.muestreos[i].norte);
        row.add(estudio.muestreos[i].este);
        row.add(estudio.muestreos[i].incidencia);
        rows.add(row);
      }

      File f = await _localFile;
      print("F.path");
      print(f.path);
      filePath = f.path;
      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
    }
  }

  sendMailAndAttachment() async {
    print("filePath");
    print(filePath);
    final Email email = Email(
      body:
          "<p>Estudio de una parcela de aguacate realizado el <b>${estudio.createdAt}</b> </p>"
          "<ul>"
          "<li>Plaga: ${estudio.nombrePlaga}</li>"
          "<li>Humedad: ${estudio.humedad}%</li>"
          "<li>Total muestreos realizados: ${estudio.totalMuestreos}</li>"
          "<li>Suma de incidencias: ${estudio.totalIncidencias}</li>"
          "<li>Varianza: ${estudio.varianza}</li>"
          "<li>Desviación estándar: ${estudio.desviacionEstandar}</li>"
          "<li>Media: ${estudio.media}</li>"
          "</ul>",
      subject: 'Estudio-${estudio.id}',
      recipients: [],
      isHTML: true, /* 
      attachmentPaths: [filePath], */
    );

    await FlutterEmailSender.send(email);
  }

  Widget btnShare() {
    var gestureDetector = GestureDetector(
      onTap: () {
        getCsv();
        sendMailAndAttachment();
      },
      child: Container(
        width: 120.0,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            border: Border.all(color: kTextTitle.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(20.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Compartir",
              style: TextStyle(color: kTextTitle.withOpacity(0.7)),
            ),
            const SizedBox(width: 10.0),
            FaIcon(FontAwesomeIcons.solidShareSquare,
                size: 13.0, color: kTextTitle.withOpacity(0.7)),
          ],
        ),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[gestureDetector],
    );
  }

  Widget _tabla() {
    if (estudio.muestreos.isEmpty) {
      return const SizedBox(
          height: 100.0,
          child: Center(
              child: Text(
            "No hay registros",
            style: TextStyle(color: Colors.grey),
          )));
    }

    List<DataRow> rows = [];
    int i = 1;
    List<int> incidencias = [];
    for (var p in estudio.muestreos) {
      DataCell c0 = DataCell(Text(i.toString()));
      DataCell c1 = DataCell(Text(p.norte.toString()));
      DataCell c2 = DataCell(Text(p.este.toString()));
      DataCell c3 = DataCell(Text(p.incidencia.toString()));

      rows.add(DataRow(cells: [c0, c1, c2, c3]));
      incidencias.add(int.parse(p.incidencia.toString()));
      i++;
    }
    return SizedBox(
      height: 200.0,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(
                label:
                    Text('N', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Norte',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Este',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Incidencia',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: rows,
        ),
      ),
    );
  }

  String labelNivelDependendencia(double value) {
    if (value >= 0.0 && value < 26.0) {
      return "Alto";
    }

    if (value >= 26.0 && value < 76.0) {
      return "Medio";
    }

    return "Bajo";
  }

  Widget _card(String main, String secondary) {
    return Container(
      width: 90,
      height: 80,
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
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
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

  Widget rowButtons() {
    return Positioned(
      bottom: 10.0,
      child: SizedBox(
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ButtonTop(
              size: size,
              text: "Mapa de densidad",
              icon: FontAwesomeIcons.solidSun,
              isCurrent: true,
              function: () {
                if (estudio.muestreos.isNotEmpty) {
                  Modelo m = getModelo(estudio.modelo);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeatMap(estudio, m),
                        fullscreenDialog: true,
                      ));
                } else {
                  showSnackBar(context, "Aun no hay suficientes datos");
                }
              },
            ),
            ButtonTop(
                size: size,
                text: "Semivariograma",
                icon: FontAwesomeIcons.chartLine,
                isCurrent: true,
                function: handleSemivariogramaClick)
          ],
        ),
      ),
    );
  }

  void handleSemivariogramaClick() {
    if (estudio.muestreos.length <= 1) {
      showSnackBar(context, "Aun no hay suficientes datos");
      return;
    }

    if (isAjustado()) {
      List<ChartData> data = Calculos.calcularSemivariograma(estudio);
      Ajuste ajuste = Ajuste(
        meseta: estudio.meseta,
        pepita: estudio.pepita,
        rango: estudio.rango,
        datos: data,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AjusteScreen(
            modelo: estudio.modelo,
            ajuste: ajuste,
            muestreos: widget.estudio.muestreos,
            distanciasSemivariograma: data.map((e) => e.distancia).toList(),
            incidenciaSemivariograma:
                data.map((e) => e.semivariograma).toList(),
            chartData: data,
            valoresModelo: ajuste.getValues(estudio.modelo),
          ),
        ),
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SemivariogramScreen(estudio),
            fullscreenDialog: true,
          ));
    }
  }

  bool isAjustado() {
    if (estudio.modelo == null) {
      return false;
    }
    return estudio.modelo.isNotEmpty;
  }

  Widget _cardEstudio(BuildContext context) {
    var mainContainer = Container(
      width: double.infinity,
      height: size.height * 0.30,
      margin: const EdgeInsets.symmetric(horizontal: 7.0),
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 14.0),
      decoration: BoxDecoration(
          color: kTextTitle.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3.0),
            topRight: Radius.circular(3.0),
            bottomLeft: Radius.circular(17.0),
            bottomRight: Radius.circular(17.0),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _appBar(context),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: "title",
                        child: Text(
                          "Estudio ${estudio.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 37.0,
                            color: kTextTitle,
                          ),
                        ),
                      ),
                      Text(
                        "Plaga: ${estudio.nombrePlaga}",
                        style: TextStyle(
                          color: kTextTitle.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        "Temperatura: ${estudio.temperatura}°C",
                        style: TextStyle(
                          color: kTextTitle.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        "Humedad: ${estudio.humedad}%",
                        style: TextStyle(
                          color: kTextTitle.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5.0),
                child: Image.asset(
                  'images/lupa2.png',
                  width: 80.0,
                ),
              )
            ],
          ),
        ],
      ),
    );
    return Stack(
      children: <Widget>[
        Container(
          height: size.height * 0.25,
        ),
        mainContainer
      ],
    );
  }

  Widget _appBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      margin: const EdgeInsets.only(bottom: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: InkWell(
              child: Container(
                height: 40.0,
                width: 40.0,
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: kTextTitle,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          InkWell(
            child: Container(
              height: 40.0,
              width: 40.0,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.ellipsisV,
                size: 17.0,
                color: kTextTitle,
              ),
            ),
            onTap: () {
              _options();
            },
          ),
        ],
      ),
    );
  }

  Future _options() async {
    final option = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Opciones'),
            children: <Widget>[
              SimpleDialogOption(
                  child: const Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Eliminar'),
                      ),
                      FaIcon(
                        FontAwesomeIcons.trash,
                        size: 15.0,
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context, 1);
                  }),
              /*  SimpleDialogOption(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Importar'),
                      ),
                      FaIcon(
                        FontAwesomeIcons.solidEdit,
                        size: 15.0,
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context, 2);
                  }), */
              /*  
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Subir a la base de datos global'),
                    ),
                    FaIcon(
                      FontAwesomeIcons.database,
                      size: 15.0,
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context, 3);
                },
              ), */
            ],
          );
        });
    switch (option) {
      case 1:
        //Eliminar
        final bool? respuesta =
            await _dialogConfirm("¿Estás seguro de eliminar el registro?");

        if (respuesta != null && respuesta && estudio.id != null) {
          estudiosBloc.deleteData(estudio.id ?? 0);
          Navigator.of(context).pop();
        }
        break;
      //Importar
      case 2:
        break;
      case 3:
        break;
    }
  }

  Future<bool?> _dialogConfirm(String title,
      {String textMainButton = "Eliminar"}) {
    //Create and dialog confirm
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: Text(
                textMainButton,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}

class ButtonTop extends StatelessWidget {
  const ButtonTop({super.key, 
    required this.size,
    required this.text,
    required this.icon,
    required this.function,
    this.isCurrent = false,
  });
  final String text;
  final Size size;
  final IconData icon;
  final bool isCurrent;
  final void Function()? function;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        height: 45,
        width: size.width * 0.43,
        decoration: BoxDecoration(
            color: isCurrent ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(
              30.0,
            ),
            border: Border.all(
                color: isCurrent ? Colors.white : Colors.black)),
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: isCurrent ? Colors.white : Colors.black,
                letterSpacing: 1.3,
              ),
            ),
            FaIcon(
              icon,
              size: 15.0,
              color: isCurrent ? Colors.white : Colors.black,
            )
          ],
        )),
      ),
    );
  }
}

class _FullScreenDialog extends StatefulWidget {
  Estudio estudio;
  _FullScreenDialog(@required this.estudio);

  @override
  __FullScreenDialogState createState() => __FullScreenDialogState();
}

class __FullScreenDialogState extends State<_FullScreenDialog> {
  bool obteniendoUbicacion = true;
  Convertidor convertidor = Convertidor();
  double latitud = 0.0;
  double longitud = 0.0;
  TextEditingController utmEste = TextEditingController();
  TextEditingController utmNorte = TextEditingController();
  TextEditingController utmZona = TextEditingController();
  TextEditingController incidenciaCrtl = TextEditingController();
  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

  void obtenerUbicacion() async {
    setState(() {
      obteniendoUbicacion = true;
    });

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    latitud = position.latitude;
    longitud = position.longitude;
    /*   print("Latitud: $latitud");
    print("longitud: $longitud"); */
    Map utm = convertidor.fromLatLon(latitud, longitud, null);

    utmEste.text =
        double.parse(utm["este"].toString()).roundToDouble().toInt().toString();
    utmNorte.text = double.parse(utm["norte"].toString())
        .roundToDouble()
        .toInt()
        .toString();
    utmZona.text = utm["zona"].toString() + utm["letra"].toString();

    setState(() {
      obteniendoUbicacion = false;
    });
  }

  final key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var formContainer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        decoration: BoxDecoration(
            border: Border.all(
                color: kTextTitle.withOpacity(
          0.2,
        ))),
        child: Column(
          children: <Widget>[
            TextField(
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'UTM Zona',
              ),
              controller: utmZona,
              readOnly: true,
            ),
            TextField(
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'UTM Este',
              ),
              controller: utmEste,
              readOnly: true,
            ),
            TextField(
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'UTM Norte',
              ),
              controller: utmNorte,
              readOnly: true,
            ),
            TextField(
              autofocus: true,
              controller: incidenciaCrtl,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ingresa la incidencia',
              ),
            ),
            const SizedBox(height: 20.0),
            _buttons(context),
          ],
        ),
      ),
    );
    return Scaffold(
      key: key,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Nuevo muestreo",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: ThemeData().scaffoldBackgroundColor,
      ),
      body: obteniendoUbicacion ? loader() : formContainer,
    );
  }

  Widget loader() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset("images/location4.gif"),
          const Text("Obteniendo Ubicación",
              style: TextStyle(
                fontSize: 30.0,
              )),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
        ),
        onPressed: () {
          if (isTesting) {
            for (Muestreo m in Mock.createDate(widget.estudio.id ?? 0)) {
              Muestreo.create(m);
            }
          } else {
            if (incidenciaCrtl.text == "") {
              showSnackBar(context, "Por favor ingresa en valor de incidencia");
              return;
            }
            Muestreo m = Muestreo(
              latitud: latitud,
              longitud: longitud,
              norte: double.parse(utmNorte.text),
              este: double.parse(utmEste.text),
              zona: utmZona.text,
              incidencia: int.parse(incidenciaCrtl.text),
              estudioId: widget.estudio.id ?? 0,
            );
            Muestreo.create(m);
          }

          return Navigator.pop(context, true);
        },
        child: const Text(
          "Hacer Registro",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          "Cancelar",
          style: TextStyle(color: Colors.grey),
        ),
      )
    ]);
  }
}
