import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/authentication.dart';

class RegistroEmpleado extends StatefulWidget {
  const RegistroEmpleado({super.key});

  @override
  State<RegistroEmpleado> createState() => _RegistroEmpleadoState();
}

class _RegistroEmpleadoState extends State<RegistroEmpleado> {
  final _nombreController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final Autenticacion _authService = Autenticacion();
  bool _estaCargando = false;
  bool _ocultarPassword = true;

  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorTarjeta = Color(0xFF252525);
  static const Color colorInput = Color(0xFF333333);
  static const Color colorFuente = Color(0xFFD4AF37);
  static const Color colorGrisTexto = Color(0xFFAAAAAA);

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

  Future<void> _procesarRegistro() async {
    if (_nombreController.text.trim().isEmpty ||
        _celularController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      _mostrarMensaje("Por favor llena todos los campos");
      return;
    }

    setState(() => _estaCargando = true);

    final resultado = await _authService.registrarEmpleado(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
      nombre: _nombreController.text.trim(),
      telefono: _celularController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _estaCargando = false);

    if (resultado['status'] == 'exito') {
      final String puesto = resultado['puesto'] ?? 'empleado';
      final bool esAdmin = puesto == 'admin';
      _mostrarMensaje(
        esAdmin
            ? "¡Bienvenido! Eres el primer empleado del sistema y fuiste asignado como administrador."
            : "¡Cuenta creada! Tu rol es empleado. El administrador puede ajustar tus permisos.",
        esError: false,
      );
      Navigator.pop(context);
    } else {
      _mostrarMensaje(resultado['status'] ?? "Error desconocido al registrar");
    }
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
        title: Text(
          "Registro de Empleado",
          style: GoogleFonts.poppins(
            color: colorFuente,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Únete al Equipo",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colorFuente,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Si eres el primer empleado del sistema, se te asignará como administrador automáticamente.",
                style: GoogleFonts.poppins(fontSize: 13, color: colorGrisTexto),
              ),
              const SizedBox(height: 28),

              _buildTextField("Nombre Completo", Icons.person_outline, _nombreController, TextInputType.name),
              const SizedBox(height: 16),
              _buildTextField("Número de Celular", Icons.phone_iphone, _celularController, TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField("Correo Electrónico", Icons.email_outlined, _emailController, TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 36),

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
                    shadowColor: colorFuente.withValues(alpha: 0.3),
                  ),
                  child: _estaCargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: colorPrincipal, strokeWidth: 3),
                        )
                      : Text(
                          "REGISTRAR EMPLEADO",
                          style: GoogleFonts.poppins(
                            color: colorPrincipal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: "¿Ya tienes cuenta? ",
                      style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Inicia Sesión",
                          style: GoogleFonts.poppins(
                            color: colorFuente,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
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
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

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
          onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
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

  @override
  void dispose() {
    _nombreController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
