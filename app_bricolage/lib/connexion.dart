import 'package:flutter/material.dart';
import 'inscription.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController _identifiantController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();

  Future<void> _connexion() async {
    final String identifiant = _identifiantController.text.trim();
    final String mdp = _mdpController.text;

    // Requête de connexion à Supabase
    final response = await Supabase.instance.client
        .from('Utilisateur')
        .select()
        .eq('identifiant', identifiant)
        .eq('mdp', mdp);

    // Vérifiez si l'utilisateur existe
    if (response.isNotEmpty) {
      // Utilisateur trouvé, connecté avec succès
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage()));
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
              controller: _identifiantController,
              decoration: const InputDecoration(labelText: 'Identifiant'),
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
