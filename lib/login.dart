import 'package:flutter/material.dart';
import 'package:sprint2_chilaqueen/authentication.dart';
import 'package:sprint2_chilaqueen/recovery.dart';
import 'package:sprint2_chilaqueen/registro.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/ventana_user.dart';
import 'package:sprint2_chilaqueen/ventana_employed.dart'; // Importante para el rol empleado

class Chilaqueen extends StatefulWidget {
  const Chilaqueen({super.key});

  @override
  State<Chilaqueen> createState() => _ChilaqueenState();
}

const Color colorPrincipal = Color(0xFF1A1A1A);
const Color colorFuente = Color(0xFFD4AF37);

class _ChilaqueenState extends State<Chilaqueen> {
  // 1. Controladores y Servicios
  final userController = TextEditingController();
  final passController = TextEditingController();
  final Autenticacion _authService = Autenticacion();
  bool _estaCargando = false;



  // Función para mostrar alertas rápidas
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset("assets/Logo_2.png", width: 400),
              const SizedBox(height: 20),
              Text(
                "INICIAR SESIÓN",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colorFuente,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Card(
                  color: colorPrincipal,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: colorFuente, width: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CORREO ELECTRÓNICO: ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: colorFuente,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: userController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "ejemplo@correo.com",
                            hintStyle: TextStyle(color: colorFuente.withOpacity(0.6)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: colorFuente),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: colorFuente, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "CONTRASEÑA: ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: colorFuente,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Tu contraseña",
                            hintStyle: TextStyle(color: colorFuente.withOpacity(0.6)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: colorFuente),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: colorFuente, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Botón de Ingresar con Lógica de Firebase
                        Center(
                          child: _estaCargando
                              ? const CircularProgressIndicator(color: colorFuente)
                              : ElevatedButton(
                            onPressed: () async {
                              // 1. Validaciones Locales
                              String? errorCorreo = _authService.validarCorreo(userController.text);
                              String? errorPass = _authService.validarPassword(passController.text);

                              if (errorCorreo != null) {
                                _mostrarMensaje(errorCorreo);
                                return;
                              }
                              if (errorPass != null) {
                                _mostrarMensaje(errorPass);
                                return;
                              }

                              // 2. Intento de Login
                              setState(() => _estaCargando = true);

                              var resultado = await _authService.iniciarSesion(
                                  userController.text,
                                  passController.text
                              );

                              setState(() => _estaCargando = false);

                              if (resultado["status"] == "exito") {
                                String puesto = resultado["puesto"] ??
                                    "cliente";

                                switch (puesto) {
                                  case "cliente":
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const MainU()),
                                    );
                                    break;

                                  case "empleado":
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const MainE()),
                                    );
                                    break;

                                  case "admin":
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const MainE()),
                                    );
                                    break;

                                  default:
                                    _mostrarMensaje("Rol desconocido");
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorFuente,
                              minimumSize: const Size(200, 45),
                            ),
                            child: const Text(
                              "INGRESAR",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Registro()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              side: const BorderSide(color: colorFuente),
                              minimumSize: const Size(200, 45),
                            ),
                            child: const Text(
                              "REGISTRARSE",
                              style: TextStyle(color: colorFuente, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Password()),
                  );
                },
                child: Text(
                  "¿OLVIDASTE TU CONTRASEÑA?",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: colorFuente,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}