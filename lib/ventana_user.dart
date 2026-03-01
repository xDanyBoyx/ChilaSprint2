import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint2_chilaqueen/login.dart';

class MainU extends StatefulWidget {
  const MainU({super.key});

  @override
  State<MainU> createState() => _MainUState();
}

const Color colorPrincipal = Color(0xFF1A1A1A);
const Color colorFuente = Color(0xFFD4AF37);

class _MainUState extends State<MainU> {
  int _indice = 0;

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
                    Text("BIENVENIDO", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold)),
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
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "MENÚ"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "CARRITO"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "PEDIDOS"),
        ],
      ),
    );
  }

  Widget contenido() {
    switch (_indice) {
      case 0:
        return menuPrincipal();
      case 1:
        return const Center(child: Text("Carrito vacío", style: TextStyle(color: Colors.white)));
      case 2:
        return const Center(child: Text("Sin pedidos recientes", style: TextStyle(color: Colors.white)));
      default:
        return menuPrincipal();
    }
  }

  Widget menuPrincipal() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Buscar platillo...",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: colorFuente),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: colorFuente)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTag("Chilaquiles"),
            _buildTag("Tortas"),
            _buildTag("Especiales"),
          ],
        ),
        const SizedBox(height: 20),
        _itemMenu("Chilaquiles Tradicionales", "Salsa roja o verde, pollo, crema y queso.", "85.00", "assets/chilaquiles.jpg"),
        _itemMenu("Torta de Chilaquil", "Bolillo crujiente relleno de sabor.", "65.00", "assets/torta.jpg"),
        _itemMenu("ChilaQueen Especial", "Receta secreta de la casa con extra de todo.", "110.00", "assets/especiales.jpg"),
      ],
    );
  }

  Widget _buildTag(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: colorFuente),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(texto, style: GoogleFonts.poppins(color: colorFuente, fontSize: 12)),
    );
  }

  Widget _itemMenu(String nombre, String desc, String precio, String rutaImagen) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: colorFuente, width: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Ahora usa la variable rutaImagen en lugar de un texto fijo
              child: Image.asset(rutaImagen, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(desc, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text("\$$precio", style: const TextStyle(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_shopping_cart, color: colorFuente),
            ),
          ],
        ),
      ),
    );
  }
}