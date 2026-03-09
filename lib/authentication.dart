import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Autenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- VALIDACIONES LOCALES ---

  String? validarCorreo(String email) {
    if (email.isEmpty) return "El correo es obligatorio";
    // Expresión regular para validar formato de email
    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (!emailValid) return "Formato de correo inválido";
    return null;
  }

  String? validarPassword(String password) {
    if (password.isEmpty) return "La contraseña es obligatoria";
    if (password.length < 6) return "Mínimo 6 caracteres";
    return null;
  }

  // --- FUNCIONES DE FIREBASE ---

  // 1. REGISTRO + GUARDAR EN FIRESTORE
  Future<String?> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
  }) async {
    try {
      // Crear en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Guardar datos adicionales en Firestore (Modelo de datos que diseñamos)
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': nombre,
        'telefono': telefono,
        'correo': email.trim(),
        'puesto': 'cliente', // Por defecto es cliente
        'fecha_registro': DateTime.now(),
      });

      return "exito";
    } on FirebaseAuthException catch (e) {
      return _manejarErrorFirebase(e.code);
    }
  }

  // 2. LOGIN + VERIFICAR ROL
  Future<Map<String, dynamic>> iniciarSesion(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Consultar el puesto en Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return {"status": "exito", "puesto": userDoc.get('puesto')};
      }
      return {"status": "Error: Datos de usuario no encontrados"};

    } on FirebaseAuthException catch (e) {
      return {"status": _manejarErrorFirebase(e.code)};
    }
  }

  // Traductor de errores de Firebase para el usuario
  String _manejarErrorFirebase(String code) {
    switch (code) {
      case 'weak-password': return "La contraseña es muy débil.";
      case 'email-already-in-use': return "Este correo ya está registrado.";
      case 'user-not-found': return "Usuario no encontrado.";
      case 'wrong-password': return "Contraseña incorrecta.";
      case 'invalid-email': return "Correo inválido.";
      default: return "Ocurrió un error. Intenta de nuevo.";
    }
  }
}