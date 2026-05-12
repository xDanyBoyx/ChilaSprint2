import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const Color colorPrincipal = Color(0xFF1A1A1A);
  static const Color colorInput = Color(0xFF333333);
  static const Color colorFuente = Color(0xFFD4AF37);
  static const Color colorGrisTexto = Color(0xFFAAAAAA);

  final _auth = FirebaseAuth.instance;
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  String _urlImagen = "";

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _cargando = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        _nombreCtrl.text = data['nombre'] ?? '';
        _correoCtrl.text = data['correo'] ?? _auth.currentUser?.email ?? '';
        _telefonoCtrl.text = data['telefono'] ?? '';
        _urlImagen = data['imagen_perfil'] ?? '';
      } else {
        _correoCtrl.text = _auth.currentUser?.email ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _guardarPerfil() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre no puede estar vacío"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': _nombreCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        // correo no lo actualizamos aquí porque requiere reautenticación en Firebase Auth
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado 👑"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // Normaliza URLs típicas que NO sirven como imagen directa.
  // Drive: https://drive.google.com/file/d/<ID>/view → https://drive.google.com/uc?export=view&id=<ID>
  // Imgur: https://imgur.com/<ID> → https://i.imgur.com/<ID>.jpg
  String _normalizarUrlImagen(String url) {
    url = url.trim();
    if (url.isEmpty) return url;

    // Google Drive (file/d/<ID>/...)
    final drive = RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (drive != null) {
      return 'https://drive.google.com/uc?export=view&id=${drive.group(1)}';
    }
    // Drive open?id=
    final driveOpen = RegExp(r'drive\.google\.com/open\?id=([a-zA-Z0-9_-]+)').firstMatch(url);
    if (driveOpen != null) {
      return 'https://drive.google.com/uc?export=view&id=${driveOpen.group(1)}';
    }
    // Imgur página → imagen directa (asume .jpg)
    final imgurPage = RegExp(r'^https?://imgur\.com/([a-zA-Z0-9]+)$').firstMatch(url);
    if (imgurPage != null) {
      return 'https://i.imgur.com/${imgurPage.group(1)}.jpg';
    }
    return url;
  }

  Future<void> _editarFotoPerfil() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ctrl = TextEditingController(text: _urlImagen);

    final urlNueva = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String urlPreview = ctrl.text.trim();
        bool urlCarga = false;
        bool urlError = false;

        return StatefulBuilder(builder: (ctx, setS) {
          void evaluar(String texto) {
            final normal = _normalizarUrlImagen(texto);
            setS(() {
              urlPreview = normal;
              urlCarga = normal.isNotEmpty;
              urlError = false;
            });
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF252525),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(children: const [
              Icon(Icons.camera_alt, color: colorFuente),
              SizedBox(width: 10),
              Text("Foto de Perfil", style: TextStyle(color: Colors.white)),
            ]),
            content: SizedBox(
              width: MediaQuery.of(ctx).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Pega la URL DIRECTA de una imagen (terminada en .jpg, .png, .webp). Si pegas un link de Google Drive o Imgur lo convertimos automáticamente.",
                      style: TextStyle(color: colorGrisTexto.withValues(alpha: 0.9), fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: ctrl,
                      style: const TextStyle(color: Colors.white),
                      onChanged: evaluar,
                      decoration: InputDecoration(
                        hintText: "https://...",
                        hintStyle: const TextStyle(color: colorGrisTexto),
                        prefixIcon: const Icon(Icons.link, color: colorFuente),
                        filled: true,
                        fillColor: colorInput,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Preview
                    if (urlPreview.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorInput,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                urlPreview,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, p) {
                                  if (p == null) {
                                    if (!urlCarga) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (ctx.mounted) setS(() => urlCarga = true);
                                      });
                                    }
                                    return child;
                                  }
                                  return const SizedBox(
                                    width: 100, height: 100,
                                    child: Center(child: CircularProgressIndicator(color: colorFuente, strokeWidth: 2)),
                                  );
                                },
                                errorBuilder: (_, __, ___) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (ctx.mounted) setS(() => urlError = true);
                                  });
                                  return Container(
                                    width: 100, height: 100,
                                    color: Colors.redAccent.withValues(alpha: 0.15),
                                    child: const Icon(Icons.broken_image, color: Colors.redAccent, size: 40),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (urlError)
                              Text("No pudimos cargar esta imagen",
                                  style: TextStyle(color: Colors.redAccent, fontSize: 11),
                                  textAlign: TextAlign.center)
                            else if (urlCarga)
                              Text("✓ Imagen válida",
                                  style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              if (_urlImagen.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, ''),
                  child: const Text("Quitar foto", style: TextStyle(color: Colors.redAccent)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar", style: TextStyle(color: colorGrisTexto)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: urlError ? Colors.grey : colorFuente,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: urlError
                    ? null
                    : () => Navigator.pop(ctx, _normalizarUrlImagen(ctrl.text)),
                child: const Text("Guardar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );

    if (urlNueva == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set({'imagen_perfil': urlNueva}, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _urlImagen = urlNueva);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(urlNueva.isEmpty ? "Foto eliminada" : "Foto actualizada 📸"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: colorFuente),
        title: Text("Mi Perfil", style: GoogleFonts.playfairDisplay(color: colorFuente, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: colorFuente))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _editarFotoPerfil,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: colorFuente,
                            backgroundImage: _urlImagen.isNotEmpty ? NetworkImage(_urlImagen) : null,
                            onBackgroundImageError: _urlImagen.isNotEmpty ? (_, __) {} : null,
                            child: _urlImagen.isEmpty
                                ? const Icon(Icons.person, size: 50, color: colorPrincipal)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: colorFuente, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Toca la foto para cambiarla",
                      style: GoogleFonts.poppins(color: colorGrisTexto, fontSize: 11)),
                  const SizedBox(height: 30),
                  _campoPerfil("Nombre Completo", _nombreCtrl, Icons.person_outline),
                  const SizedBox(height: 20),
                  _campoPerfil("Correo Electrónico", _correoCtrl, Icons.email_outlined, readOnly: true),
                  const SizedBox(height: 20),
                  _campoPerfil("Teléfono", _telefonoCtrl, Icons.phone_iphone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardarPerfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorFuente,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _guardando
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text("GUARDAR CAMBIOS",
                              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _campoPerfil(String label, TextEditingController ctrl, IconData icono,
      {bool readOnly = false, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(color: readOnly ? colorGrisTexto : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: colorGrisTexto),
        prefixIcon: Icon(icono, color: colorFuente),
        filled: true,
        fillColor: colorInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
