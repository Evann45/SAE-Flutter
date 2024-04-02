import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'demanderaide.dart';
import 'aider.dart';
import 'profil.dart';

class Annonce {
  final int? idA;
  final String titre;

  Annonce({
    required this.idA,
    required this.titre,
  });

  Map<String, Object?> toMap() {
    return {
      'idA': idA,
      'titre': titre,
    };
  }
}

class Bien {
  final int? idB;
  final String nom;

  Bien({
    required this.idB,
    required this.nom,
  });

  Map<String, Object?> toMap() {
    return {
      'idB': idB,
      'nom': nom,
    };
  }
}

class HomePagePrep extends StatefulWidget {
  final String idU;

  const HomePagePrep({required this.idU, Key? key}) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<HomePagePrep> {
  late Future<Database> _baseDeDonnees;

  @override
  void initState() {
    super.initState();
    _initialiserBaseDeDonnees();
  }

  Future<void> _initialiserBaseDeDonnees() async {
    WidgetsFlutterBinding.ensureInitialized();
    _baseDeDonnees = _ouvrirBaseDeDonnees();
  }

  Future<Database> _ouvrirBaseDeDonnees() async {
    return openDatabase(
      join(await getDatabasesPath(), 'SAE_Flutter.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE bien(idB INTEGER PRIMARY KEY, nom TEXT); CREATE TABLE annonce(idA INTEGER PRIMARY KEY, titre TEXT)');
      },
      version: 1,
    );
  }

  Future<void> _insererBien(Bien bien) async {
    final db = await _baseDeDonnees;
    await db.insert('bien', bien.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _insererAnonce(Annonce annonce) async {
    final db = await _baseDeDonnees;
    await db.insert('annonce', annonce.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          const Center(), // Vous pouvez remplacer cela par le contenu de votre page d'accueil
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DemanderAidePage(idU: widget.idU)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AiderPage(idU: widget.idU)),
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
