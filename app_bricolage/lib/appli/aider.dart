import 'package:flutter/material.dart';
import 'home.dart';
import 'demanderaide.dart';
import 'profil.dart';

class AiderPage extends StatefulWidget {
  final String idU;

  const AiderPage({required this.idU, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AiderPageState createState() => _AiderPageState();
}

class _AiderPageState extends State<AiderPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 63, 88, 199),
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Demande',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Aide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePagePrep(idU: widget.idU)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DemanderAidePage(idU: widget.idU)),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilPage(idU: widget.idU)),
            );
          }
        },
      ),
    );
  }
}
