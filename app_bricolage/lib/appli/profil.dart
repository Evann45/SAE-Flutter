import 'package:app_bricolage/connexion.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
import 'reservations.dart';
import 'lesAnnonces.dart';
import 'mesBiens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilPage extends StatefulWidget {
  final String idU;
  final Future<Database> baseDeDonnees;

  const ProfilPage({required this.idU, required this.baseDeDonnees, Key? key})
      : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final supabase = Supabase.instance.client;

  String? userName;
  String? userSurname;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final response =
        await supabase.from('USER').select().eq('idU', widget.idU).single();
    setState(() {
      userName = response['nom'] as String?;
      userSurname = response['prenom'] as String?;
      userEmail = response['address_mail'] as String?;
    });
  }

  void _deconnexion() async {
    await supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ConnexionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _deconnexion,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Nom: $userName'),
            Text('Prénom: $userSurname'),
            Text('Adresse email: $userEmail'),
          ],
        ),
      ),
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
                  builder: (context) => LesAnnoncesPrep(
                      idU: widget.idU, baseDeDonnees: widget.baseDeDonnees)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReservationsPage(
                      idU: widget.idU, baseDeDonnees: widget.baseDeDonnees)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MesBiensPage(
                      idU: widget.idU, baseDeDonnees: widget.baseDeDonnees)),
            );
          }
        },
      ),
    );
  }
}
