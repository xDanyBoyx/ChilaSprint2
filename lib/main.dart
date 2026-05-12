import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'analytics_service.dart';
import 'login.dart';
import 'ventana_user.dart';
import 'ventana_employed.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Espera a que Auth restaure la sesión (evita currentUser == null)
  final user = await FirebaseAuth.instance.authStateChanges().first;

  Widget home = const Chilaqueen();

  if (user != null) {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final data = doc.data();
      final puesto = data?['puesto'] ?? 'cliente';
      home = puesto == 'cliente' ? const MainU() : const MainE();
    } catch (_) {
      home = const Chilaqueen();
    }
  }

  runApp(MaterialApp(
    home: home,
    debugShowCheckedModeBanner: false,
    navigatorObservers: [AnalyticsService.observer],
  ));
}

