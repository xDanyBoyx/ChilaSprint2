import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorTarjeta = Color(0xFF252525);
  static const Color colorFuente = Color(0xFFD4AF37);
  static const Color colorGrisTexto = Color(0xFFAAAAAA);

  bool notisPedidos = true;
  bool notisPromos = false;
  bool faceId = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFuente),
        title: Text("Configuración", style: GoogleFonts.playfairDisplay(color: colorFuente, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text("Notificaciones", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _crearSwitch("Actualizaciones de pedidos", "Te avisamos cuando tu comida vaya en camino", notisPedidos, (val) => setState(() => notisPedidos = val)),
          _crearSwitch("Promociones y Ofertas", "Entérate primero de los descuentos", notisPromos, (val) => setState(() => notisPromos = val)),

          const SizedBox(height: 30),
          Text("Seguridad", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _crearSwitch("Iniciar sesión con FaceID / Huella", "Para entrar más rápido a la app", faceId, (val) => setState(() => faceId = val)),

          const SizedBox(height: 30),
          Text("Acerca de", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ListTile(
            title: Text("Términos y Condiciones", style: GoogleFonts.poppins(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: colorGrisTexto, size: 14),
            contentPadding: EdgeInsets.zero,
            onTap: () {},
          ),
          ListTile(
            title: Text("Aviso de Privacidad", style: GoogleFonts.poppins(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: colorGrisTexto, size: 14),
            contentPadding: EdgeInsets.zero,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _crearSwitch(String titulo, String subtitulo, bool valor, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(titulo, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitulo, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
      value: valor,
      onChanged: onChanged,
      activeColor: Colors.black,
      activeTrackColor: colorFuente,
      inactiveThumbColor: colorGrisTexto,
      inactiveTrackColor: colorTarjeta,
      contentPadding: EdgeInsets.zero,
    );
  }
}