import 'package:agave_app/const/const.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:store_redirect/store_redirect.dart';

class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _appbar(),
              SizedBox(height: 10.0),
              Text(
                "App Ahuacatl",
                style: TextStyle(
                  fontSize: 23.0,
                  letterSpacing: 1.3,
                ),
              ),
              _icon(),
              SizedBox(height: 10.0),
              Text("Versión: 1.0.0"),
              Divider(),
              _review(),
              SizedBox(height: 10.0),
              _info(),
              SizedBox(height: 10.0),
              Divider(),
              _developers(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35.0),
      child: Text(
        "App Ahuacatl es una aplicación que sirve como herramienta en el muestreo y análisis de problemas fitosanitarios.",
        style: TextStyle(height: 2.0, fontSize: 15.0),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _developers() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Colaboradores",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 10.0),
          _infoDeveloper("Nancy Martínez Martínez", "annym9071@gmail.com",
              "Facultad de Ciencias Agrícolas, UAEMex"),
          _infoDeveloper("Dr. José Francisco Ramírez Davila",
              "jframirezd@uaemex.mx", "Facultad de Ciencias Agrícolas, UAEMex"),
          _infoDeveloper("M. En I. Sara Verá Noguez", "sveran@uaemex.mx",
              "Facultad de Ingeniería, UAEMex"),
          _infoDeveloper("Jovanny Ramírez Chimal", "jovannyrch@gmail.com",
              "Facultad de Ingeniería, UAEMex"),
          _infoDeveloper("Dr. Jaime Mejia Carranza", "jmejiac@uaemex.mx",
              "Centro Universitario Tenancingo, UAEMex"),
        ],
      ),
    );
  }

  Widget _infoDeveloper(String nombre, String correo, String carrera) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: TextStyle(fontSize: 19.0),
              textAlign: TextAlign.start,
            ),
            Text(
              carrera,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.start,
            ),
            Text(
              correo,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black45,
              ),
              textAlign: TextAlign.start,
            ),
            Divider(),
          ]),
    );
  }

  Widget _icon() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 10.0),
        height: 100.0,
        width: 100.0,
        child: Image.asset("images/icon.png"),
      ),
    );
  }

  Widget _review() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FaIcon(
            FontAwesomeIcons.star,
            size: 19.0,
            color: Colors.green,
          ),
          FaIcon(
            FontAwesomeIcons.star,
            size: 19.0,
            color: Colors.green,
          ),
          FaIcon(
            FontAwesomeIcons.star,
            size: 19.0,
            color: Colors.green,
          ),
          FaIcon(
            FontAwesomeIcons.star,
            size: 19.0,
            color: Colors.green,
          ),
          FaIcon(
            FontAwesomeIcons.star,
            size: 19.0,
            color: Colors.green,
          )
        ],
      ),
      SizedBox(height: 10.0),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor)),
        onPressed: () {
          StoreRedirect.redirect(
              androidAppId: "com.jovannyrch.agroapp", iOSAppId: "585027354");
        },
        child: Text("Calificar la aplicación"),
      ),
    ]);
  }

  Widget _appbar() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "Acerca de",
              style: TextStyle(
                fontSize: 30.0,
                letterSpacing: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
