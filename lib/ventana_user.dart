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
        title: Image.asset('assets/Logo_2.png', height: 40),
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
        return carritoCompras();
      case 2:
        return pedidosView();
      default:
        return menuPrincipal();
    }
  }

  Widget menuPrincipal() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        // Título estilo Mockup
        Center(
          child: Text(
            "NUESTRO\nMENÚ",
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: colorFuente,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Buscador
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Buscar platillo...",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: colorFuente),
            filled: true,
            fillColor: Colors.black,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: colorFuente, width: 1.5)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: colorFuente, width: 2)
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Tags/Categorías
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTag("Chilaquiles"),
            _buildTag("Tortas"),
            _buildTag("Especiales"),
          ],
        ),
        const SizedBox(height: 25),

        // Items del Menú rediseñados
        _itemMenu("Chilaquiles Tradicionales", "Salsa roja o verde, pollo, crema y queso.", "85.00", "assets/chilaquiles.jpg"),
        _itemMenu("Torta de Chilaquil", "Bolillo crujiente relleno de sabor.", "65.00", "assets/torta.jpg"),
        _itemMenu("ChilaQueen Especial", "Receta secreta de la casa con extra de todo.", "110.00", "assets/especiales.jpg"),
      ],
    );
  }

  Widget carritoCompras() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              Center(
                child: Text(
                  "CARRITO\nDE COMPRAS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: colorFuente,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Productos en el carrito
              _itemCarrito("Chilaquiles Rojos Naturales", "Salsa de tomate y chiles secos, con crema, queso y cebolla.", "75.00", "assets/chilarojos.jpg"),
              _itemCarrito("Chilaquiles Verdes con pollo", "Salsa de tomate y chiles verdes, con crema, queso, cebolla y pollo.", "75.00", "assets/chilaverdes.jpg"),

              const SizedBox(height: 10),

              // Selectores de Método de Entrega y Pago
              Row(
                children: [
                  Expanded(child: _selectorOpciones("MÉTODO DE ENTREGA", ["Recoger", "Domicilio"])),
                  const SizedBox(width: 10),
                  Expanded(child: _selectorOpciones("MÉTODO DE PAGO", ["Efectivo", "Tarjeta"])),
                ],
              ),
            ],
          ),
        ),

        // Sección de Total y Botón (Fijo abajo)
        _seccionTotal(),
      ],
    );
  }

  Widget pedidosView() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Center(
          child: Text(
            "Mis pedidos",
            style: GoogleFonts.playfairDisplay(
              color: colorFuente,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Lista de pedidos basados en tu mockup
        _itemPedido(
            "Pedido #01",
            "Chilaquiles Rojos Naturales",
            "75.00",
            "assets/chilarojos.jpg",
            "en camino / 5 minutos restantes.",
            Colors.blueAccent
        ),
        _itemPedido(
            "Pedido #02",
            "Chilaquiles Verdes con pollo",
            "75.00",
            "assets/chilaverdes.jpg",
            "Entregado.",
            Colors.green
        ),
        _itemPedido(
            "Pedido #03",
            "Chilaquiles Verdes con pollo",
            "75.00",
            "assets/chilaverdes.jpg",
            "En preparación.",
            Colors.redAccent
        ),
      ],
    );
  }

  Widget _itemPedido(String nroPedido, String nombre, String precio, String rutaImagen, String estado, Color colorEstado) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: colorFuente, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Imagen circular del platillo
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(rutaImagen, width: 85, height: 85, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),

          // Información del pedido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nroPedido, style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(nombre, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text("\$$precio MXN", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Estado del pedido con color dinámico
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(fontSize: 12),
                    children: [
                      const TextSpan(text: "Estado: ", style: TextStyle(color: colorFuente)),
                      TextSpan(text: estado, style: TextStyle(color: colorEstado)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botón circular de "X" (Cerrar/Eliminar)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: colorFuente,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _itemCarrito(String nombre, String desc, String precio, String rutaImagen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: colorFuente, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50), // Imagen circular como en el mockup
            child: Image.asset(rutaImagen, width: 90, height: 90, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11)),
                const SizedBox(height: 8),
                Text("\$$precio MXN", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const Icon(Icons.delete_outline, color: colorFuente, size: 30),
        ],
      ),
    );
  }

  Widget _selectorOpciones(String titulo, List<String> opciones) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: colorFuente, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: GoogleFonts.poppins(color: colorFuente, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ...opciones.map((opt) => Row(
            children: [
              Icon(Icons.radio_button_off, color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Text(opt, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            ],
          )).toList(),
        ],
      ),
    );
  }

  Widget _seccionTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: colorFuente, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SUBTOTAL: \$150", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL: \$150", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colorFuente,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: const Text("REALIZAR COMPRA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: colorFuente, width: 2), // Borde grueso como el mockup
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Imagen Circular
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              rutaImagen,
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              // Fallback por si la imagen no carga
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[900], width: 85, height: 85, child: Icon(Icons.fastfood, color: colorFuente)),
            ),
          ),
          const SizedBox(width: 15),

          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    nombre,
                    style: GoogleFonts.playfairDisplay(
                        color: colorFuente,
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                    )
                ),
                const SizedBox(height: 4),
                Text(
                    desc,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 11)
                ),
                const SizedBox(height: 8),
                Text(
                    "\$$precio MXN",
                    style: GoogleFonts.poppins(
                        color: colorFuente,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                ),
              ],
            ),
          ),

          // Botón de agregar
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, color: colorFuente, size: 30),
          ),
        ],
      ),
    );
  }
}