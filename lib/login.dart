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

  // Nuevo: Control para ver/ocultar contraseña
  bool _ocultarPassword = true;

  // Nuevos colores
  final Color colorTarjeta = const Color(0xFF252525);
  final Color colorInput = const Color(0xFF333333);
  final Color colorGrisTexto = const Color(0xFFAAAAAA);

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Scroll más suave
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Image.asset("assets/Logo_2.png", width: 250),
                const SizedBox(height: 30),

                // Título
                Text(
                  "Bienvenido de vuelta",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorFuente, // Dorado
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Inicia sesión para continuar",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorGrisTexto,
                  ),
                ),
                const SizedBox(height: 40),

                // Tarjeta Principal
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorTarjeta,
                    borderRadius: BorderRadius.circular(24), // Bordes súper redondeados
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label Correo
                      Text(
                        "Correo electrónico",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Input Correo
                      TextField(
                        controller: userController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "ejemplo@correo.com",
                          hintStyle: TextStyle(color: colorGrisTexto.withOpacity(0.6)),
                          filled: true,
                          fillColor: colorInput, // Fondo del input diferente al de la tarjeta
                          prefixIcon: const Icon(Icons.email_outlined, color: colorFuente, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none, // Quitamos el borde duro
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: colorFuente, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Label Contraseña
                      Text(
                        "Contraseña",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Input Contraseña
                      TextField(
                        controller: passController,
                        obscureText: _ocultarPassword, // Usamos la variable de estado
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Tu contraseña",
                          hintStyle: TextStyle(color: colorGrisTexto.withOpacity(0.6)),
                          filled: true,
                          fillColor: colorInput,
                          prefixIcon: const Icon(Icons.lock_outline, color: colorFuente, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: colorGrisTexto,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarPassword = !_ocultarPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: colorFuente, width: 1.5),
                          ),
                        ),
                      ),

                      // Olvidaste tu contraseña
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Password()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          ),
                          child: Text(
                            "¿Olvidaste tu contraseña?",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorFuente,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Botón Ingresar
                      SizedBox(
                        width: double.infinity, // Ocupa todo el ancho
                        height: 55, // Más alto, fácil de tocar
                        child: _estaCargando
                            ? const Center(child: CircularProgressIndicator(color: colorFuente))
                            : ElevatedButton(
                          onPressed: () async {
                            //
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

                            setState(() => _estaCargando = true);

                            var resultado = await _authService.iniciarSesion(
                                userController.text,
                                passController.text
                            );

                            setState(() => _estaCargando = false);

                            if (resultado["status"] == "exito") {
                              String puesto = resultado["puesto"] ?? "cliente";

                              switch (puesto) {
                                case "cliente":
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainU()));
                                  break;
                                case "empleado":
                                case "admin":
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainE()));
                                  break;
                                default:
                                  _mostrarMensaje("Rol desconocido");
                              }
                            } else {
                              // AQUÍ ESTÁ EL CAMBIO: Mostrar el error devuelto por Firebase
                              _mostrarMensaje(resultado["status"]);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorFuente,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Iniciar Sesión",
                            style: GoogleFonts.poppins(
                              color: colorPrincipal,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Registrarse
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Registro()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: colorFuente, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Crear una cuenta",
                            style: GoogleFonts.poppins(
                              color: colorFuente,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}