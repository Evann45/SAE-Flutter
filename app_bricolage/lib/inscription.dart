import 'package:app_bricolage/connexion.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final TextEditingController _identifiantController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();

  Future<void> _inscription() async {
    final String identifiant = _identifiantController.text.trim();
    final String mdp = _mdpController.text;

    // Inscription à Supabase en utilisant supabaseClient
    final response = await Supabase.instance.client.from('Utilisateur').insert({
      'identifiant': identifiant,
      'mdp': mdp,
    });

    if (response.error == null) {
      // Inscription réussie, rediriger l'utilisateur vers la page de connexion
      // ignore: use_build_context_synchronously
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ConnexionPage()));
    } else {
      // Erreur lors de l'inscription, afficher un message d'erreur
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur d\'inscription'),
            content:
                const Text('Une erreur est survenue lors de l\'inscription.'),
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
        title: const Text('Inscription'),
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
              onPressed: _inscription,
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
