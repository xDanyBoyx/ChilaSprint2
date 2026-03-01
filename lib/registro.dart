import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorFuente = Color(0xFFD4AF37);

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
                    _buildTextField("NOMBRE COMPLETO", Icons.person),
                    const SizedBox(height: 15),

                    _buildTextField("NÚMERO DE CELULAR", Icons.phone_android),
                    const SizedBox(height: 15),

                    _buildTextField("CORREO ELECTRÓNICO", Icons.email),
                    const SizedBox(height: 15),

                    _buildTextField("CONTRASEÑA", Icons.lock, isPassword: true),
                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
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

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return TextField(
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