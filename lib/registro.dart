import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/authentication.dart'; // Tu clase de lógica

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  // 1. Controladores para capturar los datos
  final _nombreController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // 2. Instancia de tu servicio de autenticación
  final Autenticacion _authService = Autenticacion();
  bool _estaCargando = false;

  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorFuente = Color(0xFFD4AF37);

  // Función para mostrar alertas
  void _mostrarMensaje(String mensaje, {bool esError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFuente),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.asset("assets/LogoB_2.png", width: 100),
              const SizedBox(height: 10),
              Text(
                "REGISTRO",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorFuente,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    _buildTextField("NOMBRE COMPLETO", Icons.person, _nombreController),
                    const SizedBox(height: 15),
                    _buildTextField("NÚMERO DE CELULAR", Icons.phone_android, _celularController),
                    const SizedBox(height: 15),
                    _buildTextField("CORREO ELECTRÓNICO", Icons.email, _emailController),
                    const SizedBox(height: 15),
                    _buildTextField("CONTRASEÑA", Icons.lock, _passController, isPassword: true),
                    const SizedBox(height: 35),

                    // Botón con lógica funcional
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _estaCargando
                          ? const Center(child: CircularProgressIndicator(color: colorFuente))
                          : ElevatedButton(
                        onPressed: () async {
                          // Validaciones simples antes de procesar
                          if (_nombreController.text.isEmpty || _celularController.text.isEmpty) {
                            _mostrarMensaje("Por favor llena todos los campos");
                            return;
                          }

                          setState(() => _estaCargando = true);

                          // Llamada a tu clase Autenticacion
                          String? resultado = await _authService.registrarUsuario(
                            email: _emailController.text,
                            password: _passController.text,
                            nombre: _nombreController.text,
                            telefono: _celularController.text,
                          );

                          setState(() => _estaCargando = false);

                          if (resultado == "exito") {
                            _mostrarMensaje("¡Cuenta creada con éxito!", esError: false);
                            Navigator.pop(context); // Regresa al login
                          } else {
                            _mostrarMensaje(resultado ?? "Error desconocido");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorFuente,
                          side: const BorderSide(color: Colors.black, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "CREAR CUENTA",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget de TextField actualizado para recibir el controlador
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller, // Asignamos el controlador aquí
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: colorFuente, size: 20),
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: colorFuente, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: colorFuente, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: colorFuente, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}