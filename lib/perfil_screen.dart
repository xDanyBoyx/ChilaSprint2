import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorTarjeta = Color(0xFF252525);
  static const Color colorInput = Color(0xFF333333);
  static const Color colorFuente = Color(0xFFD4AF37);
  static const Color colorGrisTexto = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFuente),
        title: Text("Mi Perfil", style: GoogleFonts.playfairDisplay(color: colorFuente, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/user.png')),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: colorFuente, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _campoPerfil("Nombre Completo", "Juan Pérez"),
            const SizedBox(height: 20),
            _campoPerfil("Correo Electrónico", "juan@ejemplo.com"),
            const SizedBox(height: 20),
            _campoPerfil("Teléfono", "+52 311 123 4567"),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: colorFuente, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text("GUARDAR CAMBIOS", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _campoPerfil(String label, String valorInicial) {
    return TextField(
      controller: TextEditingController(text: valorInicial),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: colorGrisTexto),
        filled: true,
        fillColor: colorInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}