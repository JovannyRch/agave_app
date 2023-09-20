import 'package:agave_app/screens/home/home_screen.dart';
import 'package:agave_app/screens/parcelas/parcelas_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final currentIndex;

  BottomNavBar({this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (value) {
        if (value != currentIndex) {
          switch (value) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ParcelasScreen()),
              );
              break;
            default:
          }
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.house),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.tree),
          label: 'Parcelas',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.bug),
          label: 'Plagas',
        ),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartLine), label: 'Estadísticas'),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.ellipsis), label: 'Más'),
      ],
    );
  }
}
