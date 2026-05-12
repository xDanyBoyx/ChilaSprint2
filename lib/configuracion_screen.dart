import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  final _auth = FirebaseAuth.instance;

  bool _notisPedidos = true;
  bool _notisPromos = false;
  bool _faceId = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _cargando = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final prefs = (doc.data()?['preferencias'] as Map<String, dynamic>?) ?? {};
      _notisPedidos = prefs['notis_pedidos'] ?? true;
      _notisPromos = prefs['notis_promos'] ?? false;
      _faceId = prefs['face_id'] ?? false;
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _guardarPreferencia(String campo, bool valor) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'preferencias': {campo: valor}
    }, SetOptions(merge: true));
  }

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
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: colorFuente))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text("Notificaciones", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                _crearSwitch("Actualizaciones de pedidos", "Te avisamos cuando tu comida vaya en camino", _notisPedidos, (val) {
                  setState(() => _notisPedidos = val);
                  _guardarPreferencia('notis_pedidos', val);
                }),
                _crearSwitch("Promociones y Ofertas", "Entérate primero de los descuentos", _notisPromos, (val) {
                  setState(() => _notisPromos = val);
                  _guardarPreferencia('notis_promos', val);
                }),

                const SizedBox(height: 30),
                Text("Seguridad", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                _crearSwitch("Iniciar sesión con FaceID / Huella", "Para entrar más rápido a la app", _faceId, (val) {
                  setState(() => _faceId = val);
                  _guardarPreferencia('face_id', val);
                }),

                const SizedBox(height: 30),
                Text("Acerca de", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ListTile(
                  title: Text("Términos y Condiciones", style: GoogleFonts.poppins(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: colorGrisTexto, size: 14),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const _PaginaLegal(titulo: "Términos y Condiciones", contenido: _kTerminos),
                  )),
                ),
                ListTile(
                  title: Text("Aviso de Privacidad", style: GoogleFonts.poppins(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: colorGrisTexto, size: 14),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const _PaginaLegal(titulo: "Aviso de Privacidad", contenido: _kPrivacidad),
                  )),
                ),
                ListTile(
                  title: Text("Versión", style: GoogleFonts.poppins(color: Colors.white)),
                  trailing: Text("1.0.0", style: GoogleFonts.poppins(color: colorGrisTexto)),
                  contentPadding: EdgeInsets.zero,
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
      activeThumbColor: Colors.black,
      activeTrackColor: colorFuente,
      inactiveThumbColor: colorGrisTexto,
      inactiveTrackColor: colorTarjeta,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _PaginaLegal extends StatelessWidget {
  final String titulo;
  final String contenido;
  const _PaginaLegal({required this.titulo, required this.contenido});

  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorFuente = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFuente),
        title: Text(titulo, style: GoogleFonts.playfairDisplay(color: colorFuente, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          contenido,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.6),
        ),
      ),
    );
  }
}

const String _kTerminos = '''
Bienvenido a ChilaQueen. Al usar esta aplicación aceptas los siguientes términos:

1. USO DEL SERVICIO
La app está destinada a la solicitud y entrega de productos alimenticios. El usuario se compromete a usarla de manera responsable y conforme a las leyes vigentes.

2. PEDIDOS
Una vez confirmado un pedido, este pasa al estado "Nuevo" y entra al flujo de cocina. Las cancelaciones después de "Preparando" pueden no ser posibles.

3. PAGOS Y PRECIOS
Los precios mostrados están en pesos mexicanos (MXN) e incluyen impuestos. Los extras seleccionados se suman al precio base.

4. CUENTA DE USUARIO
El usuario es responsable de mantener la confidencialidad de sus credenciales. ChilaQueen no se hace responsable de accesos no autorizados derivados de descuido del usuario.

5. ENTREGAS
Los tiempos estimados son aproximados y pueden variar según la demanda y zona de entrega.

6. MODIFICACIONES
ChilaQueen se reserva el derecho de modificar estos términos en cualquier momento. Se notificará a los usuarios mediante la aplicación.
''';

const String _kPrivacidad = '''
En ChilaQueen nos tomamos en serio tu privacidad.

DATOS QUE RECOPILAMOS
- Nombre, correo electrónico y teléfono
- Direcciones de entrega
- Historial de pedidos y preferencias
- Información de inicio de sesión vía Firebase Authentication

CÓMO LOS USAMOS
Tu información se utiliza exclusivamente para:
- Procesar tus pedidos y notificarte su estado
- Mejorar la experiencia dentro de la app
- Contactarte en caso de incidencias con un pedido

COMPARTIR CON TERCEROS
No vendemos ni compartimos tus datos personales con terceros con fines comerciales. Únicamente se comparte la información indispensable con repartidores para realizar la entrega.

DERECHOS ARCO
Puedes ejercer tus derechos de acceso, rectificación, cancelación u oposición escribiéndonos desde la sección de soporte.

SEGURIDAD
Tus datos se almacenan en servicios de Google Cloud (Firebase) con cifrado en tránsito y reposo.
''';
