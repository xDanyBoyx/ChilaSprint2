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

              // 👇 ESTA ES LA REGLA PARA OCULTAR LOS EXTRAS 👇
              // Si la categoría de este producto es 'Extras' o 'Extra', lo saltamos.
              if (cat.toLowerCase() == 'extras' || cat.toLowerCase() == 'extra') {
                return false;
              }

              bool coincideBusqueda = nombre.contains(_busqueda);
              // Si está en "Populares", muestra todos (excepto los extras que ya bloqueamos)
              // Si eligió otra categoría, muestra solo los de esa categoría
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

          _itemDrawer(Icons.settings_outlined, "Configuración", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfiguracionScreen()))),
          const Spacer(),
          const Divider(color: colorInput),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              await _auth.signOut();
              // Asegúrate de que Chilaqueen() sea tu pantalla de login/inicio
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