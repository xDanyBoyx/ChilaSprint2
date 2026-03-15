import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/login.dart';

class MainE extends StatefulWidget {
  const MainE({super.key});

  @override
  State<MainE> createState() => _MainEState();
}

class _MainEState extends State<MainE> {
  int _indice = 0;

  // Paleta de colores Premium
  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorTarjeta = Color(0xFF252525);
  static const Color colorInput = Color(0xFF333333);
  static const Color colorFuente = Color(0xFFD4AF37);
  static const Color colorGrisTexto = Color(0xFFAAAAAA);
  static const Color colorVerdeExito = Color(0xFF4CAF50);
  static const Color colorRojoAlerta = Color(0xFFF44336);

  final List<String> estadosPedido = ['Nuevo', 'Preparando', 'En camino', 'Listo para recoger'];

  // ==================== DATOS DE SUCURSAL ====================
  bool sucursalAbierta = true;
  String nivelDemanda = "Normal (15-25 min)";
  final List<String> opcionesDemanda = ["Baja (10-15 min)", "Normal (15-25 min)", "Alta (30-45 min)", "Saturada (+50 min)"];

  // ==================== DATOS DE STOCK ====================
  List<Map<String, dynamic>> stockPlatillos = [
    {"nombre": "Chilaquiles Verdes", "activo": true},
    {"nombre": "Chilaquiles Rojos", "activo": true},
    {"nombre": "Torta de Chilaquil", "activo": true},
    {"nombre": "Especial ChilaQueen", "activo": false},
  ];

  List<Map<String, dynamic>> stockExtras = [
    {"nombre": "Pollo Deshebrado", "activo": true},
    {"nombre": "Milanesa de Pollo", "activo": true},
    {"nombre": "Huevo Estrellado", "activo": true},
    {"nombre": "Arrachera", "activo": false},
  ];

