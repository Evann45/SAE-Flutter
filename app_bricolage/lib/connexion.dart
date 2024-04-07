import 'package:flutter/material.dart';
import 'inscription.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'appli/lesAnnonces.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages

final SupabaseClient supabase = Supabase.instance.client;

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
  final String? nom;
  final String? categorie;
  final String? etat;

  Bien({
    required this.idB,
    required this.nom,
    required this.categorie,
    required this.etat,
  });

  Map<String, Object?> toMap() {
    return {
      'idB': idB,
      'nom': nom,
      'categorie': categorie,
      'etat': etat,
    };
  }
}

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController _adresseMailController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();
  late Future<Database> _baseDeDonnees;

  Future<void> _connexion() async {
    final String adresseMail = _adresseMailController.text.trim();
    final String mdp = _mdpController.text;

    // Requête de connexion à Supabase
    final response = await supabase
        .from('USER')
        .select()
        .eq('address_mail', adresseMail)
        .eq('mdp', mdp);

    // Vérifiez si l'utilisateur existe
    if (response.isNotEmpty) {
      final idU = response[0]['idU'];
      _initialiserBaseDeDonnees(idU);
      // Utilisateur trouvé, connecté avec succès
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LesAnnoncesPrep(idU: idU, baseDeDonnees: _baseDeDonnees)));
    } else {
      // Aucun utilisateur correspondant trouvé, afficher un message d'erreur
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur de connexion'),
            content: const Text('Identifiant ou mot de passe incorrect.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _initialiserBaseDeDonnees(String idU) async {
    WidgetsFlutterBinding.ensureInitialized();
    _baseDeDonnees = _ouvrirBaseDeDonnees();
    _insererDonneesBiens(idU);
    print('ok');
    //_insererDonneesAnnonces(idU);
  }

  Future<Database> _ouvrirBaseDeDonnees() async {
    return openDatabase(
      'bien.db',
      onCreate: (baseDeDonnees, version) async {
        await baseDeDonnees.execute(
          'CREATE TABLE bien(idB INTEGER PRIMARY KEY, nom TEXT, categorie TEXT, etat TEXT)',
        );
        await baseDeDonnees.execute(
          'CREATE TABLE annonce(idA INTEGER PRIMARY KEY, titre TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _insererBien(Bien bien) async {
    final db = await _baseDeDonnees;
    await db.insert('bien', bien.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _insererDonneesBiens(String idU) async {
    int? idBien;
    String? nomB;
    int? categorieB;
    int? etatB;
    String? categorieBien;
    String? etatBien;
    final response = await supabase.from('BIEN').select().eq('idU', idU);
    for (var i = 0; i < response.length; i++) {
      setState(() {
        idBien = response[i]['idB'] as int?;
        nomB = response[i]['nom'] as String?;
        categorieB = response[i]['categorie'] as int?;
        etatB = response[i]['etat'] as int?;
      });
      final cat = await supabase
          .from('CATEGORIE')
          .select()
          .eq('idC', categorieB as Object)
          .single();
      final etatt = await supabase
          .from('ETATBIEN')
          .select()
          .eq('idEB', etatB as Object)
          .single();
      setState(() {
        categorieBien = cat['nomCategorie'] as String?;
        etatBien = etatt['typeEtat'] as String?;
      });
      await _insererBien(Bien(
          idB: idBien, nom: nomB, categorie: categorieBien, etat: etatBien));
    }
  }

  Future<void> _insererAnonce(Annonce annonce) async {
    final db = await _baseDeDonnees;
    await db.insert('annonce', annonce.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _insererDonneesAnnonces(String idU) async {
    int? idA;
    String titre;
    final response = await supabase.from('ANNONCE').select();
    for (var i = 0; i < response.length; i++) {
      idA = response[i]['idA'] as int?;
      titre = response[i]['titre'] as String;
      await _insererAnonce(Annonce(idA: idA, titre: titre));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _adresseMailController,
              decoration: const InputDecoration(labelText: 'Adresse mail'),
            ),
            TextField(
              controller: _mdpController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _connexion,
              child: const Text('Se connecter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InscriptionPage()),
                );
              },
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
