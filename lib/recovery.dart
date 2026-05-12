import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorFuente = Color(0xFFD4AF37);

  final _emailController = TextEditingController();
  bool _enviando = false;

  Future<void> _enviarRecuperacion() async {
    final correo = _emailController.text.trim();
    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ingresa tu correo", style: GoogleFonts.poppins()), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Correo enviado. Revisa tu bandeja.", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = e.code == 'user-not-found' ? "Correo no registrado." : "Error al enviar. Intenta de nuevo.";
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: GoogleFonts.poppins()), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset("assets/Logo_2.png", width: 300),
              const SizedBox(height: 30),
              Text(
                "RECUPERAR\nCONTRASEÑA",
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: colorFuente, height: 1.2),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      "Introduce tu correo electrónico.\nEnviaremos instrucciones para la recuperación de tu cuenta.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined, color: colorFuente),
                        hintText: "Email registrado",
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Color(0xFF333333),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: colorFuente, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _enviando ? null : _enviarRecuperacion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorFuente,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _enviando
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                            : Text("ENVIAR", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}