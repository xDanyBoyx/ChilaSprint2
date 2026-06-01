import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';
import 'package:sprint2_chilaqueen/utils/validators.dart' as val;

class Autenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- VALIDACIONES LOCALES ---

  String? validarCorreo(String email) => val.validarCorreo(email);

  String? validarPassword(String password) => val.validarPassword(password);

  // --- FUNCIONES DE FIREBASE ---

  // 1. REGISTRO + GUARDAR EN FIRESTORE
  // El orden correcto: Auth primero → luego Firestore (ya autenticado).
  // Usa config/sistema como flag público para saber si ya existe un admin,
  // evitando consultar la colección usuarios sin permisos.
  Future<String?> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
  }) async {
    try {
      // PASO 1 – Crear cuenta en Firebase Auth (sin Firestore todavía)
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // PASO 2 – Ya autenticados, determinar rol usando config/sistema
      // (documento de configuración con lectura pública en Firestore Rules)
      String puesto = 'cliente';
      try {
        final configDoc = await _firestore
            .collection('config')
            .doc('sistema')
            .get();
        final adminCreado = configDoc.data()?['adminCreado'] == true;
        if (!adminCreado) puesto = 'admin';
      } catch (_) {
        // Fallback: consultar usuarios directamente (ya hay token de Auth)
        try {
          final existentes = await _firestore
              .collection('usuarios')
              .where('puesto', whereIn: ['empleado', 'admin'])
              .limit(1)
              .get();
          if (existentes.docs.isNotEmpty) puesto = 'cliente';
        } catch (_) {
          puesto = 'cliente';
        }
      }

      // PASO 3 – Guardar documento del usuario
      await _firestore.collection('usuarios').doc(cred.user!.uid).set({
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        'correo': email.trim(),
        'puesto': puesto,
        'role': puesto,
        'fecha_registro': FieldValue.serverTimestamp(),
        'imagen_perfil': '',
      });

      // PASO 4 – Si es el primer admin, marcar la bandera en config/sistema
      if (puesto == 'admin') {
        await _firestore
            .collection('config')
            .doc('sistema')
            .set({'adminCreado': true}, SetOptions(merge: true));
      }

      await AnalyticsService.logRegistro();
      return 'exito';
    } on FirebaseAuthException catch (e) {
      return _manejarErrorFirebase(e.code);
    } catch (e) {
      return 'Error inesperado al registrar. Intenta de nuevo.';
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
        debugPrint("Error leyendo el rol en Firestore: $e");
      }

      await AnalyticsService.logLogin();
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

  // 3. REGISTRO DE EMPLEADO + DETECCIÓN AUTOMÁTICA DE ROL ADMIN
  // Si no existe ningún empleado/admin en Firestore, el primero es asignado como admin.
  Future<Map<String, dynamic>> registrarEmpleado({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
  }) async {
    String? correoError = validarCorreo(email);
    if (correoError != null) return {'status': correoError};
    String? passError = validarPassword(password);
    if (passError != null) return {'status': passError};

    try {
      // Consultar si ya existe algún empleado o admin registrado en el sistema
      final QuerySnapshot existentes = await _firestore
          .collection('usuarios')
          .where('puesto', whereIn: ['empleado', 'admin'])
          .limit(1)
          .get();

      // Si la colección de empleados está vacía, el primero se convierte en admin
      final String puesto = existentes.docs.isEmpty ? 'admin' : 'empleado';

      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection('usuarios').doc(cred.user!.uid).set({
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        'correo': email.trim(),
        'puesto': puesto,
        'fecha_registro': FieldValue.serverTimestamp(),
        'imagen_perfil': '',
      });

      await AnalyticsService.logEmpleadoContratado(puesto);
      return {'status': 'exito', 'puesto': puesto};
    } on FirebaseAuthException catch (e) {
      return {'status': _manejarErrorFirebase(e.code)};
    } catch (e) {
      return {'status': 'Error inesperado. Intenta de nuevo.'};
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