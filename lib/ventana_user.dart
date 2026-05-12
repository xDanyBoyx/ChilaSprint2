import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sprint2_chilaqueen/login.dart';
import 'package:sprint2_chilaqueen/perfil_screen.dart';
import 'package:sprint2_chilaqueen/configuracion_screen.dart';
import 'package:sprint2_chilaqueen/metodos_pago_screen.dart';

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

  // Conjunto de IDs de productos favoritos del usuario (en vivo)
  Set<String> _favoritos = {};
  StreamSubscription<QuerySnapshot>? _subFavoritos;

  @override
  void initState() {
    super.initState();
    _suscribirFavoritos();
  }

  @override
  void dispose() {
    _subFavoritos?.cancel();
    super.dispose();
  }

  void _suscribirFavoritos() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _subFavoritos = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .snapshots()
        .listen(
      (snap) {
        if (!mounted) return;
        setState(() => _favoritos = snap.docs.map((d) => d.id).toSet());
      },
      onError: (_) {
        // Tras signOut Firestore emite permission-denied. Lo absorbemos
        // para que no propague como error sin manejar.
      },
      cancelOnError: true,
    );
  }

  Future<void> _cerrarSesion() async {
    // 1) Cerramos el drawer si está abierto para evitar overlays atorados
    final nav = Navigator.of(context, rootNavigator: true);
    if (Navigator.canPop(context)) Navigator.pop(context);

    // 2) Cancelamos listeners antes de cerrar sesión (evita errores de
    //    permission-denied que congelan el isolate al perder el token).
    await _subFavoritos?.cancel();
    _subFavoritos = null;

    // 3) Cerramos sesión y navegamos al login limpiando el stack
    try {
      await _auth.signOut();
    } catch (_) {}

    if (!mounted) return;
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Chilaqueen()),
      (r) => false,
    );
  }

  Future<void> _toggleFavorito(String productoId, Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .doc(productoId);
    if (_favoritos.contains(productoId)) {
      await ref.delete();
    } else {
      await ref.set({
        'nombre': data['nombre'] ?? '',
        'descripcion': data['descripcion'] ?? '',
        'precio_base': data['precio_base'] ?? data['precio'] ?? 0,
        'imagen_url': data['imagen_url'] ?? '',
        'categoria': data['categoria'] ?? '',
        'agregado_en': FieldValue.serverTimestamp(),
      });
    }
  }

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

        // --- LISTA + FILTROS DINÁMICOS DESDE FIREBASE ---
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('productos').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: colorFuente));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error al cargar productos", style: TextStyle(color: Colors.white)));
            }

            final todos = snapshot.data?.docs ?? [];

            // 1) Ocultamos extras y productos no disponibles del listado del cliente
            final visibles = todos.where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final cat = (d['categoria'] ?? '').toString().toLowerCase();
              final disponible = d['disponible'] != false; // por defecto disponible
              if (!disponible) return false;
              if (cat == 'extra' || cat == 'extras') return false;
              return true;
            }).toList();

            // 2) Construimos las categorías dinámicamente
            final Set<String> categoriasSet = {};
            for (final doc in visibles) {
              final d = doc.data() as Map<String, dynamic>;
              final cat = (d['categoria'] ?? '').toString().trim();
              if (cat.isNotEmpty) categoriasSet.add(cat.toLowerCase());
            }
            final List<String> categorias = ["🔥 Populares", ...categoriasSet];

            // 3) Aplicamos filtro por categoría seleccionada + búsqueda
            final platillos = visibles.where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final nombre = (d['nombre'] ?? '').toString().toLowerCase();
              final cat = (d['categoria'] ?? '').toString().toLowerCase().trim();
              final bool coincideBusqueda = nombre.contains(_busqueda);
              final bool coincideCategoria = _categoriaSeleccionada == "🔥 Populares" ||
                  cat == _categoriaSeleccionada.toLowerCase();
              return coincideBusqueda && coincideCategoria;
            }).toList();

            return Column(
              children: [
                // Filtros (scroll horizontal)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categorias.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _buildTag(categorias[i]),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Platillos", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 15),

                if (platillos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text("No encontramos lo que buscas 🌶️",
                        style: GoogleFonts.poppins(color: colorGrisTexto)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: platillos.length,
                    itemBuilder: (context, index) {
                      final docId = platillos[index].id;
                      final d = platillos[index].data() as Map<String, dynamic>;
                      return _itemMenu(docId, d);
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _labelCategoria(String cat) {
    if (cat.startsWith("🔥")) return cat;
    return cat.isEmpty ? cat : "${cat[0].toUpperCase()}${cat.substring(1)}";
  }

  // ==================== WIDGETS DE APOYO ====================

  Widget _seccionUbicacion() {
    String? uid = _auth.currentUser?.uid;

    return InkWell(
      onTap: () {
        _mostrarModalDirecciones(context);
      },
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

                // 👇 MAGIA DE FIREBASE EN TIEMPO REAL (STREAMBUILDER) 👇
                uid == null
                    ? Text("Dirección desconocida", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
                    : StreamBuilder<QuerySnapshot>(
                  // Escuchamos los cambios EN VIVO con .snapshots()
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .collection('direcciones')
                      .where('predeterminada', isEqualTo: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Buscando dirección...", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14));
                    }

                    // Si no hay datos o la subcolección está vacía
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text("Agrega una dirección", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14));
                    }

                    // Extraemos el primer documento de dirección
                    var dirData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

                    String calle = dirData['calle'] ?? '';
                    String numExt = dirData['num_ext'] ?? '';
                    String colonia = dirData['colonia'] ?? '';

                    // Armamos la dirección final
                    String direccionFinal = "$calle $numExt, $colonia".trim();

                    return Text(
                      direccionFinal.isNotEmpty ? direccionFinal : "Dirección incompleta",
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
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
        child: Text(
          _labelCategoria(texto),
          style: GoogleFonts.poppins(
            color: isSelected ? colorPrincipal : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _itemMenu(String productoId, Map<String, dynamic> d) {
    final String nombre = d['nombre'] ?? 'Platillo';
    final String desc = d['descripcion'] ?? '';
    final String precio = (d['precio_base'] ?? d['precio'] ?? '0').toString();
    final String url = d['imagen_url'] ?? '';
    final bool isFavorite = _favoritos.contains(productoId);

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
              IconButton(
                onPressed: () => _toggleFavorito(productoId, d),
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: colorFuente, size: 22),
              ),
              IconButton(
                onPressed: () => _mostrarOpcionesPlatillo(context, productoId, nombre, precio, url),
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

  // ==================== DRAWER Y NAV ====================
  Widget _crearDrawer() {
    String? uid = _auth.currentUser?.uid;

    return Drawer(
      backgroundColor: colorPrincipal,
      child: Column(
        children: [
          // 👇 STREAMBUILDER PARA EL PERFIL EN TIEMPO REAL 👇
          StreamBuilder<DocumentSnapshot>(
              stream: uid != null
                  ? FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots()
                  : const Stream.empty(),
              builder: (context, snapshot) {
                // Valores por defecto mientras carga
                String nombreUser = _auth.currentUser?.displayName ?? "Usuario ChilaQueen";
                String urlImagen = "";

                // Si ya cargó y el documento existe, tomamos los datos reales
                if (snapshot.hasData && snapshot.data!.exists) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  nombreUser = userData['nombre'] ?? nombreUser;
                  urlImagen = userData['imagen_perfil'] ?? "";
                }

                return DrawerHeader(
                  decoration: const BoxDecoration(color: colorTarjeta),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: colorFuente,
                          // Si hay URL, la mostramos. Si no, o si hay error, no ponemos imagen de fondo
                          backgroundImage: urlImagen.isNotEmpty ? NetworkImage(urlImagen) : null,
                          // Si no hay URL, mostramos el ícono de persona por defecto
                          child: urlImagen.isEmpty
                              ? const Icon(Icons.person, size: 40, color: colorPrincipal)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                            nombreUser.toUpperCase(),
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                      ],
                    ),
                  ),
                );
              }
          ),

          _itemDrawer(Icons.person_outline, "Mi Perfil", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()))),

          // 👇 REGALITO: Conectamos este botón a tu nuevo modal de direcciones 👇
          _itemDrawer(Icons.location_on_outlined, "Mis Direcciones", () {
            Navigator.pop(context); // Primero cerramos el Drawer
            _mostrarModalDirecciones(context); // Luego abrimos tu modal Pro
          }),

          _itemDrawer(Icons.credit_card_outlined, "Métodos de Pago", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MetodosPagoScreen()));
          }),

          _itemDrawer(Icons.settings_outlined, "Configuración", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfiguracionScreen()))),
          const Spacer(),
          const Divider(color: colorInput),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent)),
            onTap: () => _cerrarSesion(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _itemDrawer(IconData ico, String tit, VoidCallback tap) => ListTile(leading: Icon(ico, color: colorFuente), title: Text(tit, style: const TextStyle(color: Colors.white)), onTap: tap);

  Widget _crearBottomNav() {
    final uid = _auth.currentUser?.uid;
    final carritoStream = uid != null
        ? FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('carrito').snapshots()
        : const Stream<QuerySnapshot>.empty();

    return StreamBuilder<QuerySnapshot>(
      stream: carritoStream,
      builder: (context, snapshot) {
        final int countCarrito = snapshot.data?.docs.length ?? 0;

        Widget iconoCarrito = const Icon(Icons.shopping_cart_outlined);
        if (countCarrito > 0) {
          iconoCarrito = Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined),
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: colorFuente, borderRadius: BorderRadius.circular(10)),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    "$countCarrito",
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        return BottomNavigationBar(
          currentIndex: _indice,
          onTap: (pos) => setState(() => _indice = pos),
          backgroundColor: colorTarjeta,
          selectedItemColor: colorFuente,
          unselectedItemColor: colorGrisTexto,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menú"),
            const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favoritos"),
            BottomNavigationBarItem(icon: iconoCarrito, label: "Carrito"),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: "Pedidos"),
          ],
        );
      },
    );
  }

  // ==================== VISTA: FAVORITOS ====================
  Widget favoritosView() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return _vistaVacia(Icons.favorite_border, "Inicia sesión para ver tus favoritos");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('favoritos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: colorFuente));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _vistaVacia(Icons.favorite_border, "Aún no tienes favoritos\nDale 🤍 a tus platillos preferidos");
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          children: [
            Text("Tus Favoritos", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final productoId = doc.id;
              return _itemMenu(productoId, data);
            }),
          ],
        );
      },
    );
  }

  // ==================== VISTA: CARRITO ====================
  Widget carritoCompras() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return _vistaVacia(Icons.shopping_cart_outlined, "Inicia sesión para ver tu carrito");

    final carritoRef = FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('carrito');

    return StreamBuilder<QuerySnapshot>(
      stream: carritoRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: colorFuente));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _vistaVacia(Icons.shopping_cart_outlined, "Tu carrito está vacío\nAgrega platillos desde el menú");
        }

        double total = 0;
        for (final doc in docs) {
          final d = doc.data() as Map<String, dynamic>;
          total += (d['precio_total'] ?? 0).toDouble();
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                children: [
                  Text("Tu Carrito", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ...docs.map((doc) => _itemCarrito(doc.id, doc.data() as Map<String, dynamic>, carritoRef)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: colorTarjeta,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                      Text("\$${total.toStringAsFixed(2)} MXN",
                          style: GoogleFonts.poppins(color: colorFuente, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirCheckout(docs, total),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorFuente,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, color: Colors.black),
                      label: Text("Continuar al Pago", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _itemCarrito(String itemId, Map<String, dynamic> d, CollectionReference carritoRef) {
    final List extras = d['extras'] ?? [];
    final int cantidad = (d['cantidad'] ?? 1).toInt();
    final double precioUnitario = (d['precio_unitario'] ?? 0).toDouble();
    final double precioTotal = precioUnitario * cantidad;
    final String nota = d['nota'] ?? '';
    final String url = d['imagen_url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colorTarjeta, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url.startsWith('http')
                ? Image.network(url, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImagen())
                : Container(color: colorInput, width: 70, height: 70, child: const Icon(Icons.fastfood, color: colorGrisTexto)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d['nombre'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                if (extras.isNotEmpty)
                  Text("+ ${extras.map((e) => e['nombre']).join(', ')}",
                      style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 11)),
                if (nota.isNotEmpty)
                  Text("Nota: $nota", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11, fontStyle: FontStyle.italic)),
                const SizedBox(height: 6),
                Text("\$${precioTotal.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => carritoRef.doc(itemId).delete(),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (cantidad > 1) {
                        carritoRef.doc(itemId).update({
                          'cantidad': cantidad - 1,
                          'precio_total': precioUnitario * (cantidad - 1),
                        });
                      } else {
                        carritoRef.doc(itemId).delete();
                      }
                    },
                    child: const Icon(Icons.remove_circle_outline, color: colorFuente, size: 22),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text("$cantidad", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  InkWell(
                    onTap: () => carritoRef.doc(itemId).update({
                      'cantidad': cantidad + 1,
                      'precio_total': precioUnitario * (cantidad + 1),
                    }),
                    child: const Icon(Icons.add_circle_outline, color: colorFuente, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MODAL DE CHECKOUT (Método de pago + Dirección) ====================
  void _abrirCheckout(List<QueryDocumentSnapshot> items, double total) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        // Map { tipo: 'efectivo' | 'tarjeta', tarjetaId?: ..., marca?, ultimos_4? }
        Map<String, dynamic> metodoSel = {'tipo': 'efectivo'};
        bool procesando = false;

        return StatefulBuilder(builder: (ctx, setS) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            decoration: const BoxDecoration(
                color: colorTarjeta,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: colorGrisTexto.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 14),
                Text("Confirmar Pedido",
                    style: GoogleFonts.playfairDisplay(
                        color: colorFuente, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("${items.length} ${items.length == 1 ? 'producto' : 'productos'} • \$${total.toStringAsFixed(2)} MXN",
                    style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
                const Divider(color: colorInput, height: 28),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // === DIRECCIÓN DE ENTREGA ===
                      Row(children: [
                        const Icon(Icons.location_on, color: colorFuente, size: 20),
                        const SizedBox(width: 8),
                        Text("Entregar en",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      ]),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(uid)
                            .collection('direcciones')
                            .where('predeterminada', isEqualTo: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData || snap.data!.docs.isEmpty) {
                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _mostrarModalDirecciones(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: colorInput,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))),
                                child: Row(children: [
                                  const Icon(Icons.add_location_alt, color: Colors.redAccent),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text("Agrega una dirección de entrega",
                                        style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13)),
                                  ),
                                ]),
                              ),
                            );
                          }
                          final dir = snap.data!.docs.first.data() as Map<String, dynamic>;
                          final calle = "${dir['calle'] ?? ''} ${dir['num_ext'] ?? ''}".trim();
                          final colonia = (dir['colonia'] ?? '').toString();
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: colorInput, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              const Icon(Icons.home_outlined, color: colorFuente),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(dir['etiqueta'] ?? 'Dirección',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    Text("$calle, $colonia",
                                        style: GoogleFonts.poppins(
                                            color: colorGrisTexto, fontSize: 11)),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _mostrarModalDirecciones(context);
                                },
                                child: Text("Cambiar",
                                    style: GoogleFonts.poppins(
                                        color: colorFuente, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // === MÉTODO DE PAGO ===
                      Row(children: [
                        const Icon(Icons.payment, color: colorFuente, size: 20),
                        const SizedBox(width: 8),
                        Text("Método de pago",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MetodosPagoScreen())),
                          icon: const Icon(Icons.add, color: colorFuente, size: 16),
                          label: Text("Agregar",
                              style: GoogleFonts.poppins(
                                  color: colorFuente, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 8),

                      // Efectivo
                      _filaMetodo(
                        seleccionado: metodoSel['tipo'] == 'efectivo',
                        icono: Icons.payments_outlined,
                        titulo: "Efectivo",
                        subtitulo: "Pago contra entrega",
                        onTap: () => setS(() => metodoSel = {'tipo': 'efectivo'}),
                      ),
                      // Tarjetas guardadas
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(uid)
                            .collection('metodos_pago')
                            .snapshots(),
                        builder: (context, snap) {
                          final docs = snap.data?.docs ?? [];
                          return Column(
                            children: docs.map((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              final id = doc.id;
                              final marca = d['marca'] ?? 'Tarjeta';
                              final last4 = d['ultimos_4'] ?? '----';
                              final esSel = metodoSel['tipo'] == 'tarjeta' && metodoSel['tarjetaId'] == id;
                              return _filaMetodo(
                                seleccionado: esSel,
                                icono: Icons.credit_card,
                                titulo: "$marca •••• $last4",
                                subtitulo: (d['alias'] ?? '').toString().isNotEmpty
                                    ? d['alias']
                                    : "Vence ${d['vencimiento'] ?? '--/--'}",
                                onTap: () => setS(() => metodoSel = {
                                      'tipo': 'tarjeta',
                                      'tarjetaId': id,
                                      'marca': marca,
                                      'ultimos_4': last4,
                                    }),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // === RESUMEN ===
                      Row(children: [
                        const Icon(Icons.receipt_long_outlined, color: colorFuente, size: 20),
                        const SizedBox(width: 8),
                        Text("Resumen",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      ]),
                      const SizedBox(height: 8),
                      ...items.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        final int cant = (d['cantidad'] ?? 1).toInt();
                        final double pt = ((d['precio_unitario'] ?? 0) as num).toDouble() * cant;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Expanded(
                                child: Text("${cant}x ${d['nombre'] ?? ''}",
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
                            Text("\$${pt.toStringAsFixed(2)}",
                                style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 13)),
                          ]),
                        );
                      }),
                      const Divider(color: colorInput, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("\$${total.toStringAsFixed(2)} MXN",
                              style: GoogleFonts.poppins(
                                  color: colorFuente, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: procesando
                          ? null
                          : () async {
                              setS(() => procesando = true);
                              final ok = await _confirmarPedido(items, total, metodoSel);
                              if (!ctx.mounted) return;
                              setS(() => procesando = false);
                              if (ok) Navigator.pop(ctx);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorFuente,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: procesando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text("Pagar \$${total.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _filaMetodo({
    required bool seleccionado,
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado ? colorFuente.withValues(alpha: 0.12) : colorInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: seleccionado ? colorFuente : Colors.transparent, width: 1.5),
        ),
        child: Row(children: [
          Icon(icono, color: seleccionado ? colorFuente : colorGrisTexto),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitulo,
                    style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11)),
              ],
            ),
          ),
          Icon(
            seleccionado ? Icons.radio_button_checked : Icons.radio_button_off,
            color: seleccionado ? colorFuente : colorGrisTexto,
          ),
        ]),
      ),
    );
  }

  Future<bool> _confirmarPedido(
      List<QueryDocumentSnapshot> items, double total, Map<String, dynamic> metodoPago) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    // Datos del usuario
    String nombreCliente = _auth.currentUser?.displayName ?? 'Cliente';
    String telefono = '';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      if (userDoc.exists) {
        final ud = userDoc.data() ?? {};
        nombreCliente = (ud['nombre'] ?? nombreCliente).toString();
        telefono = (ud['telefono'] ?? '').toString();
      }
    } catch (_) {}

    // Dirección predeterminada
    Map<String, dynamic>? direccion;
    try {
      final dirSnap = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('direcciones')
          .where('predeterminada', isEqualTo: true)
          .limit(1)
          .get();
      if (dirSnap.docs.isNotEmpty) {
        direccion = dirSnap.docs.first.data();
      }
    } catch (_) {}

    if (direccion == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Agrega una dirección de entrega antes de continuar"),
            backgroundColor: Colors.orange),
      );
      return false;
    }

    // Tiempo estimado desde config
    String tiempoEstimado = "15-25 min";
    try {
      final cfg =
          await FirebaseFirestore.instance.collection('config').doc('sucursal').get();
      if (cfg.exists) {
        tiempoEstimado = (cfg.data()?['nivel_demanda'] ?? tiempoEstimado).toString();
      }
    } catch (_) {}

    final batch = FirebaseFirestore.instance.batch();
    final pedidosRef = FirebaseFirestore.instance.collection('pedidos');

    // Resumen del método de pago para guardarlo en cada pedido
    final Map<String, dynamic> metodoResumen = metodoPago['tipo'] == 'efectivo'
        ? {'tipo': 'efectivo', 'etiqueta': 'Efectivo'}
        : {
            'tipo': 'tarjeta',
            'etiqueta':
                "${metodoPago['marca'] ?? 'Tarjeta'} •••• ${metodoPago['ultimos_4'] ?? '----'}",
            'tarjeta_id': metodoPago['tarjetaId'],
          };

    for (final doc in items) {
      final d = doc.data() as Map<String, dynamic>;
      final int cantidad = (d['cantidad'] ?? 1).toInt();
      final List extras = d['extras'] ?? [];
      final List<String> notas = [];
      for (final e in extras) {
        notas.add("+${e['nombre']} (+\$${e['precio']})");
      }
      if ((d['nota'] ?? '').toString().isNotEmpty) {
        notas.add("Ojo: ${d['nota']}");
      }
      if (cantidad > 1) {
        notas.add("Cantidad: $cantidad");
      }

      final nuevoPedido = pedidosRef.doc();
      batch.set(nuevoPedido, {
        'cliente_uid': uid,
        'cliente_nombre': nombreCliente,
        'cliente_telefono': telefono,
        'platillo': d['nombre'] ?? '',
        'imagen_url': d['imagen_url'] ?? '',
        'notas': notas,
        'cantidad': cantidad,
        'precio_unitario': d['precio_unitario'] ?? 0,
        'precio_total': ((d['precio_unitario'] ?? 0) as num).toDouble() * cantidad,
        'estadoActual': 'Nuevo',
        'tiempoEstimado': tiempoEstimado,
        'fecha': FieldValue.serverTimestamp(),
        'metodo_pago': metodoResumen,
        'direccion_entrega': {
          'etiqueta': direccion['etiqueta'] ?? '',
          'calle': direccion['calle'] ?? '',
          'num_ext': direccion['num_ext'] ?? '',
          'num_int': direccion['num_int'] ?? '',
          'colonia': direccion['colonia'] ?? '',
          'referencias': direccion['referencias'] ?? '',
        },
      });

      batch.delete(doc.reference);
    }

    try {
      await batch.commit();
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("¡Pedido confirmado! Total: \$${total.toStringAsFixed(2)} 🎉"),
            backgroundColor: Colors.green),
      );
      setState(() => _indice = 3);
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al confirmar: $e"), backgroundColor: Colors.redAccent),
      );
      return false;
    }
  }

  // ==================== VISTA: PEDIDOS DEL CLIENTE ====================
  Widget pedidosView() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return _vistaVacia(Icons.receipt_long_outlined, "Inicia sesión para ver tus pedidos");

    const List<String> activos = ['Nuevo', 'Preparando', 'En camino', 'Listo para recoger'];
    const List<String> historial = ['Entregado', 'Cancelado'];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .where('cliente_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: colorFuente));
        }
        if (snapshot.hasError) {
          return _vistaVacia(Icons.error_outline, "Error al cargar pedidos");
        }
        final docs = snapshot.data?.docs ?? [];
        docs.sort((a, b) {
          final fa = (a.data() as Map<String, dynamic>)['fecha'];
          final fb = (b.data() as Map<String, dynamic>)['fecha'];
          if (fa == null && fb == null) return 0;
          if (fa == null) return 1;
          if (fb == null) return -1;
          return (fb as Timestamp).compareTo(fa as Timestamp);
        });

        final pedidosActivos = docs.where((d) {
          final estado = (d.data() as Map<String, dynamic>)['estadoActual'] ?? '';
          return activos.contains(estado);
        }).toList();

        final pedidosHistorial = docs.where((d) {
          final estado = (d.data() as Map<String, dynamic>)['estadoActual'] ?? '';
          return historial.contains(estado);
        }).toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Tus Pedidos",
                      style: GoogleFonts.playfairDisplay(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              TabBar(
                indicatorColor: colorFuente,
                indicatorWeight: 3,
                labelColor: colorFuente,
                unselectedLabelColor: colorGrisTexto,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: "🔥 ACTIVOS (${pedidosActivos.length})"),
                  Tab(text: "📋 HISTORIAL (${pedidosHistorial.length})"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _listaPedidos(pedidosActivos, "Aún no tienes pedidos en curso"),
                    _listaPedidos(pedidosHistorial, "Sin pedidos completados aún"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _listaPedidos(List<QueryDocumentSnapshot> docs, String mensajeVacio) {
    if (docs.isEmpty) {
      return _vistaVacia(Icons.receipt_long_outlined, mensajeVacio);
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      children: docs.map((doc) => _itemPedido(doc.id, doc.data() as Map<String, dynamic>)).toList(),
    );
  }

  Widget _itemPedido(String id, Map<String, dynamic> d) {
    final String estado = d['estadoActual'] ?? 'Nuevo';
    final List notas = d['notas'] ?? [];
    final double precioTotal = (d['precio_total'] ?? 0).toDouble();
    final fecha = d['fecha'];
    final String tiempoEstimado = (d['tiempoEstimado'] ?? '').toString();
    final Map<String, dynamic>? metodo =
        d['metodo_pago'] is Map ? Map<String, dynamic>.from(d['metodo_pago']) : null;
    final Map<String, dynamic>? dirEntrega =
        d['direccion_entrega'] is Map ? Map<String, dynamic>.from(d['direccion_entrega']) : null;

    String fechaStr = '';
    if (fecha is Timestamp) {
      final dt = fecha.toDate();
      fechaStr =
          "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    Color colorEstado;
    IconData iconEstado;
    switch (estado) {
      case 'Entregado':
        colorEstado = Colors.greenAccent;
        iconEstado = Icons.check_circle;
        break;
      case 'Cancelado':
        colorEstado = Colors.redAccent;
        iconEstado = Icons.cancel;
        break;
      case 'En camino':
        colorEstado = Colors.blueAccent;
        iconEstado = Icons.delivery_dining;
        break;
      case 'Listo para recoger':
        colorEstado = Colors.orangeAccent;
        iconEstado = Icons.shopping_bag;
        break;
      case 'Preparando':
        colorEstado = colorFuente;
        iconEstado = Icons.restaurant;
        break;
      default:
        colorEstado = colorGrisTexto;
        iconEstado = Icons.fiber_new;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorEstado.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#${id.substring(0, 6).toUpperCase()}",
                  style: GoogleFonts.poppins(color: colorFuente, fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(iconEstado, color: colorEstado, size: 14),
                  const SizedBox(width: 6),
                  Text(estado,
                      style: GoogleFonts.poppins(
                          color: colorEstado, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(d['platillo'] ?? '',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          if (notas.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...notas.map((n) {
              final txt = n.toString();
              Color c = colorGrisTexto;
              if (txt.startsWith('+')) c = Colors.greenAccent;
              if (txt.startsWith('Ojo:')) c = colorFuente;
              return Text(txt, style: GoogleFonts.poppins(color: c, fontSize: 12));
            }),
          ],
          if (tiempoEstimado.isNotEmpty &&
              estado != 'Entregado' &&
              estado != 'Cancelado') ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.timer_outlined, color: colorFuente, size: 14),
              const SizedBox(width: 6),
              Text("ETA: $tiempoEstimado",
                  style:
                      GoogleFonts.poppins(color: colorFuente, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ],
          if (metodo != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(metodo['tipo'] == 'efectivo' ? Icons.payments_outlined : Icons.credit_card,
                  color: colorGrisTexto, size: 14),
              const SizedBox(width: 6),
              Text(metodo['etiqueta'] ?? '',
                  style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11)),
            ]),
          ],
          if (dirEntrega != null && (dirEntrega['calle'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, color: colorGrisTexto, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    "${dirEntrega['calle']} ${dirEntrega['num_ext'] ?? ''}, ${dirEntrega['colonia'] ?? ''}",
                    style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ],
          const Divider(color: colorInput, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fechaStr, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11)),
              Text("\$${precioTotal.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                      color: colorFuente, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vistaVacia(IconData icono, String texto) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: colorGrisTexto, size: 70),
          const SizedBox(height: 16),
          Text(texto, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 14)),
        ],
      ),
    );
  }

  // ==================== MODAL DE PERSONALIZACIÓN ====================

  void _mostrarOpcionesPlatillo(BuildContext context, String productoId, String nombre, String precio, String imagen) {
    // Extras disponibles. Si quieres más adelante los puedes leer de Firestore.
    final List<Map<String, dynamic>> extrasDisponibles = [
      {'nombre': 'Pollo', 'precio': 25},
      {'nombre': 'Huevo', 'precio': 15},
    ];

    final double precioBase = double.tryParse(precio) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctxModal) {
        final Set<int> extrasSeleccionados = {};
        int cantidad = 1;
        final TextEditingController notaCtrl = TextEditingController();

        return StatefulBuilder(builder: (ctxModal, setModalState) {
          double totalExtras = 0;
          for (final i in extrasSeleccionados) {
            totalExtras += (extrasDisponibles[i]['precio'] as num).toDouble();
          }
          final double precioUnitario = precioBase + totalExtras;
          final double total = precioUnitario * cantidad;

          return Container(
            height: MediaQuery.of(ctxModal).size.height * 0.8,
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
                      const SizedBox(height: 8),
                      ...extrasDisponibles.asMap().entries.map((e) {
                        final i = e.key;
                        final extra = e.value;
                        return CheckboxListTile(
                          title: Text("Extra ${extra['nombre']} (+\$${extra['precio']})", style: const TextStyle(color: Colors.white)),
                          value: extrasSeleccionados.contains(i),
                          activeColor: colorFuente,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setModalState(() {
                            if (v == true) {
                              extrasSeleccionados.add(i);
                            } else {
                              extrasSeleccionados.remove(i);
                            }
                          }),
                        );
                      }),
                      const SizedBox(height: 10),
                      Text("Notas especiales", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notaCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Ej. sin cebolla, salsa aparte...",
                          hintStyle: const TextStyle(color: colorGrisTexto, fontSize: 13),
                          filled: true,
                          fillColor: colorInput,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cantidad", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: cantidad > 1 ? () => setModalState(() => cantidad--) : null,
                                icon: const Icon(Icons.remove_circle_outline, color: colorFuente),
                              ),
                              Text("$cantidad", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: () => setModalState(() => cantidad++),
                                icon: const Icon(Icons.add_circle_outline, color: colorFuente),
                              ),
                            ],
                          ),
                        ],
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
                      onPressed: () async {
                        final uid = _auth.currentUser?.uid;
                        if (uid == null) {
                          ScaffoldMessenger.of(ctxModal).showSnackBar(
                            const SnackBar(content: Text("Debes iniciar sesión"), backgroundColor: Colors.redAccent),
                          );
                          return;
                        }
                        final extras = extrasSeleccionados
                            .map((i) => {
                                  'nombre': extrasDisponibles[i]['nombre'],
                                  'precio': extrasDisponibles[i]['precio'],
                                })
                            .toList();

                        await FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(uid)
                            .collection('carrito')
                            .add({
                          'producto_id': productoId,
                          'nombre': nombre,
                          'imagen_url': imagen,
                          'precio_base': precioBase,
                          'extras': extras,
                          'precio_unitario': precioUnitario,
                          'cantidad': cantidad,
                          'precio_total': total,
                          'nota': notaCtrl.text.trim(),
                          'agregado_en': FieldValue.serverTimestamp(),
                        });

                        if (!ctxModal.mounted) return;
                        Navigator.pop(ctxModal);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$nombre agregado al carrito 🛒"), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: colorFuente),
                      child: Text(
                        "Agregar al Carrito • \$${total.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
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

  // ==================== MODAL DE LISTA DE DIRECCIONES ====================
  void _mostrarModalDirecciones(BuildContext context) {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    showModalBottomSheet(
        context: context,
        backgroundColor: colorTarjeta,
        isScrollControlled: true, // Permite que se ajuste al contenido
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Se adapta al tamaño de la lista
              children: [
                Text("Mis Direcciones 📍", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // 👇 LISTA DE DIRECCIONES EN TIEMPO REAL 👇
                Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('direcciones').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: colorFuente));
                          }

                          var docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("Aún no tienes direcciones guardadas.", style: GoogleFonts.poppins(color: colorGrisTexto)),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true, // Para que no marque error dentro del Column
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              var data = docs[index].data() as Map<String, dynamic>;
                              String docId = docs[index].id;
                              bool esPredeterminada = data['predeterminada'] == true;

                              String etiqueta = data['etiqueta'] ?? 'Dirección';
                              String calle = data['calle'] ?? '';
                              String numExt = data['num_ext'] ?? '';
                              String colonia = data['colonia'] ?? '';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: esPredeterminada ? colorFuente.withOpacity(0.1) : colorInput,
                                  borderRadius: BorderRadius.circular(15),
                                  border: esPredeterminada ? Border.all(color: colorFuente, width: 1.5) : null,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                      esPredeterminada ? Icons.location_on : Icons.location_on_outlined,
                                      color: esPredeterminada ? colorFuente : colorGrisTexto
                                  ),
                                  title: Text(etiqueta, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text("$calle $numExt, $colonia", style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 12)),
                                  trailing: esPredeterminada ? const Icon(Icons.check_circle, color: colorFuente) : null,
                                  onTap: () async {
                                    // Al tocarla, la hacemos principal y cerramos el modal
                                    Navigator.pop(context);
                                    await _cambiarDireccionPredeterminada(uid, docId);
                                  },
                                ),
                              );
                            },
                          );
                        }
                    )
                ),
                const SizedBox(height: 15),

                // 👇 BOTÓN PARA AGREGAR NUEVA 👇
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorFuente,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: Text("Agregar nueva dirección", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Cerramos este modal y abrimos el formulario
                    Navigator.pop(context);
                    _mostrarDialogoNuevaDireccion(context);
                  },
                )
              ],
            ),
          );
        }
    );
  }

