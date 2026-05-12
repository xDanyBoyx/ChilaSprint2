import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:sprint2_chilaqueen/login.dart';
import 'analytics_service.dart';

class MainE extends StatefulWidget {
  const MainE({super.key});

  @override
  State<MainE> createState() => _MainEState();
}

class _MainEState extends State<MainE> {
  int _indice = 0;
  String _miPuesto = '';
  String _miNombre = '';
  String _miCorreo = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();
      if (data != null && mounted) {
        setState(() {
          _miNombre = data['nombre'] as String? ?? 'Usuario';
          _miCorreo = data['correo'] as String? ?? FirebaseAuth.instance.currentUser?.email ?? '';
          _miPuesto = data['puesto'] as String? ?? 'empleado';
        });
      }
    } catch (_) {}
  }

  // Paleta de colores Premium
  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorTarjeta = Color(0xFF252525);
  static const Color colorInput = Color(0xFF333333);
  static const Color colorFuente = Color(0xFFD4AF37);
  static const Color colorGrisTexto = Color(0xFFAAAAAA);
  static const Color colorVerdeExito = Color(0xFF4CAF50);
  static const Color colorRojoAlerta = Color(0xFFF44336);

  final List<String> estadosPedido = ['Nuevo', 'Preparando', 'En camino', 'Listo para recoger', 'Entregado', 'Cancelado'];

  // ==================== DATOS DE SUCURSAL ====================
  final List<String> opcionesDemanda = ["Baja (10-15 min)", "Normal (15-25 min)", "Alta (30-45 min)", "Saturada (+50 min)"];

  // ==================== DATOS DE STOCK ====================


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFuente),
        title: Image.asset('assets/LogoB_2.png', height: 40),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawer: _crearDrawer(),
      body: SafeArea(child: _contenido()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: colorInput, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _indice,
          onTap: (pos) => setState(() => _indice = pos),
          backgroundColor: colorPrincipal,
          selectedItemColor: colorFuente,
          unselectedItemColor: colorGrisTexto,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "TICKETS"),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: "STOCK"),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: "FINANZAS"),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: "SUCURSAL"),
            BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: "EQUIPO"),
          ],
        ),
      ),
    );
  }

  // ==================== RUTAS DEL NAVEGADOR ====================
  Widget _contenido() {
    switch (_indice) {
      case 0: return _moduloTickets();
      case 1: return _moduloStock();
      case 2: return _moduloFinanzas();
      case 3: return _moduloSucursal();
      case 4: return _moduloEmpleados();
      default: return _moduloTickets();
    }
  }

  // ==================== DRAWER ACTUALIZADO (MENÚ LATERAL) ====================
  Widget _crearDrawer() {
    return Drawer(
      backgroundColor: colorPrincipal,
      child: Column(
        children: [
          // CABECERA DEL DRAWER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: colorTarjeta,
              border: Border(bottom: BorderSide(color: colorFuente, width: 2)),
            ),
            accountName: Text(
                _miNombre.isEmpty ? 'Cargando...' : _miNombre,
                style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            accountEmail: Text(
                _miCorreo,
                style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)
            ),
            currentAccountPicture: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: colorFuente, shape: BoxShape.circle),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/user.png'), // Tu imagen
                backgroundColor: colorInput,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // OPCIONES DEL MENÚ
          _itemDrawer(icono: Icons.person_outline, titulo: "Mi Perfil Administrativo"),
          _itemDrawer(icono: Icons.print_outlined, titulo: "Impresora de Tickets"),
          _itemDrawer(icono: Icons.notifications_none, titulo: "Notificaciones"),
          _itemDrawer(icono: Icons.help_outline, titulo: "Soporte Técnico"),

          const Spacer(),
          const Divider(color: colorInput, thickness: 1),

          // CERRAR SESIÓN
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colorRojoAlerta.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.logout, color: colorRojoAlerta, size: 20),
            ),
            title: Text("Cerrar Sesión", style: GoogleFonts.poppins(color: colorRojoAlerta, fontWeight: FontWeight.w600, fontSize: 15)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Chilaqueen()), (route) => false);
              }
            },
          ),

          // VERSIÓN DE LA APP
          Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 10),
            child: Text("ChilaQueen Admin v1.0.0", style: GoogleFonts.poppins(color: colorInput, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para los botones del Drawer
  Widget _itemDrawer({required IconData icono, required String titulo}) {
    return ListTile(
      leading: Icon(icono, color: colorFuente, size: 22),
      title: Text(titulo, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: colorGrisTexto, size: 18),
      onTap: () {
        // Aquí puedes agregar la navegación en el futuro
        Navigator.pop(context); // Cierra el drawer al tocar
      },
    );
  }

  // ==================== MÓDULO 4: SUCURSAL ====================
  Widget _moduloSucursal() {
    final docRef = FirebaseFirestore.instance.collection('config').doc('sucursal');

    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        Map<String, dynamic> data = {};
        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>;
        }

        bool sucursalAbierta = data['abierta'] ?? true;
        String nivelGuardado = data['nivel_demanda'] ?? "Normal (15-25 min)";
        String nivelValido = opcionesDemanda.contains(nivelGuardado) ? nivelGuardado : opcionesDemanda[1];

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text("Gestión de Sucursal", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Controla la operación general de ChilaQueen matriz.", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
            const SizedBox(height: 30),

            // --- TARJETA ESTADO ABIERTO/CERRADO ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: sucursalAbierta ? colorTarjeta : colorRojoAlerta.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sucursalAbierta ? colorFuente.withValues(alpha: 0.3) : colorRojoAlerta.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(sucursalAbierta ? Icons.storefront : Icons.store_outlined,
                              color: sucursalAbierta ? colorVerdeExito : colorRojoAlerta, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ESTADO ACTUAL", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              Text(
                                sucursalAbierta ? "Abierto" : "Cerrado temporalmente",
                                style: GoogleFonts.poppins(color: sucursalAbierta ? colorVerdeExito : colorRojoAlerta, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: sucursalAbierta,
                        onChanged: _miPuesto == 'admin'
                            ? (valor) {
                                docRef.set({'abierta': valor}, SetOptions(merge: true));
                                AnalyticsService.logSucursalToggle(valor);
                              }
                            : null,
                        activeThumbColor: colorPrincipal,
                        activeTrackColor: colorVerdeExito,
                        inactiveThumbColor: colorGrisTexto,
                        inactiveTrackColor: colorInput,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sucursalAbierta
                        ? "La sucursal está recibiendo pedidos con normalidad."
                        : "Los clientes no pueden hacer pedidos en este momento.",
                    style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text("TRÁFICO EN COCINA", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),

            // --- DROPDOWN NIVEL DE DEMANDA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: nivelValido,
                  dropdownColor: colorTarjeta,
                  icon: const Icon(Icons.expand_more, color: colorFuente),
                  isExpanded: true,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  items: opcionesDemanda.map((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
                  onChanged: _miPuesto == 'admin'
                      ? (String? newValue) {
                          if (newValue != null) docRef.set({'nivel_demanda': newValue}, SetOptions(merge: true));
                        }
                      : null,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text("Este tiempo se mostrará como 'Tiempo Estimado' global en la app del cliente.", style: TextStyle(color: colorGrisTexto, fontSize: 11)),
            ),

            const SizedBox(height: 30),
            Text("CLIMA ACTUAL", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            _tarjetaClima(),

            const SizedBox(height: 30),
            Text("INFORMACIÓN", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _filaInfoSucursal(Icons.location_on_outlined, "Dirección", "Av. Insurgentes Sur 1234, CDMX"),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: colorInput, height: 1)),
                  _filaInfoSucursal(Icons.access_time, "Horario de Hoy", "08:00 AM - 04:00 PM"),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: colorInput, height: 1)),
                  _filaInfoSucursal(Icons.phone_outlined, "Teléfono Contacto", "55 1234 5678"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filaInfoSucursal(IconData icono, String titulo, String valor) { return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icono, color: colorFuente, size: 20), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)), Text(valor, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))]))]); }

  // ==================== CLIMA (Open-Meteo REST API) ====================
  Future<Map<String, dynamic>> _fetchClima() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=19.4326&longitude=-99.1332&current_weather=true',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['current_weather'] as Map<String, dynamic>;
    }
    throw Exception('Error ${response.statusCode}');
  }

  Map<String, String> _infoClima(int code) {
    if (code == 0)  return {'emoji': '☀️',  'desc': 'Despejado',            'nota': 'Clima ideal, pedidos normales esperados.'};
    if (code <= 3)  return {'emoji': '🌤️',  'desc': 'Parcialmente nublado', 'nota': 'Clima favorable para entregas.'};
    if (code <= 48) return {'emoji': '🌫️',  'desc': 'Niebla',               'nota': 'Visibilidad reducida en entregas.'};
    if (code <= 67) return {'emoji': '🌧️',  'desc': 'Lluvia',               'nota': 'Alta demanda de delivery esperada.'};
    if (code <= 77) return {'emoji': '🌨️',  'desc': 'Nieve',                'nota': 'Considera cerrar temporalmente.'};
    if (code <= 82) return {'emoji': '🌦️',  'desc': 'Chubascos',            'nota': 'Posible aumento en pedidos.'};
    return             {'emoji': '⛈️',  'desc': 'Tormenta',             'nota': 'Considera cerrar temporalmente.'};
  }

  Widget _tarjetaClima() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchClima(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: colorFuente, strokeWidth: 2))),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.wifi_off, color: colorGrisTexto, size: 20),
              const SizedBox(width: 12),
              Text("Sin datos de clima disponibles", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
            ]),
          );
        }

        final clima = snapshot.data!;
        final temp = (clima['temperature'] as num).toDouble();
        final code = (clima['weathercode'] as num).toInt();
        final info = _infoClima(code);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colorFuente.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(info['emoji']!, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('${temp.toStringAsFixed(1)}°C', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(info['desc']!, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
                    ]),
                    const SizedBox(height: 4),
                    Text(info['nota']!, style: GoogleFonts.poppins(color: colorFuente, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== RESTO DEL CÓDIGO (FINANZAS, TICKETS, STOCK) ====================
  Widget _moduloFinanzas() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .where('estadoActual', whereIn: ['Entregado', 'Cancelado'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: colorFuente));
        }

        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        final todayDocs = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final fecha = data['fecha'];
          if (fecha == null) return false;
          return !(fecha as Timestamp).toDate().isBefore(startOfDay);
        }).toList();

        final entregadosDia = todayDocs.where((d) => (d.data() as Map<String, dynamic>)['estadoActual'] == 'Entregado').toList();
        final canceladosCount = todayDocs.length - entregadosDia.length;

        double ingresos = 0;
        final Map<String, int> conteoPlatos = {};
        final Map<int, int> conteoPorHora = {};

        for (var doc in entregadosDia) {
          final data = doc.data() as Map<String, dynamic>;
          ingresos += ((data['precio_total'] ?? 0) as num).toDouble();
          final platillo = data['platillo'] as String? ?? 'Otro';
          conteoPlatos[platillo] = (conteoPlatos[platillo] ?? 0) + 1;
          final fecha = data['fecha'];
          if (fecha != null) {
            final hora = (fecha as Timestamp).toDate().hour;
            conteoPorHora[hora] = (conteoPorHora[hora] ?? 0) + 1;
          }
        }

        final totalPedidos = entregadosDia.length;
        final totalGeneral = todayDocs.length;
        final ticketPromedio = totalPedidos > 0 ? ingresos / totalPedidos : 0.0;
        final tasaExito = totalGeneral > 0 ? totalPedidos / totalGeneral : 0.0;
        final tasaStr = (tasaExito * 100).toStringAsFixed(0);

        int? horaPico;
        int maxEnHora = 0;
        conteoPorHora.forEach((hora, total) {
          if (total > maxEnHora) { maxEnHora = total; horaPico = hora; }
        });
        final horaPicoStr = horaPico != null
            ? '${horaPico.toString().padLeft(2, '0')}:00  —  $maxEnHora pedidos'
            : 'Sin datos aún';

        final topVentas = conteoPlatos.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final maxVentas = topVentas.isNotEmpty ? topVentas.first.value : 1;

        const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
        final fechaHoy = '${now.day} ${meses[now.month - 1]} ${now.year}';

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Resumen del Día", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 28, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: colorInput, borderRadius: BorderRadius.circular(20)),
                  child: Text(fechaHoy, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Ingresos totales
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colorTarjeta, colorInput.withValues(alpha: 0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorFuente.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text("INGRESOS TOTALES", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(
                    "\$${ingresos.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(color: colorVerdeExito, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  if (totalPedidos == 0) ...[
                    const SizedBox(height: 8),
                    Text("Sin pedidos entregados hoy", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3 métricas
            Row(
              children: [
                Expanded(child: _tarjetaMetrica(icono: Icons.receipt_long, titulo: "PEDIDOS", valor: "$totalPedidos", colorIcono: colorFuente)),
                const SizedBox(width: 10),
                Expanded(child: _tarjetaMetrica(icono: Icons.payments_outlined, titulo: "TICKET PROM.", valor: "\$${ticketPromedio.toStringAsFixed(2)}", colorIcono: Colors.white)),
                const SizedBox(width: 10),
                Expanded(child: _tarjetaMetrica(icono: Icons.cancel_outlined, titulo: "CANCELADOS", valor: "$canceladosCount", colorIcono: colorRojoAlerta)),
              ],
            ),
            const SizedBox(height: 16),

            // Tasa de éxito
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TASA DE ÉXITO", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text("$tasaStr%", style: GoogleFonts.poppins(color: colorVerdeExito, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: colorRojoAlerta.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: tasaExito,
                        child: Container(height: 8, decoration: BoxDecoration(color: colorVerdeExito, borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$totalPedidos completados", style: GoogleFonts.poppins(color: colorVerdeExito, fontSize: 11)),
                      Text("$canceladosCount cancelados", style: GoogleFonts.poppins(color: colorRojoAlerta, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Hora pico
            Row(children: [
              const Icon(Icons.bolt, color: colorFuente, size: 20),
              const SizedBox(width: 10),
              Text("HORA PICO", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: colorFuente.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.access_time, color: colorFuente, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(horaPicoStr, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text("Momento de mayor actividad del día", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Top vendidos
            Row(children: [
              const Icon(Icons.star, color: colorFuente, size: 20),
              const SizedBox(width: 10),
              Text("TOP MÁS VENDIDOS", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ]),
            const SizedBox(height: 20),

            if (topVentas.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text("Aún no hay ventas hoy", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
                ),
              )
            else
              ...topVentas.take(5).toList().asMap().entries.map((entry) => _barraVentas(
                rank: entry.key + 1,
                platillo: entry.value.key,
                ventas: entry.value.value,
                porcentaje: entry.value.value / maxVentas,
                totalVentas: totalPedidos,
              )),
          ],
        );
      },
    );
  }
  Widget _tarjetaMetrica({required IconData icono, required String titulo, required String valor, required Color colorIcono}) { return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icono, color: colorIcono, size: 18), const SizedBox(width: 8), Text(titulo, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))]), const SizedBox(height: 12), Text(valor, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))])); }
  Widget _barraVentas({required String platillo, required int ventas, required double porcentaje, int rank = 0, int totalVentas = 0}) {
    const medallas = ['🥇', '🥈', '🥉'];
    final medallaStr = rank >= 1 && rank <= 3 ? medallas[rank - 1] : '$rank.';
    final pct = totalVentas > 0 ? (ventas / totalVentas * 100).toStringAsFixed(0) : '0';
    final Color barColor = rank == 1
        ? colorFuente
        : rank == 2
            ? const Color(0xFFB0BEC5)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : colorGrisTexto;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(medallaStr, style: TextStyle(fontSize: rank <= 3 ? 16 : 13, color: barColor)),
              const SizedBox(width: 8),
              Expanded(child: Text(platillo, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
              Text("$ventas ord.", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
              const SizedBox(width: 8),
              Text("$pct%", style: GoogleFonts.poppins(color: barColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(children: [
            Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: colorInput, borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(widthFactor: porcentaje, child: Container(height: 8, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4)))),
          ]),
        ],
      ),
    );
  }

  // ==================== HELPERS DE FECHA ====================
  String _formatFecha(dynamic ts) {
    if (ts == null) return 'Sin fecha';
    final dt = (ts as Timestamp).toDate();
    const m = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${dt.day.toString().padLeft(2,'0')} ${m[dt.month-1]} ${dt.year}';
  }
  String _formatHora(dynamic ts) {
    if (ts == null) return '--:--';
    final dt = (ts as Timestamp).toDate();
    return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  // ==================== MÓDULO: TICKETS ====================
  Widget _moduloTickets() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .where('estadoActual', whereIn: ['Nuevo', 'Preparando', 'En camino', 'Listo para recoger'])
          .snapshots(),
      builder: (context, snapshot) {
        final activos = snapshot.data?.docs ?? [];
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: colorPrincipal,
                child: TabBar(
                  indicatorColor: colorFuente,
                  indicatorWeight: 3,
                  labelColor: colorFuente,
                  unselectedLabelColor: colorGrisTexto,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: [
                    Tab(text: "🔥 ACTIVOS (${activos.length})"),
                    const Tab(text: "📋 HISTORIAL"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [_listaPedidosActivos(activos), _listaPedidosHistorial()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _listaPedidosActivos(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, color: colorGrisTexto, size: 60),
            const SizedBox(height: 16),
            Text("Sin pedidos activos", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final docId = docs[index].id;
        return _ticketCocina(
          docId: docId,
          id: docId.substring(0, 6).toUpperCase(),
          cliente: data['cliente_nombre'] ?? 'Cliente',
          fecha: _formatFecha(data['fecha']),
          hora: _formatHora(data['fecha']),
          platillo: data['platillo'] ?? 'Sin platillo',
          notas: List<String>.from(data['notas'] ?? []),
          estadoActual: data['estadoActual'] ?? 'Nuevo',
          tiempoEstimado: data['tiempoEstimado'] ?? 'Sin asignar',
        );
      },
    );
  }

  Widget _ticketCocina({
    required String docId,
    required String id,
    required String cliente,
    required String fecha,
    required String hora,
    required String platillo,
    required List<String> notas,
    required String estadoActual,
    required String tiempoEstimado,
  }) {
    final docRef = FirebaseFirestore.instance.collection('pedidos').doc(docId);
    String valorDropdown = estadosPedido.contains(estadoActual) ? estadoActual : estadosPedido.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: estadoActual == 'Nuevo' ? colorFuente : Colors.transparent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: colorInput, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#$id", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
                Row(children: [
                  const Icon(Icons.calendar_today, color: colorGrisTexto, size: 14),
                  const SizedBox(width: 4),
                  Text("$fecha • $hora", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.person, color: colorGrisTexto, size: 18),
                  const SizedBox(width: 8),
                  Text(cliente, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 16),
                Text("1x $platillo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...notas.map((nota) {
                  Color colorNota = colorGrisTexto;
                  if (nota.startsWith('+')) colorNota = colorVerdeExito;
                  if (nota.startsWith('-')) colorNota = colorRojoAlerta;
                  if (nota.startsWith('Ojo:')) colorNota = colorFuente;
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text(nota, style: GoogleFonts.poppins(color: colorNota, fontSize: 13, fontWeight: FontWeight.w500)),
                  );
                }),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: colorInput, height: 1)),
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: colorInput, borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: valorDropdown,
                          dropdownColor: colorTarjeta,
                          icon: const Icon(Icons.keyboard_arrow_down, color: colorFuente),
                          isExpanded: true,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          items: estadosPedido.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              docRef.update({'estadoActual': newValue});
                              AnalyticsService.logPedidoActualizado(newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => _mostrarModalTiempo(context, docId, id, tiempoEstimado),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorFuente.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(8),
                          color: tiempoEstimado != "Sin asignar" ? colorFuente.withValues(alpha: 0.1) : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer_outlined, color: tiempoEstimado != "Sin asignar" ? colorFuente : colorGrisTexto, size: 16),
                            const SizedBox(width: 4),
                            Text(tiempoEstimado, style: GoogleFonts.poppins(color: tiempoEstimado != "Sin asignar" ? colorFuente : colorGrisTexto, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModalTiempo(BuildContext context, String docId, String idPedido, String tiempoActual) {
    final List<String> opciones = ["5 min", "10 min", "15 min", "20 min", "30 min", "45 min"];
    String tiempoSeleccionado = opciones.contains(tiempoActual) ? tiempoActual : opciones[0];

    showModalBottomSheet(
      context: context,
      backgroundColor: colorTarjeta,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colorGrisTexto.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Text("Asignar ETA", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Pedido #$idPedido", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: opciones.map((tiempo) {
                    bool sel = tiempoSeleccionado == tiempo;
                    return InkWell(
                      onTap: () => setModalState(() => tiempoSeleccionado = tiempo),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 72) / 3,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? colorFuente : colorInput,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: sel ? colorFuente : Colors.transparent),
                        ),
                        child: Center(child: Text(tiempo, style: GoogleFonts.poppins(color: sel ? colorPrincipal : Colors.white, fontWeight: sel ? FontWeight.bold : FontWeight.normal))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: colorVerdeExito, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('pedidos').doc(docId).update({'tiempoEstimado': tiempoSeleccionado});
                      Navigator.pop(context);
                    },
                    child: Text("Confirmar Tiempo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _listaPedidosHistorial() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .where('estadoActual', whereIn: ['Entregado', 'Cancelado'])
          .snapshots(),
      builder: (context, snapshot) {
        final historial = snapshot.data?.docs ?? [];
        if (historial.isEmpty) {
          return Center(child: Text("Sin historial aún", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 15)));
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: historial.length,
          itemBuilder: (context, index) {
            final data = historial[index].data() as Map<String, dynamic>;
            final docId = historial[index].id;
            return _ticketHistorial(
              id: docId.substring(0, 6).toUpperCase(),
              data: data,
            );
          },
        );
      },
    );
  }

  Widget _ticketHistorial({required String id, required Map<String, dynamic> data}) {
    final estado = data['estadoActual'] ?? '';
    final cliente = data['cliente_nombre'] ?? 'Cliente';
    final hora = _formatHora(data['fecha']);
    final bool esCancelado = estado == "Cancelado";

    return GestureDetector(
      onTap: () => _mostrarDetalleHistorial(id: id, data: data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: esCancelado ? colorRojoAlerta.withValues(alpha: 0.2) : colorVerdeExito.withValues(alpha: 0.2),
            child: Icon(esCancelado ? Icons.close : Icons.check, color: esCancelado ? colorRojoAlerta : colorVerdeExito, size: 20),
          ),
          title: Text("#$id • $cliente", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(estado, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hora, style: GoogleFonts.poppins(color: colorFuente, fontSize: 12)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: colorGrisTexto, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleHistorial({required String id, required Map<String, dynamic> data}) {
    final estado = data['estadoActual'] ?? '';
    final cliente = data['cliente_nombre'] ?? 'Cliente';
    final platillo = data['platillo'] ?? 'Sin platillo';
    final notas = List<String>.from(data['notas'] ?? []);
    final precioTotal = data['precio_total']?.toString() ?? '—';
    final fecha = _formatFecha(data['fecha']);
    final hora = _formatHora(data['fecha']);
    final bool esCancelado = estado == "Cancelado";

    showModalBottomSheet(
      context: context,
      backgroundColor: colorTarjeta,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colorGrisTexto.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),

            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#$id", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 22, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: esCancelado ? colorRojoAlerta.withValues(alpha: 0.15) : colorVerdeExito.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(estado, style: GoogleFonts.poppins(color: esCancelado ? colorRojoAlerta : colorVerdeExito, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("$fecha • $hora", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
            const Divider(color: colorInput, height: 30),

            // Cliente
            _filaDetalle(Icons.person_outline, "Cliente", cliente),
            const SizedBox(height: 14),

            // Platillo
            _filaDetalle(Icons.restaurant_menu, "Platillo", "1x $platillo"),
            const SizedBox(height: 14),

            // Notas
            if (notas.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, color: colorFuente, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Notas", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                        ...notas.map((nota) {
                          Color colorNota = colorGrisTexto;
                          if (nota.startsWith('+')) colorNota = colorVerdeExito;
                          if (nota.startsWith('-')) colorNota = colorRojoAlerta;
                          if (nota.startsWith('Ojo:')) colorNota = colorFuente;
                          return Text(nota, style: GoogleFonts.poppins(color: colorNota, fontSize: 13, fontWeight: FontWeight.w500));
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Precio
            _filaDetalle(Icons.payments_outlined, "Total", "\$$precioTotal MXN"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _filaDetalle(IconData icono, String label, String valor) {
    return Row(
      children: [
        Icon(icono, color: colorFuente, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11)),
            Text(valor, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _moduloStock() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: colorFuente));
        }

        final docs = snapshot.data?.docs ?? [];
        final disponibles = docs.where((d) => (d.data() as Map<String, dynamic>)['disponible'] != false).length;
        final agotados = docs.length - disponibles;

        final Map<String, List<QueryDocumentSnapshot>> porCategoria = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final cat = (data['categoria'] as String? ?? 'otros').toLowerCase();
          porCategoria.putIfAbsent(cat, () => []).add(doc);
        }

        return Stack(
          children: [
            docs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: colorGrisTexto, size: 60),
                        const SizedBox(height: 16),
                        Text("Sin productos registrados", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 15)),
                        const SizedBox(height: 8),
                        Text("Toca AGREGAR para añadir al menú", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    children: [
                      Text("Control de Menú", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Activa o desactiva productos según disponibilidad.", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _chipResumen("$disponibles disponibles", colorVerdeExito),
                          const SizedBox(width: 10),
                          _chipResumen("$agotados agotados", colorRojoAlerta),
                        ],
                      ),
                      ...porCategoria.entries.map((entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 28),
                          _headerCategoria(entry.key),
                          const SizedBox(height: 12),
                          ...entry.value.map((doc) => _itemStock(
                            docId: doc.id,
                            data: doc.data() as Map<String, dynamic>,
                          )),
                        ],
                      )),
                    ],
                  ),
            if (_miPuesto == 'admin')
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorFuente,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: Text("AGREGAR PRODUCTO", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  onPressed: _mostrarDialogoAgregarProducto,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _itemStock({required String docId, required Map<String, dynamic> data}) {
    final nombre = data['nombre'] as String? ?? 'Sin nombre';
    final precio = data['precio'] ?? data['precio_base'];
    final disponible = data['disponible'] != false;
    final precioStr = precio != null ? '\$${precio.toString()}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: disponible ? Colors.transparent : colorRojoAlerta.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: disponible ? colorVerdeExito : colorRojoAlerta)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.poppins(
                    color: disponible ? Colors.white : colorGrisTexto,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: disponible ? TextDecoration.none : TextDecoration.lineThrough,
                    decorationColor: colorGrisTexto,
                  ),
                ),
                if (precioStr.isNotEmpty)
                  Text(precioStr, style: GoogleFonts.poppins(color: colorFuente, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Switch(
            value: disponible,
            onChanged: _miPuesto == 'admin'
                ? (valor) => FirebaseFirestore.instance.collection('productos').doc(docId).update({'disponible': valor})
                : null,
            activeThumbColor: colorPrincipal,
            activeTrackColor: colorFuente,
            inactiveThumbColor: colorGrisTexto,
            inactiveTrackColor: colorInput,
          ),
        ],
      ),
    );
  }

  Widget _chipResumen(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(texto, style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _headerCategoria(String categoria) {
    const iconos = <String, IconData>{
      'platillo': Icons.restaurant_menu,
      'proteína': Icons.set_meal_outlined,
      'extra': Icons.egg_alt_outlined,
      'bebida': Icons.local_drink_outlined,
      'postre': Icons.cake_outlined,
    };
    final icono = iconos[categoria] ?? Icons.category_outlined;
    return Row(children: [
      Icon(icono, color: colorFuente, size: 20),
      const SizedBox(width: 10),
      Text(categoria.toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
    ]);
  }

  void _mostrarDialogoAgregarProducto() {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String categoriaSeleccionada = 'platillo';
    bool guardando = false;
    String? errorMsg;
    const categorias = ['platillo', 'proteína', 'extra', 'bebida', 'postre'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colorTarjeta,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.add_box_outlined, color: colorFuente),
              const SizedBox(width: 10),
              Text("Nuevo Producto", style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nombre *", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: nombreCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ej. Chilaquiles con Arrachera",
                    hintStyle: const TextStyle(color: colorGrisTexto),
                    filled: true,
                    fillColor: colorInput,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Text("Categoría", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categorias.map((cat) => _chipRol(cat, categoriaSeleccionada, (c) => setDialogState(() => categoriaSeleccionada = c))).toList(),
                ),
                const SizedBox(height: 16),
                Text("Precio (MXN) *", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: precioCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "0.00",
                    hintStyle: const TextStyle(color: colorGrisTexto),
                    prefixIcon: const Icon(Icons.attach_money, color: colorFuente, size: 20),
                    filled: true,
                    fillColor: colorInput,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Text("Descripción (opcional)", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ingredientes o descripción breve...",
                    hintStyle: const TextStyle(color: colorGrisTexto),
                    filled: true,
                    fillColor: colorInput,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 10),
                  Text(errorMsg!, style: GoogleFonts.poppins(color: colorRojoAlerta, fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.poppins(color: colorGrisTexto)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorFuente,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: guardando ? null : () async {
                final nombre = nombreCtrl.text.trim();
                if (nombre.isEmpty) { setDialogState(() => errorMsg = "El nombre es obligatorio"); return; }
                final precio = double.tryParse(precioCtrl.text.trim());
                if (precio == null || precio <= 0) { setDialogState(() => errorMsg = "Ingresa un precio válido"); return; }
                setDialogState(() { guardando = true; errorMsg = null; });
                try {
                  await FirebaseFirestore.instance.collection('productos').add({
                    'nombre': nombre,
                    'categoria': categoriaSeleccionada,
                    'precio': precio,
                    'descripcion': descCtrl.text.trim(),
                    'disponible': true,
                  });
                  AnalyticsService.logProductoAgregado(categoriaSeleccionada);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  setDialogState(() { guardando = false; errorMsg = "Error al guardar. Verifica permisos."; });
                }
              },
              child: guardando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text("Agregar", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MÓDULO: EMPLEADOS ====================
  Widget _moduloEmpleados() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: colorFuente));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins(color: Colors.white)));
            }

            var empleados = (snapshot.data?.docs ?? []).where((doc) {
              final puesto = (doc.data() as Map<String, dynamic>)['puesto'] ?? '';
              return puesto != 'cliente' && puesto.isNotEmpty;
            }).toList();

            if (empleados.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_off, color: colorGrisTexto, size: 60),
                    const SizedBox(height: 16),
                    Text("Sin empleados registrados", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text("Usa CONTRATAR para agregar al equipo", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: empleados.length,
              itemBuilder: (context, index) {
                var data = empleados[index].data() as Map<String, dynamic>;
                String docId = empleados[index].id;
                return _tarjetaEmpleado(docId: docId, data: data);
              },
            );
          },
        ),
        if (_miPuesto == 'admin')
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorFuente,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
              ),
              icon: const Icon(Icons.person_add, color: Colors.black),
              label: Text("CONTRATAR", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              onPressed: _mostrarDialogoContratar,
            ),
          ),
      ],
    );
  }

  Widget _tarjetaEmpleado({required String docId, required Map<String, dynamic> data}) {
    String nombre = data['nombre'] ?? 'Sin nombre';
    String puesto = data['puesto'] ?? 'empleado';
    String telefono = data['telefono'] ?? 'Sin teléfono';
    String correo = data['correo'] ?? 'Sin correo';
    String imagenUrl = data['imagen_perfil'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: puesto == 'admin' ? colorFuente.withValues(alpha: 0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colorInput,
            backgroundImage: imagenUrl.isNotEmpty ? NetworkImage(imagenUrl) : null,
            child: imagenUrl.isEmpty ? const Icon(Icons.person, color: colorGrisTexto, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: puesto == 'admin' ? colorFuente.withValues(alpha: 0.15) : colorInput,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(puesto.toUpperCase(), style: GoogleFonts.poppins(color: puesto == 'admin' ? colorFuente : colorGrisTexto, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                Text(telefono, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                Text(correo, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (_miPuesto == 'admin')
            IconButton(
              onPressed: () => _confirmarDarDeBaja(docId, nombre),
              icon: const Icon(Icons.cancel, color: colorRojoAlerta, size: 28),
            ),
        ],
      ),
    );
  }

  void _confirmarDarDeBaja(String docId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorTarjeta,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¿Dar de baja?", style: GoogleFonts.playfairDisplay(color: colorFuente, fontWeight: FontWeight.bold)),
        content: Text(
          "$nombre será removido del equipo y su cuenta pasará a cliente.",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: GoogleFonts.poppins(color: colorGrisTexto)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojoAlerta,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('usuarios').doc(docId).update({'puesto': 'cliente'});
            },
            child: Text("Dar de baja", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoContratar() {
    final correoCtrl = TextEditingController();
    String rolSeleccionado = 'empleado';
    bool buscando = false;
    String? mensajeError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colorTarjeta,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.person_add, color: colorFuente),
              const SizedBox(width: 10),
              Text("Contratar", style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Correo del usuario registrado", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: correoCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "ejemplo@correo.com",
                  hintStyle: const TextStyle(color: colorGrisTexto),
                  prefixIcon: const Icon(Icons.email_outlined, color: colorFuente, size: 20),
                  filled: true,
                  fillColor: colorInput,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  errorText: mensajeError,
                  errorStyle: const TextStyle(color: colorRojoAlerta, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              Text("Rol a asignar", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _chipRol('empleado', rolSeleccionado, (r) => setDialogState(() => rolSeleccionado = r)),
                  const SizedBox(width: 10),
                  _chipRol('admin', rolSeleccionado, (r) => setDialogState(() => rolSeleccionado = r)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.poppins(color: colorGrisTexto)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorFuente,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: buscando ? null : () async {
                String correo = correoCtrl.text.trim();
                if (correo.isEmpty) {
                  setDialogState(() => mensajeError = "Ingresa un correo");
                  return;
                }
                setDialogState(() { buscando = true; mensajeError = null; });

                try {
                  var query = await FirebaseFirestore.instance
                      .collection('usuarios')
                      .where('correo', isEqualTo: correo)
                      .limit(1)
                      .get();

                  if (query.docs.isEmpty) {
                    setDialogState(() { buscando = false; mensajeError = "Usuario no encontrado"; });
                    return;
                  }

                  await query.docs.first.reference.update({'puesto': rolSeleccionado});
                  AnalyticsService.logEmpleadoContratado(rolSeleccionado);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("¡Contratado como $rolSeleccionado!", style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: colorVerdeExito,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                } catch (e) {
                  setDialogState(() { buscando = false; mensajeError = "Sin permisos. Revisa las reglas de Firestore."; });
                }
              },
              child: buscando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text("Contratar", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipRol(String rol, String seleccionado, Function(String) onTap) {
    bool isSelected = rol == seleccionado;
    return InkWell(
      onTap: () => onTap(rol),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorFuente : colorInput,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          rol.toUpperCase(),
          style: GoogleFonts.poppins(
            color: isSelected ? colorPrincipal : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}