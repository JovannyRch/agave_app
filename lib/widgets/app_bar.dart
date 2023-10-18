import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyAppBar extends StatelessWidget {
  final String title;
  final Function method;
  final String btnMessage;
  const MyAppBar(this.title, this.btnMessage, this.method, {super.key});

  @override
  Widget build(BuildContext context) {
    return crearAppBar(context, title, method);
  }

  Widget crearAppBar(BuildContext context, String s, Function method) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              s,
              style: const TextStyle(
                fontSize: 30.0,
                letterSpacing: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => {method()},
            child: Row(
              children: <Widget>[
                const FaIcon(
                  FontAwesomeIcons.plus,
                  size: 14.0,
                  color: Colors.black54,
                ),
                const SizedBox(width: 10.0),
                Text(
                  btnMessage,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
