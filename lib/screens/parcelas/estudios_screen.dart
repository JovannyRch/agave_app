import 'package:agave_app/backend/bloc/estudios_bloc.dart';
import 'package:agave_app/backend/models/database.dart';
import 'package:agave_app/backend/models/estudio_model.dart';
import 'package:agave_app/backend/models/parcela_model.dart';
import 'package:agave_app/backend/models/plaga_model.dart';
import 'package:agave_app/const/const.dart';
import 'package:agave_app/helpers/utils.dart';
import 'package:agave_app/screens/parcelas/estudios_details.dart';
import 'package:agave_app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
/* import 'package:flutter_svg/flutter_svg.dart'; */
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EstudiosScreen extends StatefulWidget {
  Parcela parcela;

  EstudiosScreen(@required this.parcela);

  @override
  _EstudiosScreenState createState() => _EstudiosScreenState();
}

class _EstudiosScreenState extends State<EstudiosScreen> {
  late BuildContext globalContext;
  EstudiosBloc estudiosBloc = new EstudiosBloc();

  late Parcela p;
  int total = 0;

  @override
  void initState() {
    this.p = widget.parcela;
    estudiosBloc.parcelasId = widget.parcela.id;
    this.estudiosBloc.getDatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.globalContext = context;
    final body = SafeArea(
      child: Container(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // _searcher(),
              MyAppBar("Estudios", "Crear estudio", () async {
                List<Plaga> plagas = getPlagas();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _FullScreenDialog(p, plagas),
                      fullscreenDialog: true,
                    ));
              }),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Parcela: ${widget.parcela.descripcion}",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              loadData(),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      body: body,
    );
  }

  Widget loadData() {
    return StreamBuilder(
      stream: estudiosBloc.estudios,
      builder: (BuildContext context, AsyncSnapshot<List<Estudio>> snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasData) {
          List<Estudio> parcelas = snapshot.data ?? [];
          total = parcelas.length;

          if (parcelas.length == 0) {
            return Container(
                height: 500.0,
                child: Center(
                  child: Text("No se han hecho estudios"),
                ));
          }
          return Column(
              children: parcelas.map((Estudio e) {
            return _tileContainer(e);
          }).toList());
        }
        return Container();
      },
    );
  }

  Widget _tileContainer(Estudio e) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          this.globalContext,
          MaterialPageRoute(
              builder: (context) => EstudiosDetail(e, widget.parcela)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 5.0,
        ),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: kTextTitle.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Image.asset(
                'images/lupa2.png',
                width: 40.0,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    child: Text(
                      "Estudio ${e.id}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                        color: kTextTitle,
                      ),
                    ),
                    tag: e.id ?? 0,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "${e.humedad}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: kTextTitle.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "${e.temperatura}°C",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: kTextTitle.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "${e.createdAt} ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: kTextTitle.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              color: kTextTitle,
            )
          ],
        ),
      ),
    );
  }
}

class _FullScreenDialog extends StatefulWidget {
  List<Plaga> plagas;
  Parcela parcela;
  _FullScreenDialog(this.parcela, this.plagas);

  @override
  __FullScreenDialogState createState() => __FullScreenDialogState();
}

class __FullScreenDialogState extends State<_FullScreenDialog> {
  TextEditingController controllerHumedad = new TextEditingController();
  TextEditingController controllerTemperatura = new TextEditingController();

  String value = '1';
  EstudiosBloc estudiosBloc = new EstudiosBloc();
  final key = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    this.value = "${widget.plagas[0].id}";
    print("$value");
    /* options = widget.plagas
        .map((p) => S2Choice(value: "${p.id}", title: p.nombre))
        .toList();
 */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Crear estudio",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: ThemeData().scaffoldBackgroundColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
              border: Border.all(
                  color: kTextTitle.withOpacity(
            0.2,
          ))),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                DropdownButtonFormField(
                  value: value,
                  decoration: InputDecoration(
                    labelText: 'Plaga',
                    helperText: 'Selecciona la plaga',
                  ),
                  items: widget.plagas
                      .map((p) => DropdownMenuItem(
                            child: Text(p.nombre),
                            value: "${p.id}",
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      this.value = value.toString();
                    });
                  },
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: controllerHumedad,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Ingresa la humedad',
                    helperText: 'En una escala del 0% al 100%',
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: controllerTemperatura,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Ingresa la temperatura',
                    helperText: 'En C°',
                  ),
                ),
                SizedBox(height: 20.0),
                _buttons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor)),
        onPressed: () async {
          if (controllerHumedad.text == "") {
            showSnackBar(context, "Ingrese la humedad");
            return;
          }
          double humedad = double.parse(controllerHumedad.text);
          if (humedad < 0 || humedad > 100) {
            showSnackBar(context, "Ingrese un valor válido para la humedad");
            return;
          }

          if (controllerTemperatura.text == "") {
            showSnackBar(context, "Ingrese la temperatura");
            return;
          }
          double temperatura = double.parse(controllerTemperatura.text);

          var now = DateTime.now();

          int newEstudioId = await estudiosBloc.getNextId();

          Estudio e = Estudio(
              id: newEstudioId,
              humedad: humedad,
              temperatura: temperatura,
              createdAt: "${now.year}/${now.month}/${now.day}",
              parcelaId: widget.parcela.id,
              plagaId: int.parse(value),
              modelo: '',
              pepita: 0.0,
              rango: 0.0,
              meseta: 0.0,
              datosModelo: '');
          estudiosBloc.create(e);
          return Navigator.pop(context, true);
        },
        child: const Text(
          "Crear",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          "Cancelar",
        ),
      )
    ]);
  }
}
