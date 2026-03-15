import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sprint2_chilaqueen/login.dart';
import 'package:sprint2_chilaqueen/perfil_screen.dart';
import 'package:sprint2_chilaqueen/configuracion_screen.dart';

class MainU extends StatefulWidget {
  const MainU({super.key});

  @override
  State<MainU> createState() => _MainUState();
}

// Paleta de colores de la marca
const Color colorPrincipal = Color(0xFF1A1A1A);
const Color colorFuente = Color(0xFFD4AF37);
const Color colorTarjeta = Color(0xFF252525);
const Color colorInput = Color(0xFF333333);
const Color colorGrisTexto = Color(0xFFAAAAAA);

class _MainUState extends State<MainU> {
  // --- Variables de Estado ---
  int _indice = 0;
  String _busqueda = "";
  String _categoriaSeleccionada = "🔥 Populares";
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        scrolledUnderElevation: 0,
      ),
      drawer: _crearDrawer(),
      body: _cambiarContenido(),
      bottomNavigationBar: _crearBottomNav(),
    );
  }

  // Lógica para cambiar entre pestañas
  Widget _cambiarContenido() {
    switch (_indice) {
      case 0: return menuPrincipal();
      case 1: return favoritosView();
      case 2: return carritoCompras();
      case 3: return pedidosView();
      default: return menuPrincipal();
    }
  }

  // ==================== VISTA: MENÚ PRINCIPAL ====================
  Widget menuPrincipal() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      children: [
        // Entrega
        _seccionUbicacion(),
        const SizedBox(height: 25),

        Text(
          "¿Qué se te antoja hoy?",
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Barra de Búsqueda
        TextField(
          onChanged: (valor) => setState(() => _busqueda = valor.toLowerCase()),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Buscar platillo...",
            hintStyle: TextStyle(color: colorGrisTexto),
            prefixIcon: const Icon(Icons.search, color: colorFuente),
            filled: true,
            fillColor: colorInput,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 25),

        // Filtros de Categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildTag("🔥 Populares"),
              const SizedBox(width: 10),
              _buildTag("Chilaquiles"),
              const SizedBox(width: 10),
              _buildTag("Tortas"),
              const SizedBox(width: 10),
              _buildTag("Bebidas"),
            ],
          ),
        ),
        const SizedBox(height: 25),

        Text("Platillos", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),

        // --- LISTA DINÁMICA DE FIREBASE ---
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('productos').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: colorFuente));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error al cargar productos", style: TextStyle(color: Colors.white)));
            }

            // Filtrado local para búsqueda y categoría
            var platillos = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String nombre = (data['nombre'] ?? "").toString().toLowerCase();
              String cat = data['categoria'] ?? "";

              bool coincideBusqueda = nombre.contains(_busqueda);
              bool coincideCategoria = _categoriaSeleccionada == "🔥 Populares" || cat == _categoriaSeleccionada;

              return coincideBusqueda && coincideCategoria;
            }).toList();

            if (platillos.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text("No encontramos lo que buscas 🌶️", style: TextStyle(color: colorGrisTexto)),
              ));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: platillos.length,
              itemBuilder: (context, index) {
                var d = platillos[index].data() as Map<String, dynamic>;
                return _itemMenu(
                    d['nombre'] ?? 'Platillo',
                    d['descripcion'] ?? '',
                    (d['precio_base'] ?? d['precio'] ?? '0').toString(), // Soporta ambos nombres de campo
                    d['imagen_url'] ?? '',
                    false // Por ahora favorito en false
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ==================== WIDGETS DE APOYO ====================

  Widget _seccionUbicacion() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: colorTarjeta, shape: BoxShape.circle),
            child: const Icon(Icons.location_on, color: colorFuente, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Entregar en", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                Text("Av. de la Cultura 123, Tepic", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: colorGrisTexto),
        ],
      ),
    );
  }

  Widget _buildTag(String texto) {
    bool isSelected = _categoriaSeleccionada == texto;
    return InkWell(
      onTap: () => setState(() => _categoriaSeleccionada = texto),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? colorFuente : colorTarjeta, borderRadius: BorderRadius.circular(20)),
        child: Text(texto, style: GoogleFonts.poppins(color: isSelected ? colorPrincipal : Colors.white, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _itemMenu(String nombre, String desc, String precio, String url, bool isFavorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: url.startsWith('http')
                ? Image.network(url, width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImagen())
                : _errorImagen(),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11)),
                const SizedBox(height: 8),
                Text("\$$precio MXN", style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(onPressed: () {}, icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: colorFuente, size: 22)),
              IconButton(
                onPressed: () => _mostrarOpcionesPlatillo(context, nombre, precio, url),
                style: IconButton.styleFrom(backgroundColor: colorPrincipal),
                icon: const Icon(Icons.add, color: colorFuente, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorImagen() => Container(color: colorInput, width: 90, height: 90, child: const Icon(Icons.fastfood, color: colorGrisTexto));

  // ==================== DRAWER Y NAV ====================

  Widget _crearDrawer() {
    String nombreUser = _auth.currentUser?.displayName ?? "Usuario ChilaQueen";
    return Drawer(
      backgroundColor: colorPrincipal,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: colorTarjeta),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 35, backgroundColor: colorFuente, child: Icon(Icons.person, size: 40, color: colorPrincipal)),
                  const SizedBox(height: 10),
                  Text(nombreUser.toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ),
          _itemDrawer(Icons.person_outline, "Mi Perfil", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()))),
          _itemDrawer(Icons.location_on_outlined, "Mis Direcciones", () {}),
          _itemDrawer(Icons.settings_outlined, "Configuración", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfiguracionScreen()))),
          const Spacer(),
          const Divider(color: colorInput),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Chilaqueen()), (r) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _itemDrawer(IconData ico, String tit, VoidCallback tap) => ListTile(leading: Icon(ico, color: colorFuente), title: Text(tit, style: const TextStyle(color: Colors.white)), onTap: tap);

  Widget _crearBottomNav() {
    return BottomNavigationBar(
      currentIndex: _indice,
      onTap: (pos) => setState(() => _indice = pos),
      backgroundColor: colorTarjeta,
      selectedItemColor: colorFuente,
      unselectedItemColor: colorGrisTexto,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menú"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favoritos"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "Carrito"),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: "Pedidos"),
      ],
    );
  }

  // ==================== VISTAS RESTANTES (SKETCH) ====================

  Widget favoritosView() => Center(child: Text("Tus Favoritos", style: TextStyle(color: Colors.white)));
  Widget carritoCompras() => Center(child: Text("Carrito de Compras", style: TextStyle(color: Colors.white)));
  Widget pedidosView() => Center(child: Text("Tus Pedidos", style: TextStyle(color: Colors.white)));

  // ==================== MODAL DE PERSONALIZACIÓN ====================

  void _mostrarOpcionesPlatillo(BuildContext context, String nombre, String precio, String imagen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool extraPollo = false;
        bool extraHuevo = false;
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: imagen.startsWith('http')
                      ? Image.network(imagen, height: 180, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 180, color: colorInput),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(nombre, style: GoogleFonts.playfairDisplay(color: colorFuente, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("\$$precio MXN", style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const Divider(color: colorInput, height: 40),
                      Text("Personaliza tu orden", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      CheckboxListTile(
                        title: const Text("Extra Pollo (+\$25)", style: TextStyle(color: Colors.white)),
                        value: extraPollo,
                        activeColor: colorFuente,
                        onChanged: (v) => setModalState(() => extraPollo = v!),
                      ),
                      CheckboxListTile(
                        title: const Text("Extra Huevo (+\$15)", style: TextStyle(color: Colors.white)),
                        value: extraHuevo,
                        activeColor: colorFuente,
                        onChanged: (v) => setModalState(() => extraHuevo = v!),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: colorFuente),
                      child: const Text("Agregar al Carrito", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }
}