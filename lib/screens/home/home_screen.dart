import 'package:agave_app/screens/dasboard/dashboard_screen.dart';
import 'package:agave_app/screens/more/more_screen.dart';
import 'package:agave_app/screens/parcelas/parcelas_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _getNav(),
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: <Widget>[
            DashBoardScreen(),
            ParcelasScreen(),
            MoreScreen(),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _getNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (value) {
        if (value != currentIndex) {
          setState(() {
            currentIndex = value;
          });
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.home),
          label: "Inicio",
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.tree),
          label: "Parcelas",
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.info),
          label: "Acerca de",
        ),
      ],
    );
  }
}
