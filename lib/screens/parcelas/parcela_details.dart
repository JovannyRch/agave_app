import 'package:agave_app/backend/bloc/parcelas_bloc.dart';
import 'package:agave_app/backend/models/parcela_model.dart';
import 'package:agave_app/const/const.dart';
import 'package:agave_app/screens/parcelas/estudios_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ParcelaDetails extends StatefulWidget {
  final Parcela parcela;

  const ParcelaDetails(this.parcela, {super.key});

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
  final picker = ImagePicker();
  final key = GlobalKey<ScaffoldState>();
  var connectivityResult;
  bool isOnline = false;
  @override
  void initState() {
    super.initState();

    initData();
  }

  void initData() async {
    p = widget.parcela;
    int total = await p.totalEstudios;
    totalMuestreos = "$total";
    ultimoMuestreo = await p.ultimoMuestreo;
    photos = await p.fotos;
    plagaPrincipal = await p.plagaPrincipal;

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
    globalContext = context;
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
            const SizedBox(height: 20.0),
            _details(),
            const SizedBox(height: 20.0),
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
          child: const Center(
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
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
                  child: const Text(
                    "Agregar foto",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black),
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
              SimpleDialogOption(
                  child: const Row(
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
                child: const Row(
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
            await _dialogConfirm("¿Estás seguro de eliminar el registro?");

        if (respuesta) {
          parcelasBloc.deleteData(p.id);
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
        });
  }

  Widget _gridPhotos() {
    return const Center(child: Text("No se han cargado fotos"));
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Detalles",
            style: TextStyle(
              fontSize: 23.0,
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _containerDetail("Superficie", "${p.superficie} m\u00B2"),
              _containerDetail("Último estudio", ultimoMuestreo),
            ],
          ),
          const SizedBox(height: 10.0),
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
      padding: const EdgeInsets.all(10.0),
      width: size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12.0,
              )),
          const SizedBox(height: 7.0),
          Text(text,
              style: const TextStyle(
                fontSize: 15.0,
              )),
        ],
      ),
    );
  }

  Widget _btnMuestreo() {
    return Positioned(
      right: size.width * 0.20,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            globalContext,
            CupertinoPageRoute(builder: (context) => EstudiosScreen(p)),
          );
        },
        child: Container(
          height: 45,
          width: size.width * 0.35,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                30.0,
              )),
          child: const Center(
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
                  child: Hero(
                    tag: "title",
                    child: Text(
                      p.descripcion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 37.0,
                        color: kTextTitle,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5.0),
                child: Image.asset(
                  'images/aguacate.png',
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
}
