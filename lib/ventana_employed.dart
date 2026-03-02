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
        title: Image.asset('assets/Logo_2.png', height: 40),
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
        return metricas();
      case 2:
        return gestionEmpleados();
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

  Widget metricas() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Métricas",
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colorFuente,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                filtroBoton("Hoy"),
                filtroBoton("Semana"),
                filtroBoton("Mes"),
              ],
            ),

            const SizedBox(height: 20),

            metricaCard("Top Producto", "Chilaquiles Verdes"),
            const SizedBox(height: 15),
            metricaCard("Ventas", "\$600,000.00"),

            const SizedBox(height: 25),

            Text(
              "Historial",
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorFuente,
              ),
            ),

            const SizedBox(height: 15),

            historialCard("#01", "Daniel", "Chilaquiles rojos", "10/01/2026"),
            const SizedBox(height: 10),
            historialCard("#02", "Kevin", "Chilaquiles verdes", "12/01/2026"),
          ],
        ),
      ),
    );
  }

  Widget gestionEmpleados() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [

          Text(
            "Empleados",
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorFuente,
            ),
          ),

          const SizedBox(height: 20),

          empleadoCard(
            "Jorge Bayzoni",
            "Administrador",
            "3113436583",
            "jorgebayzoni@ittepic.edu.mx",
          ),

          const SizedBox(height: 15),

          empleadoCard(
            "Daniel Barrera",
            "Jefe",
            "3112356543",
            "danielbarrera@ittepic.edu.mx",
          ),

          const SizedBox(height: 15),

          empleadoCard(
            "Kevin Hernandez",
            "Empleado",
            "3112356543",
            "kevinhernandez@ittepic.edu.mx",
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: colorFuente),
              ),
              child: const Text(
                "CONTRATAR",
                style: TextStyle(
                  color: colorFuente,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filtroBoton(String texto) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
      ),
      child: Text(texto, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget metricaCard(String titulo, String valor) {
    return Card(
      color: colorPrincipal,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: colorFuente),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white70),
        ),
        subtitle: Text(
          valor,
          style: const TextStyle(
            color: colorFuente,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget historialCard(String pedido, String nombre, String producto, String fecha) {
    return Card(
      color: colorPrincipal,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: colorFuente),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.black),
        ),
        title: Text(
          "Pedido $pedido - $nombre",
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          producto,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          fecha,
          style: const TextStyle(color: colorFuente),
        ),
      ),
    );
  }

  Widget empleadoCard(String nombre, String rol, String telefono, String correo) {
    return Card(
      color: colorPrincipal,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: colorFuente),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NOMBRE: $nombre",
                    style: const TextStyle(
                      color: colorFuente,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("ROL: $rol",
                      style: const TextStyle(color: Colors.white)),
                  Text(telefono,
                      style: const TextStyle(color: Colors.white70)),
                  Text(correo,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.cancel, color: Colors.red)
          ],
        ),
      ),
    );
  }
}