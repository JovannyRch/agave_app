import 'package:agave_app/backend/bloc/parcelas_bloc.dart';
import 'package:agave_app/backend/models/parcela_model.dart';
import 'package:agave_app/const/const.dart';
import 'package:agave_app/screens/parcelas/parcela_details.dart';
import 'package:agave_app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ParcelasScreen extends StatefulWidget {
  @override
  _ParcelasScreenState createState() => _ParcelasScreenState();
}

class _ParcelasScreenState extends State<ParcelasScreen> {
  ParcelasBloc parcelasBloc = new ParcelasBloc();

  late BuildContext globalContext;

  @override
  Widget build(BuildContext context) {
    parcelasBloc.getDatos();
    this.globalContext = context;
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // _searcher(),
                MyAppBar("Parcelas ", "Nueva parcela", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _FullScreenDialog(),
                        fullscreenDialog: true,
                      ));
                }),
                loadParcelas(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loadParcelas() {
    return StreamBuilder(
      stream: parcelasBloc.parcelas,
      builder: (BuildContext context, AsyncSnapshot<List<Parcela>> snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasData) {
          List<Parcela> parcelas = snapshot.data ?? [];
          if (parcelas.length == 0) {
            return Container(
                height: 500.0,
                child: Center(
                  child: Text("No hay registros de parcelas"),
                ));
          }
          return Column(
              children: parcelas.map((Parcela p) {
            return _parcelaContainer(p);
          }).toList());
        }
        return Container();
      },
    );
  }

  Widget _parcelaContainer(Parcela p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          this.globalContext,
          MaterialPageRoute(builder: (context) => ParcelaDetails(p)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 5.0,
        ),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: kTextTitle.withOpacity(0.15),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Image.asset(
                'images/aguacate.png',
                width: 40.0,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    child: Text(
                      p.descripcion,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                        color: kTextTitle,
                      ),
                    ),
                    tag: p.id,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "${p.superficie} m\u00B2",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                      color: kTextTitle.withOpacity(0.5),
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

class _FullScreenDialog extends StatelessWidget {
  final TextEditingController controllerNombre = new TextEditingController();
  final TextEditingController controllerSuperficie =
      new TextEditingController();

  final ParcelasBloc parcelasBloc = new ParcelasBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Agregar parcela",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: ThemeData().scaffoldBackgroundColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              TextField(
                autofocus: true,
                controller: controllerNombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Escriba el nombre de la parcela',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: controllerSuperficie,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Superficie', helperText: "en m\u00B2"),
              ),
              SizedBox(height: 20.0),
              _buttons(context),
            ],
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
        onPressed: () {
          String nombre = controllerNombre.text;
          double superficie = double.parse(controllerSuperficie.text);
          if (nombre != "" && superficie >= 0) {
            Parcela p = new Parcela(
              id: -1,
              descripcion: nombre,
              superficie: superficie,
              cultivoId: 1,
              createdAt: "9/06/2020",
            );
            parcelasBloc.create(p);
            return Navigator.pop(context, true);
          } else {
            return Navigator.pop(context, false);
          }
        },
        child: Text(
          "Agregar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          "Cancelar",
          style: TextStyle(color: Colors.grey),
        ),
      )
    ]);
  }
}
