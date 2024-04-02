import 'package:flutter/material.dart';
import 'inscription.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'appli/home.dart';

final SupabaseClient supabase = Supabase.instance.client;

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController _adresseMailController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();

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
      // Utilisateur trouvé, connecté avec succès
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => HomePagePrep(idU: idU)));
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
