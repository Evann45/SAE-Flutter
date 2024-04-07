import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'lesAnnonces.dart';
import 'mesBiens.dart';
import 'profil.dart';
import '../connexion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;

class ReservationsPage extends StatefulWidget {
  final String idU;
  final Future<Database> baseDeDonnees;

  const ReservationsPage(
      {required this.idU, required this.baseDeDonnees, Key? key})
      : super(key: key);

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  late Future<List<List>> _futureReservations;

  @override
  void initState() {
    super.initState();
    _futureReservations = recupReservations();
  }

  Future<List<List>> recupReservations() async {
    final response =
        await supabase.from('RESERVATION').select('*').eq('idU', widget.idU);
    List<List> reservations = [];
    for (int i = 0; i < response.length; i++) {
      final response2 = await supabase
          .from('ANNONCE')
          .select('*')
          .eq('idA', response[i]['idA']);
      final response3 = await supabase
          .from('BIEN')
          .select('*')
          .eq('idB', response2[0]['idB']);
      reservations.add([response2[0]['titre'], response3[0]['nom']]);
    }
    return reservations;
  }

  Future<void> supprimerReservation(String titre, String nom) async {
    final response3 =
        await supabase.from('BIEN').select('idB').eq('nom', nom).single();
    final response2 = await supabase
        .from('ANNONCE')
        .select('*')
        .eq('titre', titre)
        .eq('idB', response3['idB'])
        .single();
    final response = await supabase
        .from('RESERVATION')
        .delete()
        .eq('idA', response2['idA'] as int)
        .eq('idU', widget.idU);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations'),
      ),
      body: FutureBuilder<List<List>>(
        future: _futureReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur de chargement des réservations'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucune réservation trouvée'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final reservation = snapshot.data![index];
                return ListTile(
                  title: Text(reservation[0]),
                  subtitle: Text(reservation[1]),
                  // Bouton "Annuler" pour supprimer la réservation
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Annuler la réservation'),
                            content:
                                Text('Voulez-vous annuler cette réservation ?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Non'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Oui'),
                                onPressed: () {
                                  supprimerReservation(
                                      reservation[0], reservation[1]);
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _futureReservations = recupReservations();
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
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
                      idU: widget.idU, baseDeDonnees: widget.baseDeDonnees)),
            );
          } else if (index == 1) {
            // Définissez ici la navigation pour la page de demande
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MesBiensPage(
                      idU: widget.idU, baseDeDonnees: widget.baseDeDonnees)),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilPage(
                      idU: widget.idU, baseDeDonnees: widget.baseDeDonnees)),
            );
          }
        },
      ),
    );
  }
}
