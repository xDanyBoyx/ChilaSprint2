import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/login.dart';

class MainE extends StatefulWidget {
  const MainE({super.key});

  @override
  State<MainE> createState() => _MainEState();
}

const Color colorPrincipal = Color(0xFF1A1A1A);
const Color colorFuente = Color(0xFFD4AF37);

class _MainEState extends State<MainE> {
  int _indice = 0;

  final List<String> estadosPedido = [
    'Preparando',
    'En espera',
    'Repartiendo',
    'Listo para recibir',
    'Cancelado',
    'Finalizado'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFuente),
        title: Image.asset('assets/logo_2.png', height: 40),
        centerTitle: true,
        elevation: 0,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.admin_panel_settings, color: colorFuente),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: colorPrincipal,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: colorFuente,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: AssetImage('assets/user.png'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("STAFF CHILAQUEEN",
                        style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: colorFuente),
              title: Text("Configuración", style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {},
            ),
            const Divider(color: colorFuente, thickness: 0.1),
            ListTile(
              leading: const Icon(Icons.logout, color: colorFuente),
              title: Text("Cerrar Sesión", style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Chilaqueen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: contenido(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: (pos) => setState(() => _indice = pos),
        backgroundColor: Colors.black,
        selectedItemColor: colorFuente,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "PEDIDOS"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "MÉTRICAS"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "USUARIOS"),
        ],
      ),
    );
  }

  Widget contenido() {
    switch (_indice) {
      case 0:
        return gestionPedidos();
      case 1:
        return const Center(child: Text("Panel de Métricas", style: TextStyle(color: Colors.white)));
      case 2:
        return const Center(child: Text("Gestión de Usuarios", style: TextStyle(color: Colors.white)));
      default:
        return gestionPedidos();
    }
  }

  Widget gestionPedidos() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Buscar por # de pedido o cliente...",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: colorFuente),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "ÓRDENES ACTIVAS",
          style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _itemPedido("001", "Daniel R.", "Chilaquiles Verdes c/ Pollo"),
        _itemPedido("002", "Ana López", "Torta de Chilaquil Roja"),
        _itemPedido("003", "Carlos M.", "Especial ChilaQueen"),
      ],
    );
  }

  Widget _itemPedido(String numPedido, String cliente, String platillo) {
    String estadoActual = 'En espera';

    return Card(
      color: Colors.black,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: colorFuente, width: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("PEDIDO #$numPedido",
                    style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("DETALLES", style: TextStyle(color: colorFuente, fontSize: 12)),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            Text("Cliente: $cliente", style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 5),
            Text("Platillo: $platillo", style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: colorFuente, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: estadoActual,
                  dropdownColor: Colors.black,
                  icon: const Icon(Icons.arrow_drop_down, color: colorFuente),
                  isExpanded: true,
                  style: GoogleFonts.poppins(color: colorFuente, fontSize: 13),
                  items: estadosPedido.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}