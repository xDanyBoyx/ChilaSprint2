import 'package:flutter/material.dart';
import 'package:sprint2_chilaqueen/recovery.dart';
import 'package:sprint2_chilaqueen/registro.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/ventana_user.dart';

class Chilaqueen extends StatefulWidget {
  const Chilaqueen({super.key});

  @override
  State<Chilaqueen> createState() => _ChilaqueenState();
}

final user = TextEditingController();
final pass = TextEditingController();
const Color colorPrincipal = Color(0xFF1A1A1A);
const Color colorFuente = Color(0xFFD4AF37);

class _ChilaqueenState extends State<Chilaqueen> {
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
                          "USUARIO: ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: colorFuente,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: user,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Nombre de usuario",
                            hintStyle: TextStyle(color: colorFuente.withOpacity(0.6)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: colorFuente),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: colorFuente, width: 2),
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
                          controller: pass,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Contraseña",
                            hintStyle: TextStyle(color: colorFuente.withOpacity(0.6)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: colorFuente),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: colorFuente, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainU(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorFuente,
                            ),
                            child: const Text(
                              "INGRESAR",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Registro(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
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
                    MaterialPageRoute(
                      builder: (context) => const Password(),
                    ),
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
