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
  bool _ocultarPassword = true; // NUEVO: Para el ojito de la contraseña

  // Paleta de colores unificada
  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorTarjeta = Color(0xFF252525);
  static const Color colorInput = Color(0xFF333333);
  static const Color colorFuente = Color(0xFFD4AF37);
  static const Color colorGrisTexto = Color(0xFFAAAAAA);

  // Función para mostrar alertas
  void _mostrarMensaje(String mensaje, {bool esError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: esError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset("assets/LogoB_2.png", width: 90)),
                const SizedBox(height: 20),

                // Textos de Bienvenida
                Text(
                  "Únete a la Realeza",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorFuente,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Crea tu cuenta y empieza a pedir los mejores chilaquiles de la ciudad.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorGrisTexto,
                  ),
                ),
                const SizedBox(height: 35),

                // Formulario
                _buildTextField("Nombre Completo", Icons.person_outline, _nombreController, TextInputType.name),
                const SizedBox(height: 16),
                _buildTextField("Número de Celular", Icons.phone_iphone, _celularController, TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField("Correo Electrónico", Icons.email_outlined, _emailController, TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildPasswordField(), // Widget especial para la contraseña
                const SizedBox(height: 40),

                // Botón Principal
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _estaCargando ? null : _procesarRegistro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorFuente,
                      disabledBackgroundColor: colorTarjeta,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: colorFuente.withOpacity(0.3),
                    ),
                    child: _estaCargando
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: colorPrincipal, strokeWidth: 3),
                    )
                        : Text(
                      "CREAR CUENTA",
                      style: GoogleFonts.poppins(
                        color: colorPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Enlace al Login
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: "¿Ya tienes una cuenta? ",
                        style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Inicia Sesión",
                            style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Lógica separada para mantener el build limpio
  Future<void> _procesarRegistro() async {
    if (_nombreController.text.trim().isEmpty ||
        _celularController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      _mostrarMensaje("Por favor llena todos los campos");
      return;
    }

    try {
      setState(() => _estaCargando = true);

      String? resultado = await _authService.registrarUsuario(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        nombre: _nombreController.text.trim(),
        telefono: _celularController.text.trim(),
      );

      if (!mounted) return; // Buena práctica al usar BuildContext después de un await
      setState(() => _estaCargando = false);

      if (resultado == "exito") {
        _mostrarMensaje("¡Cuenta creada con éxito!", esError: false);
        Navigator.pop(context);
      } else {
        _mostrarMensaje(resultado ?? "Error desconocido al registrar");
      }
    } catch (e) {
      setState(() => _estaCargando = false);
      _mostrarMensaje("Error de conexión al registrar usuario");
    }
  }

  // Widget para campos de texto normales
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14),
        prefixIcon: Icon(icon, color: colorFuente, size: 22),
        filled: true,
        fillColor: colorInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18), // Más altura para que se vea premium
      ),
    );
  }

  // Widget especial para la contraseña (con ojito)
  Widget _buildPasswordField() {
    return TextField(
      controller: _passController,
      obscureText: _ocultarPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Contraseña",
        hintStyle: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: colorFuente, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: colorGrisTexto,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _ocultarPassword = !_ocultarPassword;
            });
          },
        ),
        filled: true,
        fillColor: colorInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}