// ==================== MODAL PARA AGREGAR DIRECCIÓN (VERSIÓN PRO) ====================
  void _mostrarDialogoNuevaDireccion(BuildContext context) {
    // Controladores para todos los campos de tu base de datos
    final TextEditingController etiquetaCtrl = TextEditingController(); // Valor por defecto
    final TextEditingController calleCtrl = TextEditingController();
    final TextEditingController numExtCtrl = TextEditingController();
    final TextEditingController numIntCtrl = TextEditingController();
    final TextEditingController coloniaCtrl = TextEditingController();
    final TextEditingController referenciasCtrl = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          bool guardando = false;
          bool predeterminada = true; // Por defecto la marcamos como principal

          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  backgroundColor: colorTarjeta,
                  surfaceTintColor: Colors.transparent, // Evita tintes raros en Android
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Icon(Icons.add_location_alt, color: colorFuente),
                      const SizedBox(width: 10),
                      Text("Nueva Dirección", style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9, // Para que no quede tan angosto
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Etiqueta (Casa, Trabajo, etc.)
                          _inputDireccion(etiquetaCtrl, "Etiqueta (Ej. Casa, Trabajo)", Icons.label_outline),
                          const SizedBox(height: 15),

                          // 2. Calle
                          _inputDireccion(calleCtrl, "Calle", Icons.signpost_outlined),
                          const SizedBox(height: 15),

                          // 3. Números (Exterior e Interior)
                          Row(
                            children: [
                              Expanded(child: _inputDireccion(numExtCtrl, "Núm. Ext", null, esNumero: true)),
                              const SizedBox(width: 15),
                              Expanded(child: _inputDireccion(numIntCtrl, "Núm. Int (Opcional)", null)),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // 4. Colonia
                          _inputDireccion(coloniaCtrl, "Colonia", Icons.holiday_village_outlined),
                          const SizedBox(height: 15),

                          // 5. Referencias
                          TextField(
                            controller: referenciasCtrl,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "Referencias (Ej. Casa roja con portón blanco, frente al parque...)",
                              hintStyle: const TextStyle(color: colorGrisTexto, fontSize: 13),
                              filled: true,
                              fillColor: colorInput,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // 6. Switch de Predeterminada
                          SwitchListTile(
                            title: Text("Marcar como predeterminada", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                            value: predeterminada,
                            activeColor: colorFuente,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setStateDialog(() => predeterminada = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar", style: TextStyle(color: colorGrisTexto)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorFuente,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: guardando ? null : () async {
                        // Validación básica
                        if (calleCtrl.text.isEmpty || numExtCtrl.text.isEmpty || coloniaCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Calle, Núm Ext y Colonia son obligatorios ⚠️"), backgroundColor: Colors.orange),
                          );
                          return;
                        }

                        setStateDialog(() => guardando = true);

                        String? uid = _auth.currentUser?.uid;
                        if (uid != null) {
                          // Si esta será la predeterminada, podríamos necesitar apagar las otras (opcional, por ahora solo guardamos)
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(uid)
                              .collection('direcciones')
                              .add({
                            'etiqueta': etiquetaCtrl.text.trim(),
                            'calle': calleCtrl.text.trim(),
                            'num_ext': numExtCtrl.text.trim(),
                            'num_int': numIntCtrl.text.trim(),
                            'colonia': coloniaCtrl.text.trim(),
                            'referencias': referenciasCtrl.text.trim(),
                            'predeterminada': predeterminada,
                          });
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dirección guardada con éxito 📍"), backgroundColor: Colors.green),
                        );
                      },
                      child: guardando
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text("Guardar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  // Widget auxiliar para no repetir tanto código en el modal
  Widget _inputDireccion(TextEditingController controlador, String hint, IconData? icono, {bool esNumero = false}) {
    return TextField(
      controller: controlador,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: colorGrisTexto, fontSize: 13),
        prefixIcon: icono != null ? Icon(icono, color: colorFuente, size: 20) : null,
        filled: true,
        fillColor: colorInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  // ==================== FUNCIÓN PARA CAMBIAR DIRECCIÓN PRINCIPAL ====================
  Future<void> _cambiarDireccionPredeterminada(String uid, String nuevaDirId) async {
    // 1. Obtenemos todas las direcciones del usuario
    var snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('direcciones')
        .get();

    // 2. Usamos un "Batch" para actualizar varias cosas al mismo tiempo
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      if (doc.id == nuevaDirId) {
        // A la que el usuario tocó, la hacemos predeterminada
        batch.update(doc.reference, {'predeterminada': true});
      } else if (doc.data()['predeterminada'] == true) {
        // A las demás que estuvieran como predeterminadas, se lo quitamos
        batch.update(doc.reference, {'predeterminada': false});
      }
    }

    // 3. Ejecutamos los cambios
    await batch.commit();
  }


}