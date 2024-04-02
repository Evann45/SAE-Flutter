import 'package:app_bricolage/connexion.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({Key? key}) : super(key: key);

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final TextEditingController _identifiantController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseMailController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();

  Future<void> _inscription() async {
    final String identifiant = _identifiantController.text.trim();
    final String prenom = _prenomController.text.trim();
    final String adresseMail = _adresseMailController.text.trim();
    final String mdp = _mdpController.text;

    final response = await supabase
        .from('USER')
        .select()
        .eq('address_mail', adresseMail)
        .eq('mdp', mdp);

    if (response.isNotEmpty) {
    } else {
      await supabase.from('USER').insert({
        'nom': identifiant,
        'prenom': prenom,
        'address_mail': adresseMail,
        'mdp': mdp,
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ConnexionPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _identifiantController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
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
                onPressed: _inscription,
                child: const Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
