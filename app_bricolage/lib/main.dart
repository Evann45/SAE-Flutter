import 'package:flutter/material.dart';
import 'connexion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // Initialisez Supabase ici
  Supabase.initialize(
    url: 'https://gxacgfvcfdcrdteexekg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4YWNnZnZjZmRjcmR0ZWV4ZWtnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE5NzQ4MjgsImV4cCI6MjAyNzU1MDgyOH0.yAP6euVRG_Cap3KPl7ecoSM3CvNZ3GkmJF3EKgp2uEA',
  );

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
