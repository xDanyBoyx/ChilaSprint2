import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Autenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- VALIDACIONES LOCALES ---

  String? validarCorreo(String email) {
    if (email.isEmpty) return "El correo es obligatorio";
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

      // Guardar datos adicionales en Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        'correo': email.trim(),
        'puesto': 'cliente', // Por defecto es cliente
        'fecha_registro': FieldValue.serverTimestamp(), // ¡Toma la hora exacta del servidor!
        'imagen_perfil': '', // El nuevo campo que agregaste preparado para usarse
      });

      return "exito";
    } on FirebaseAuthException catch (e) {
      return _manejarErrorFirebase(e.code);
    }
  }

  // 2. LOGIN + VERIFICAR ROL
  Future<Map<String, dynamic>> iniciarSesion(String email, String password) async {
    try {
      // Intentamos iniciar sesión
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String puesto = "cliente"; // Semáforo por defecto

      try {
        // Vamos a Firestore a leer qué tipo de usuario es
        DocumentSnapshot userDoc = await _firestore
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          puesto = data["puesto"] ?? "cliente";
        }
      } catch (e) {
        print("Error leyendo el rol en Firestore: $e");
      }

      // Regresamos el éxito y a dónde lo debe mandar la pantalla
      return {
        "status": "exito",
        "puesto": puesto
      };

    } on FirebaseAuthException catch (e) {
      return {"status": _manejarErrorFirebase(e.code)};
    } catch (e) {
      return {"status": "Error inesperado al iniciar sesión."};
    }
  }

  // Traductor de errores de Firebase para el usuario
  String _manejarErrorFirebase(String code) {
    switch (code) {
      case 'weak-password': return "La contraseña es muy débil.";
      case 'email-already-in-use': return "Este correo ya está registrado.";
      case 'invalid-credential': return "Correo o contraseña incorrectos."; // ¡El nuevo error de seguridad de Firebase!
      case 'user-not-found': return "Usuario no encontrado."; // Por si usas una versión viejita
      case 'wrong-password': return "Contraseña incorrecta."; // Por si usas una versión viejita
      case 'invalid-email': return "Correo inválido.";
      default: return "Ocurrió un error. Intenta de nuevo. ($code)";
    }
  }
}