import 'package:flutter/material.dart';
import 'lesAnnonces.dart';
import 'reservations.dart';
import 'profil.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../connexion.dart';

final SupabaseClient supabase = Supabase.instance.client;

class Bien {
  final int? idB;
  final String? nom;
  final String? categorie;
  final String? etat;

  Bien({this.idB, this.nom, this.categorie, this.etat});

  Map<String, dynamic> toMap() {
    return {
      'idB': idB,
      'nom': nom,
      'categorie': categorie,
      'etat': etat,
    };
  }
}

class MesBiensPage extends StatefulWidget {
  final String idU;
  final Future<Database> baseDeDonnees;

  const MesBiensPage({required this.idU, required this.baseDeDonnees, Key? key})
      : super(key: key);

  Future<void> ajouterBien(String nom, String categorie, String etat) async {
    final response = await supabase.from('BIEN').select('idB').order('idB');
    int idB = 0;
    for (int i = 0; i < response.length; i++) {
      if (response[i]['idB'] > idB) {
        idB = response[i]['idB'];
        idB++;
      }
    }

    Bien bien = Bien(idB: idB, nom: nom, categorie: categorie, etat: etat);
    final db = await baseDeDonnees;
    await db.insert('bien', bien.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    final response2 =
        await supabase.from('ETATBIEN').select('*').eq('typeEtat', etat);
    if (response2.isEmpty) {
      await supabase.from('ETATBIEN').insert([
        {
          'typeEtat': etat,
        }
      ]);
    }
    final response4 =
        await supabase.from('ETATBIEN').select('idEB').eq('typeEtat', etat);
    final response5 = await supabase
        .from('CATEGORIE')
        .select('*')
        .eq('nomCategorie', categorie);
    if (response5.isEmpty) {
      await supabase.from('CATEGORIE').insert([
        {
          'nomCategorie': categorie,
        }
      ]);
    }
    final response6 = await supabase
        .from('CATEGORIE')
        .select('idC')
        .eq('nomCategorie', categorie);
    final response3 = await supabase.from('BIEN').insert([
      {
        'idU': idU,
        'nom': nom,
        'categorie': response6[0]['idC'],
        'etat': response4[0]['idEB'],
      }
    ]);
  }

  @override
  _MesBiensPageState createState() => _MesBiensPageState();
}

class _MesBiensPageState extends State<MesBiensPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<Bien>> _mesBiens() async {
    final response =
        await supabase.from('BIEN').select('*').eq('idU', widget.idU);
    List<Bien> biens = [];
    for (int i = 0; i < response.length; i++) {
      Bien bien = Bien(
          idB: response[i]['idB'],
          nom: response[i]['nom'],
          categorie: response[i]['categorie'].toString(),
          etat: response[i]['etat'].toString());
      biens.add(bien);
      print("ok");
    }
    return biens;
  }

  Future<void> _supprimerBien(int? idB) async {
    final db = await widget.baseDeDonnees;
    await db.delete(
      'bien',
      where: 'idB =?',
      whereArgs: [idB],
    );
    final response =
        await supabase.from('ANNONCE').select('idA').eq('idB', idB as Object);
    for (var i = 0; i < response.length; i++) {
      final response2 = await supabase
          .from('RESERVATION')
          .delete()
          .eq('idA', response[i]['idA']);
    }
    final response3 =
        await supabase.from('ANNONCE').delete().eq('idB', idB as Object);
    final response4 =
        await supabase.from('BIEN').delete().eq('idB', idB as Object);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes biens'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AjouterBienPage(
                    baseDeDonnees: widget.baseDeDonnees,
                    parentPage: widget,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Bien>>(
        future: _mesBiens(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur de chargement des biens'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucun bien trouvé'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Bien bien = snapshot.data![index];
                return ListTile(
                  title: Text(bien.nom ?? 'Nom non disponible'),
                  subtitle: Text(bien.categorie ?? 'Catégorie non disponible'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _supprimerBien(bien.idB);
                    },
                  ),
                );
              },
            );
          }
        },
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
                  idU: widget.idU,
                  baseDeDonnees: widget.baseDeDonnees,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationsPage(
                  idU: widget.idU,
                  baseDeDonnees: widget.baseDeDonnees,
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilPage(
                  idU: widget.idU,
                  baseDeDonnees: widget.baseDeDonnees,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class AjouterBienPage extends StatefulWidget {
  final Future<Database> baseDeDonnees;
  final MesBiensPage parentPage;

  const AjouterBienPage({
    required this.baseDeDonnees,
    required this.parentPage,
    Key? key,
  }) : super(key: key);

  @override
  _AjouterBienPageState createState() => _AjouterBienPageState();
}

class _AjouterBienPageState extends State<AjouterBienPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _etatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un bien'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom du bien'),
            ),
            TextField(
              controller: _categorieController,
              decoration: InputDecoration(labelText: 'Catégorie du bien'),
            ),
            TextField(
              controller: _etatController,
              decoration: InputDecoration(labelText: 'État du bien'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _ajouterBien();
              },
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ajouterBien() async {
    final String nom = _nomController.text.trim();
    final String categorie = _categorieController.text.trim();
    final String etat = _etatController.text.trim();

    if (nom.isNotEmpty && categorie.isNotEmpty && etat.isNotEmpty) {
      // Ajouter le bien avec les données saisies en utilisant la fonction de MesBiensPage
      await widget.parentPage.ajouterBien(nom, categorie, etat);

      // Une fois le bien ajouté, revenir à la page précédente
      Navigator.pop(context);
    } else {
      // Afficher un message d'erreur si des champs sont vides
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs'),
        ),
      );
    }
  }
}
