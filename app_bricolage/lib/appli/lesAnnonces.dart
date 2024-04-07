import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reservations.dart';
import 'mesBiens.dart';
import 'profil.dart';
import '../connexion.dart';
import 'package:sqflite/sqflite.dart';

final SupabaseClient supabase = Supabase.instance.client;

class Annonce {
  final int? idA;
  final String titre;
  final String description;

  Annonce({
    required this.idA,
    required this.titre,
    required this.description,
  });

  Map<String, Object?> toMap() {
    return {
      'idA': idA,
      'titre': titre,
      'description': description,
    };
  }
}

class LesAnnoncesPrep extends StatefulWidget {
  final String idU;
  final Future<Database> baseDeDonnees;

  const LesAnnoncesPrep({
    required this.idU,
    required this.baseDeDonnees,
    Key? key,
  }) : super(key: key);

  @override
  _LesAnnoncesPageState createState() => _LesAnnoncesPageState();
}

class _LesAnnoncesPageState extends State<LesAnnoncesPrep> {
  late Future<List<Annonce>> _futureAnnonces;

  @override
  void initState() {
    super.initState();
    _futureAnnonces = getAllAnnonces();
  }

  Future<List<Annonce>> getAllAnnonces() async {
    final response = await supabase.from('ANNONCE').select('*').eq('etat', 1);
    List<Annonce> annonces = [];
    if (response.isNotEmpty) {
      for (int i = 0; i < response.length; i++) {
        Annonce annonce = Annonce(
          idA: response[i]['idA'] as int?,
          titre: response[i]['titre'] as String,
          description: response[i]['description'] as String,
        );
        annonces.add(annonce);
      }
    }
    return annonces;
  }

  Future<void> ajouterAnnonce(
      String titre, String description, String bien) async {
    final response2 = await supabase.from('BIEN').select('idB').eq('nom', bien);
    if (response2.isNotEmpty) {
      final response3 = await supabase
          .from('BIEN')
          .select('idU')
          .eq('idU', widget.idU)
          .eq('nom', bien);
      if (response3.isNotEmpty) {
        int idB = response2[0]['idB'] as int;
        await supabase.from('ANNONCE').insert([
          {
            'titre': titre,
            'description': description,
            'idB': idB,
          }
        ]);
      } else {}
    } else {}
  }

  Future<void> ajouterReservation(String titre, String description) async {
    final response = await supabase
        .from('ANNONCE')
        .select('idA')
        .eq('titre', titre)
        .eq('description', description)
        .single();
    final response2 = await supabase.from('RESERVATION').insert([
      {
        'idU': widget.idU,
        'idA': response['idA'] as int,
      }
    ]);
    final updateResponse = await supabase
        .from('ANNONCE')
        .update({'etat': 2}).eq('idA', response['idA']);
  }

  void reserverAnnonce(String titre, String description) {
    ajouterReservation(titre, description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Annonces'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AjouterAnnoncePage(
                    baseDeDonnees: widget.baseDeDonnees,
                    ajouterAnnonce: ajouterAnnonce,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Annonce>>(
        future: _futureAnnonces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur de chargement des annonces'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucune annonce trouvée'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final annonce = snapshot.data![index];
                return ListTile(
                  title: Text(annonce.titre),
                  subtitle: Text(annonce.description),
                  trailing: ElevatedButton(
                    onPressed: () {
                      reserverAnnonce(annonce.titre, annonce.description);
                    },
                    child: Text('Réserver'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnonceDetailsPage(
                          titre: annonce.titre,
                          description: annonce.description,
                        ),
                      ),
                    );
                  },
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationsPage(
                  idU: widget.idU,
                  baseDeDonnees: widget.baseDeDonnees,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MesBiensPage(
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

class AjouterAnnoncePage extends StatefulWidget {
  final Future<Database> baseDeDonnees;
  final Function(String, String, String) ajouterAnnonce;

  const AjouterAnnoncePage({
    required this.baseDeDonnees,
    required this.ajouterAnnonce,
    Key? key,
  }) : super(key: key);

  @override
  _AjouterAnnoncePageState createState() => _AjouterAnnoncePageState();
}

class _AjouterAnnoncePageState extends State<AjouterAnnoncePage> {
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _bienController;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController();
    _descriptionController = TextEditingController();
    _bienController = TextEditingController();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _bienController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une annonce'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titreController,
              decoration: InputDecoration(
                labelText: 'Titre de l\'annonce',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description de l\'annonce',
              ),
            ),
            TextField(
              controller: _bienController,
              decoration: InputDecoration(
                labelText: 'Nom du bien',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String titre = _titreController.text;
                String description = _descriptionController.text;
                String bien = _bienController.text;
                widget.ajouterAnnonce(titre, description, bien);
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnonceDetailsPage extends StatelessWidget {
  final String titre;
  final String description;

  const AnnonceDetailsPage({
    required this.titre,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'annonce'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Titre : $titre',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Description : $description',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
