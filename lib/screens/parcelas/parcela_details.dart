import 'package:agave_app/backend/bloc/parcelas_bloc.dart';
import 'package:agave_app/backend/models/parcela_model.dart';
import 'package:agave_app/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:agave_app/helpers/utils.dart' as utils;

class ParcelaDetails extends StatefulWidget {
  final Parcela parcela;

  ParcelaDetails(this.parcela);

  @override
  _ParcelaDetailsState createState() => _ParcelaDetailsState();
}

class _ParcelaDetailsState extends State<ParcelaDetails> {
  late Size size;
  late Parcela p;
  String totalMuestreos = "--";
  String ultimoMuestreo = "--";
  String plagaPrincipal = "--";
  ParcelasBloc parcelasBloc = ParcelasBloc();
  final picker = new ImagePicker();
  final key = new GlobalKey<ScaffoldState>();
  var connectivityResult;
  bool isOnline = false;
  @override
  void initState() {
    super.initState();

    this.initData();
  }

  void initData() async {
    this.p = widget.parcela;
    int total = await this.p.totalEstudios;
    this.totalMuestreos = "$total";
    this.ultimoMuestreo = await this.p.ultimoMuestreo;
    this.photos = await this.p.fotos;
    this.plagaPrincipal = await this.p.plagaPrincipal;

    connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      isOnline = true;
    } else {}
    setState(() {});
  }

  List<String> photos = [];

  late BuildContext globalContext;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    this.globalContext = context;
    return Scaffold(
      key: key,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                _cardParcela(context),
                _btnMuestreo(),
              ],
            ),
            SizedBox(height: 20.0),
            _details(),
            SizedBox(height: 20.0),
            _photos(),
          ],
        ),
      ),
    );
  }

  Widget _photos() {
    if (!isOnline) {
      return Expanded(
        child: Container(
          child: Center(
            child: Text(
              "Conectate a una red para ver las fotos",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Fotos",
                    style: TextStyle(
                      fontSize: 23.0,
                      letterSpacing: 1.7,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _selectSource(),
                  child: Text(
                    "Agregar foto",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.black),
            Expanded(child: _gridPhotos()),
          ],
        ),
      ),
    );
  }

  Future _selectSource() async {
    /* final option = await showDialog(
        context: context,
        child: SimpleDialog(
          title: Text('Cargar foto'),
          children: <Widget>[
            SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Tomar foto'),
                    ),
                    FaIcon(
                      FontAwesomeIcons.camera,
                      size: 15.0,
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context, 1);
                }),
            SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Elegir una foto de la galería'),
                  ),
                  FaIcon(
                    FontAwesomeIcons.images,
                    size: 15.0,
                  )
                ],
              ),
              onPressed: () {
                Navigator.pop(context, 2);
              },
            ),
          ],
        ));

    if (option == null) return;
    String url;
    PickedFile pickedFile;

    switch (option) {
      case 1:
        pickedFile = await picker.getImage(source: ImageSource.camera);
        break;
      case 2:
        pickedFile = await picker.getImage(source: ImageSource.gallery);
        break;
    }
    url = await fotosHelper.subirImagen(pickedFile);
    this.p.agregarFoto(url);
    this.photos.add(url);
    setState(() {}); */
  }

  Future _options() async {
    final option = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Opciones'),
            children: <Widget>[
              SimpleDialogOption(
                  child: Row(
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
              SimpleDialogOption(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Editar'),
                      ),
                      FaIcon(
                        FontAwesomeIcons.solidEdit,
                        size: 15.0,
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context, 2);
                  }),
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
              ),
            ],
          );
        });
    switch (option) {
      case 1:
        //Eliminar
        final bool respuesta =
            await this._dialogConfirm("¿Estás seguro de eliminar el registro?");

        if (respuesta != null && respuesta) {
          parcelasBloc.deleteData(this.p.id);
          //utils.showMessage("Eliminación correcta", key);
          Navigator.of(context).pop();
        }
        break;
      //Editar
      case 2:
        break;
      case 3:
        break;
    }
  }

  Future<dynamic> _dialogConfirm(String title,
      {String textMainButton = "Eliminar"}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                child: Text(
                  textMainButton,
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }

  Widget _gridPhotos() {
    return Center(child: Text("No se han cargado fotos"));
    /* if (this.photos.length == 0) {
      return Center(child: Text("No se han cargado fotos"));
    }
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: this.photos.length,
      itemBuilder: (BuildContext context, int index) {
        var fadeInImage = FadeInImage.assetNetwork(
          image: this.photos[index],
          placeholder: "images/arbol.gif",
          fit: BoxFit.cover,
        );
        return GestureDetector(
          onLongPress: () async {
            final bool respuesta = await this
                ._dialogConfirm("¿Estás seguro de eliminar la foto ?");
            if (respuesta != null && respuesta) {
              //Eliminar
              setState(() {
                this.p.eliminarFoto(this.photos[index]);
                this.photos.removeAt(index);
              });
              utils.showMessage("Foto eliminada correctamente", key);
            }
          },
          child: FullScreenWidget(
            child: Hero(child: fadeInImage, tag: "$index"),
          ),
        );
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.count(2, 2),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    ); */
  }

  Widget _details() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Detalles",
            style: TextStyle(
              fontSize: 23.0,
              letterSpacing: 1.7,
            ),
          ),
          SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _containerDetail("Superficie", "${this.p.superficie} m\u00B2"),
              _containerDetail("Último estudio", "${this.ultimoMuestreo}"),
            ],
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _containerDetail("Plaga principal", plagaPrincipal),
              _containerDetail("Total estudios", totalMuestreos),
            ],
          )
        ],
      ),
    );
  }

  Widget _containerDetail(String title, String text) {
    return Container(
      padding: EdgeInsets.all(10.0),
      width: size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12.0,
              )),
          SizedBox(height: 7.0),
          Text(text,
              style: TextStyle(
                fontSize: 15.0,
              )),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget _btnMuestreo() {
    return Positioned(
      right: size.width * 0.20,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          /* Navigator.push(
            this.globalContext,
            CupertinoPageRoute(builder: (context) => EstudiosScreen(p)),
          ); */
        },
        child: Container(
          height: 45,
          width: size.width * 0.35,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                30.0,
              )),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "Estudios",
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 15.0,
                color: Colors.white,
              )
            ],
          )),
        ),
      ),
    );
  }

  Widget _cardParcela(BuildContext context) {
    var mainContainer = Container(
      width: double.infinity,
      height: size.height * 0.23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _appBar(context),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Hero(
                    child: Text(
                      this.p.descripcion,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 37.0,
                        color: kTextTitle,
                      ),
                    ),
                    tag: "title",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 5.0),
                child: Image.asset(
                  'images/aguacate.png',
                  width: 80.0,
                ),
              )
            ],
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 7.0),
      padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 14.0),
      decoration: BoxDecoration(
          color: kTextTitle.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(3.0),
            topRight: Radius.circular(3.0),
            bottomLeft: Radius.circular(17.0),
            bottomRight: Radius.circular(17.0),
          )),
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
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      margin: EdgeInsets.only(bottom: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: InkWell(
              child: Container(
                height: 40.0,
                width: 40.0,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
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
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: FaIcon(
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
}
