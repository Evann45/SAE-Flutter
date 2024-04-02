import 'package:flutter/material.dart';
import 'connexion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialisez Supabase ici
  await Supabase.initialize(
      url: 'https://byorrcgamqjssunvaiao.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5b3JyY2dhbXFqc3N1bnZhaWFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTEzNzg2NTYsImV4cCI6MjAyNjk1NDY1Nn0.Lh1nx_79s6ljfKOEHVk1TwlIVWR4R8GamAlXjX_ulG4');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ConnexionPage(),
    );
  }
}
