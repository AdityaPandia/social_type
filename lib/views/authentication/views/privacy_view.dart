import 'package:flutter/material.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
            child: Text("Politicas de Privacidad")), //TO CHANGE - Appbar title
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Politicas de Privacidad", //TO CHANGE - Main Title
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            //TO CHANGE - First title's content
            "CONTENT 0 - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eu mi non lectus interdum euismod. Nunc venenatis leo posuere neque iaculis, at euismod eros commodo. Suspendisse potenti. Cras tempus turpis id consequat cursus. ",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Title 1", //TO CHANGE - Title 1
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            //TO CHANGE - Title 1 CONTENT
            "CONTENT 1 - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eu mi non lectus interdum euismod. Nunc venenatis leo posuere neque iaculis, at euismod eros commodo. Suspendisse potenti. Cras tempus turpis id consequat cursus. ",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Title 3", //TO CHANGE - Title 3
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          Text(
              // TO CHANGE - Title 3 CONTENT
              "CONTENT 3 - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eu mi non lectus interdum euismod. Nunc venenatis leo posuere neque iaculis, at euismod eros commodo. Suspendisse potenti. Cras tempus turpis id consequat cursus. ",
              style: TextStyle(
                fontSize: 14,
              )),
          SizedBox(
            height: 10,
          ),
          Text("Title 2", // TO CHANGE - Title 2
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          Text(
              // TO CHANGE - Title 2 CONTENT
              "CONTENT 2 - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eu mi non lectus interdum euismod. Nunc venenatis leo posuere neque iaculis, at euismod eros commodo. Suspendisse potenti. Cras tempus turpis id consequat cursus. ",
              style: TextStyle(
                fontSize: 14,
              )),
          SizedBox(
            height: 10,
          ),
        ]),
      ),
    );
  }
}
