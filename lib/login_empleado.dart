import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/authentication.dart';
import 'package:sprint2_chilaqueen/recovery.dart';
import 'package:sprint2_chilaqueen/registro_empleado.dart';
import 'package:sprint2_chilaqueen/ventana_employed.dart';

class LoginEmpleado extends StatefulWidget {
  const LoginEmpleado({super.key});

  @override
  State<LoginEmpleado> createState() => _LoginEmpleadoState();
}

class _LoginEmpleadoState extends State<LoginEmpleado> {
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

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _iniciarSesion() async {
    final String? errorCorreo = _authService.validarCorreo(_emailController.text);
    if (errorCorreo != null) { _mostrarMensaje(errorCorreo); return; }
    final String? errorPass = _authService.validarPassword(_passController.text);
    if (errorPass != null) { _mostrarMensaje(errorPass); return; }

    setState(() => _estaCargando = true);
    final resultado = await _authService.iniciarSesion(
      _emailController.text,
      _passController.text,
    );
    if (!mounted) return;
    setState(() => _estaCargando = false);

    if (resultado['status'] == 'exito') {
      final String puesto = resultado['puesto'] ?? 'cliente';

      // Un cliente que intenta entrar por el portal de empleados recibe error claro
      if (puesto == 'cliente') {
        _mostrarMensaje(
          "Esta cuenta es de cliente. Usa el acceso general para clientes.",
        );
        return;
      }

      // empleado o admin → interfaz administrativa
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainE()),
      );
    } else {
      _mostrarMensaje(resultado['status'] ?? 'Error al iniciar sesión');
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
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                // Badge identificador del portal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorFuente.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorFuente.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.admin_panel_settings_outlined, color: colorFuente, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Portal Administrativo",
                        style: GoogleFonts.poppins(
                          color: colorFuente,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Acceso Empleados",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: colorFuente,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Inicia sesión con tu cuenta de empleado o administrador",
                  style: GoogleFonts.poppins(fontSize: 13, color: colorGrisTexto),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Tarjeta de formulario
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorTarjeta,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Correo electrónico",
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "empleado@chilaqueen.com",
                          hintStyle: TextStyle(color: colorGrisTexto.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: colorInput,
                          prefixIcon: const Icon(Icons.email_outlined, color: colorFuente, size: 20),
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
                      const SizedBox(height: 20),

                      Text(
                        "Contraseña",
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passController,
                        obscureText: _ocultarPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Tu contraseña",
                          hintStyle: TextStyle(color: colorGrisTexto.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: colorInput,
                          prefixIcon: const Icon(Icons.lock_outline, color: colorFuente, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: colorGrisTexto,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
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

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Password()),
                          ),
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
                        width: double.infinity,
                        height: 55,
                        child: _estaCargando
                            ? const Center(child: CircularProgressIndicator(color: colorFuente))
                            : ElevatedButton(
                                onPressed: _iniciarSesion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorFuente,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Ingresar",
                                  style: GoogleFonts.poppins(
                                    color: colorPrincipal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Registrar nuevo empleado
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegistroEmpleado()),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: colorFuente, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Registrar nuevo empleado",
                            style: GoogleFonts.poppins(
                              color: colorFuente,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