  // ==================== DATOS DE PEDIDOS ====================
  List<Map<String, dynamic>> pedidosActivos = [
    {
      "id": "PED-1042", "cliente": "Daniel Barrera", "fecha": "15 Mar 2026", "hora": "15:20",
      "platillo": "Chilaquiles Verdes", "notas": ["+ Huevo Estrellado", "+ Extra Queso", "- Sin Cebolla"],
      "estadoActual": "Preparando", "tiempoEstimado": "15 min",
    },
    {
      "id": "PED-1043", "cliente": "Ana López", "fecha": "15 Mar 2026", "hora": "15:25",
      "platillo": "Torta de Chilaquil Roja", "notas": ["+ Milanesa de Pollo", "Ojo: Salsa aparte por favor"],
      "estadoActual": "Nuevo", "tiempoEstimado": "Sin asignar",
    },
  ];

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
                "Admin ChilaQueen",
                style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            accountEmail: Text(
                "matriz@chilaqueen.com",
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
            onTap: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Chilaqueen()), (route) => false);
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
    return ListView(
      physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(20),
      children: [
        Text("Gestión de Sucursal", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text("Controla la operación general de ChilaQueen matriz.", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)), const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: sucursalAbierta ? colorTarjeta : colorRojoAlerta.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: sucursalAbierta ? colorFuente.withOpacity(0.3) : colorRojoAlerta.withOpacity(0.5), width: 1.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Icon(sucursalAbierta ? Icons.storefront : Icons.store_outlined, color: sucursalAbierta ? colorVerdeExito : colorRojoAlerta, size: 28), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("ESTADO ACTUAL", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)), Text(sucursalAbierta ? "Abierto" : "Cerrado temporalmente", style: GoogleFonts.poppins(color: sucursalAbierta ? colorVerdeExito : colorRojoAlerta, fontSize: 18, fontWeight: FontWeight.bold))])]),
                  Switch(value: sucursalAbierta, onChanged: (valor) { setState(() { sucursalAbierta = valor; }); }, activeColor: colorPrincipal, activeTrackColor: colorVerdeExito, inactiveThumbColor: colorGrisTexto, inactiveTrackColor: colorInput),
                ],
              ),
              const SizedBox(height: 12), Text(sucursalAbierta ? "La sucursal está recibiendo pedidos con normalidad." : "Los clientes no pueden hacer pedidos en este momento. La app mostrará que están cerrados.", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 24), Text("TRÁFICO EN COCINA", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: nivelDemanda, dropdownColor: colorTarjeta, icon: const Icon(Icons.expand_more, color: colorFuente), isExpanded: true, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), items: opcionesDemanda.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (String? newValue) { if (newValue != null) { setState(() { nivelDemanda = newValue; }); } })),
        ),
        const Padding(padding: EdgeInsets.only(top: 8, left: 8), child: Text("Este tiempo se mostrará como 'Tiempo Estimado' global en la app del cliente.", style: TextStyle(color: colorGrisTexto, fontSize: 11))), const SizedBox(height: 30), Text("INFORMACIÓN", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [_filaInfoSucursal(Icons.location_on_outlined, "Dirección", "Av. Insurgentes Sur 1234, CDMX"), const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: colorInput, height: 1)), _filaInfoSucursal(Icons.access_time, "Horario de Hoy", "08:00 AM - 04:00 PM"), const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: colorInput, height: 1)), _filaInfoSucursal(Icons.phone_outlined, "Teléfono Contacto", "55 1234 5678")]),
        ),
      ],
    );
  }

  Widget _filaInfoSucursal(IconData icono, String titulo, String valor) { return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icono, color: colorFuente, size: 20), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)), Text(valor, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))]))]); }

  // ==================== RESTO DEL CÓDIGO (FINANZAS, TICKETS, STOCK) ====================
  Widget _moduloFinanzas() { return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(20), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Resumen del Día", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 28, fontWeight: FontWeight.bold)), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: colorInput, borderRadius: BorderRadius.circular(20)), child: Text("15 Mar 2026", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12, fontWeight: FontWeight.bold)))]), const SizedBox(height: 30), Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: [colorTarjeta, colorInput.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), border: Border.all(color: colorFuente.withOpacity(0.3))), child: Column(children: [Text("INGRESOS TOTALES", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)), const SizedBox(height: 8), Text("\$4,250.00", style: GoogleFonts.poppins(color: colorVerdeExito, fontSize: 40, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.trending_up, color: colorVerdeExito, size: 16), const SizedBox(width: 4), Text("+12.5% vs ayer", style: GoogleFonts.poppins(color: colorVerdeExito, fontSize: 12))])])), const SizedBox(height: 16), Row(children: [Expanded(child: _tarjetaMetrica(icono: Icons.receipt_long, titulo: "PEDIDOS", valor: "32", colorIcono: colorFuente)), const SizedBox(width: 16), Expanded(child: _tarjetaMetrica(icono: Icons.payments_outlined, titulo: "TICKET PROM.", valor: "\$132.80", colorIcono: Colors.white))]), const SizedBox(height: 40), Row(children: [const Icon(Icons.star, color: colorFuente, size: 20), const SizedBox(width: 10), Text("TOP MÁS VENDIDOS", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1))]), const SizedBox(height: 20), _barraVentas(platillo: "Chilaquiles Verdes", ventas: 15, porcentaje: 0.8), _barraVentas(platillo: "Torta de Chilaquil", ventas: 9, porcentaje: 0.5), _barraVentas(platillo: "Chilaquiles Rojos", ventas: 5, porcentaje: 0.3), _barraVentas(platillo: "Especial ChilaQueen", ventas: 3, porcentaje: 0.15)]); }
  Widget _tarjetaMetrica({required IconData icono, required String titulo, required String valor, required Color colorIcono}) { return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icono, color: colorIcono, size: 18), const SizedBox(width: 8), Text(titulo, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))]), const SizedBox(height: 12), Text(valor, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))])); }
  Widget _barraVentas({required String platillo, required int ventas, required double porcentaje}) { return Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(platillo, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)), Text("$ventas ord.", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12))]), const SizedBox(height: 8), Stack(children: [Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: colorInput, borderRadius: BorderRadius.circular(4))), FractionallySizedBox(widthFactor: porcentaje, child: Container(height: 8, decoration: BoxDecoration(color: colorFuente, borderRadius: BorderRadius.circular(4))))])])); }

  Widget _moduloTickets() { return DefaultTabController(length: 2, child: Column(children: [Container(color: colorPrincipal, child: TabBar(indicatorColor: colorFuente, indicatorWeight: 3, labelColor: colorFuente, unselectedLabelColor: colorGrisTexto, labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14), tabs: [Tab(text: "🔥 ACTIVOS (${pedidosActivos.length})"), const Tab(text: "📋 HISTORIAL")])), Expanded(child: TabBarView(children: [_listaPedidosActivos(), _listaPedidosHistorial()]))])); }
  Widget _listaPedidosActivos() { return ListView.builder(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(16), itemCount: pedidosActivos.length, itemBuilder: (context, index) { final pedido = pedidosActivos[index]; return _ticketCocina(index: index, id: pedido["id"], cliente: pedido["cliente"], fecha: pedido["fecha"], hora: pedido["hora"], platillo: pedido["platillo"], notas: List<String>.from(pedido["notas"]), estadoActual: pedido["estadoActual"], tiempoEstimado: pedido["tiempoEstimado"]); }); }
  Widget _ticketCocina({required int index, required String id, required String cliente, required String fecha, required String hora, required String platillo, required List<String> notas, required String estadoActual, required String tiempoEstimado}) { String valorDropdown = estadosPedido.contains(estadoActual) ? estadoActual : estadosPedido.first; return Container(margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16), border: Border.all(color: estadoActual == 'Nuevo' ? colorFuente : Colors.transparent, width: 1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: const BoxDecoration(color: colorInput, borderRadius: BorderRadius.vertical(top: Radius.circular(15))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("#$id", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)), Row(children: [const Icon(Icons.calendar_today, color: colorGrisTexto, size: 14), const SizedBox(width: 4), Text("$fecha • $hora", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12))])])), Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.person, color: colorGrisTexto, size: 18), const SizedBox(width: 8), Text(cliente, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))]), const SizedBox(height: 16), Text("1x $platillo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...notas.map((nota) { Color colorNota = colorGrisTexto; if (nota.startsWith('+')) colorNota = colorVerdeExito; if (nota.startsWith('-')) colorNota = colorRojoAlerta; if (nota.startsWith('Ojo:')) colorNota = colorFuente; return Padding(padding: const EdgeInsets.only(left: 16, bottom: 4), child: Text(nota, style: GoogleFonts.poppins(color: colorNota, fontSize: 13, fontWeight: FontWeight.w500))); }), const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: colorInput, height: 1)), Row(children: [Expanded(flex: 3, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: colorInput, borderRadius: BorderRadius.circular(8)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: valorDropdown, dropdownColor: colorTarjeta, icon: const Icon(Icons.keyboard_arrow_down, color: colorFuente), isExpanded: true, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), items: estadosPedido.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (String? newValue) { if (newValue != null) { setState(() { pedidosActivos[index]["estadoActual"] = newValue; }); } })))), const SizedBox(width: 12), Expanded(flex: 2, child: InkWell(onTap: () => _mostrarModalTiempo(context, index, id), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border.all(color: colorFuente.withOpacity(0.5)), borderRadius: BorderRadius.circular(8), color: tiempoEstimado != "Sin asignar" ? colorFuente.withOpacity(0.1) : Colors.transparent), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.timer_outlined, color: tiempoEstimado != "Sin asignar" ? colorFuente : colorGrisTexto, size: 16), const SizedBox(width: 4), Text(tiempoEstimado, style: GoogleFonts.poppins(color: tiempoEstimado != "Sin asignar" ? colorFuente : colorGrisTexto, fontSize: 12, fontWeight: FontWeight.bold))]))))])]))])); }
  void _mostrarModalTiempo(BuildContext context, int indexPedido, String idPedido) { List<String> opcionesTiempo = ["5 min", "10 min", "15 min", "20 min", "30 min", "45 min"]; String tiempoSeleccionadoTemporal = pedidosActivos[indexPedido]["tiempoEstimado"]; showModalBottomSheet(context: context, backgroundColor: colorTarjeta, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (BuildContext modalContext) { return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) { return Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colorGrisTexto.withOpacity(0.3), borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 20), Text("Asignar ETA", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 24, fontWeight: FontWeight.bold)), Text("Pedido #$idPedido", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14)), const SizedBox(height: 24), Wrap(spacing: 12, runSpacing: 12, children: opcionesTiempo.map((tiempo) { bool estaSeleccionado = tiempoSeleccionadoTemporal == tiempo; return InkWell(onTap: () { setModalState(() { tiempoSeleccionadoTemporal = tiempo; }); }, child: Container(width: (MediaQuery.of(context).size.width - 72) / 3, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: estaSeleccionado ? colorFuente : colorInput, borderRadius: BorderRadius.circular(12), border: Border.all(color: estaSeleccionado ? colorFuente : Colors.transparent)), child: Center(child: Text(tiempo, style: GoogleFonts.poppins(color: estaSeleccionado ? colorPrincipal : Colors.white, fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.normal))))); }).toList()), const SizedBox(height: 30), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: colorVerdeExito, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () { setState(() { pedidosActivos[indexPedido]["tiempoEstimado"] = tiempoSeleccionadoTemporal; }); Navigator.pop(context); }, child: Text("Confirmar Tiempo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))))])); }); }); }
  Widget _listaPedidosHistorial() { return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(16), children: [_ticketHistorial("PED-1040", "Carlos M.", "Entregado", "14:30"), _ticketHistorial("PED-1041", "Jorge B.", "Cancelado", "14:45")]); }
  Widget _ticketHistorial(String id, String cliente, String estado, String hora) { bool esCancelado = estado == "Cancelado"; return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(12)), child: ListTile(leading: CircleAvatar(backgroundColor: esCancelado ? colorRojoAlerta.withOpacity(0.2) : colorVerdeExito.withOpacity(0.2), child: Icon(esCancelado ? Icons.close : Icons.check, color: esCancelado ? colorRojoAlerta : colorVerdeExito, size: 20)), title: Text("#$id • $cliente", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), subtitle: Text(estado, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)), trailing: Text(hora, style: GoogleFonts.poppins(color: colorFuente, fontSize: 12)))); }

  Widget _moduloStock() { return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(20), children: [Text("Control de Menú", style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text("Apaga los ingredientes o platillos que se hayan agotado.", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)), const SizedBox(height: 30), Row(children: [const Icon(Icons.restaurant_menu, color: colorFuente, size: 20), const SizedBox(width: 10), Text("PLATILLOS BASE", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1))]), const SizedBox(height: 15), ...List.generate(stockPlatillos.length, (index) { return _itemStock(nombre: stockPlatillos[index]["nombre"], activo: stockPlatillos[index]["activo"], alCambiar: (valor) { setState(() { stockPlatillos[index]["activo"] = valor; }); }); }), const SizedBox(height: 30), Row(children: [const Icon(Icons.egg_alt_outlined, color: colorFuente, size: 20), const SizedBox(width: 10), Text("PROTEÍNAS Y EXTRAS", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1))]), const SizedBox(height: 15), ...List.generate(stockExtras.length, (index) { return _itemStock(nombre: stockExtras[index]["nombre"], activo: stockExtras[index]["activo"], alCambiar: (valor) { setState(() { stockExtras[index]["activo"] = valor; }); }); })]); }
  Widget _itemStock({required String nombre, required bool activo, required Function(bool) alCambiar}) { return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16), border: Border.all(color: activo ? Colors.transparent : colorRojoAlerta.withOpacity(0.5), width: 1)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: activo ? colorVerdeExito : colorRojoAlerta)), const SizedBox(width: 16), Text(nombre, style: GoogleFonts.poppins(color: activo ? Colors.white : colorGrisTexto, fontSize: 15, fontWeight: FontWeight.w600, decoration: activo ? TextDecoration.none : TextDecoration.lineThrough))]), Switch(value: activo, onChanged: alCambiar, activeColor: colorPrincipal, activeTrackColor: colorFuente, inactiveThumbColor: colorGrisTexto, inactiveTrackColor: colorInput)])); }
}