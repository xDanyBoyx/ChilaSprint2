import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _colorPrincipal = Color(0xFF1A1A1A);
const Color _colorTarjeta = Color(0xFF252525);
const Color _colorInput = Color(0xFF333333);
const Color _colorFuente = Color(0xFFD4AF37);
const Color _colorGrisTexto = Color(0xFFAAAAAA);

class MetodosPagoScreen extends StatelessWidget {
  const MetodosPagoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _colorPrincipal,
      appBar: AppBar(
        backgroundColor: _colorPrincipal,
        iconTheme: const IconThemeData(color: _colorFuente),
        title: Text("Métodos de Pago",
            style: GoogleFonts.playfairDisplay(color: _colorFuente, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _colorFuente,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text("Agregar tarjeta",
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () => _mostrarDialogoTarjeta(context),
      ),
      body: uid == null
          ? Center(child: Text("Inicia sesión", style: GoogleFonts.poppins(color: _colorGrisTexto)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                // Efectivo siempre disponible
                _tile(
                  icono: Icons.payments_outlined,
                  titulo: "Efectivo",
                  subtitulo: "Pago contra entrega",
                  permanente: true,
                ),
                const SizedBox(height: 20),
                Text("Tarjetas guardadas",
                    style: GoogleFonts.poppins(
                        color: _colorFuente, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .collection('metodos_pago')
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(color: _colorFuente)),
                      );
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text("Aún no tienes tarjetas guardadas",
                            style: GoogleFonts.poppins(color: _colorGrisTexto, fontSize: 13)),
                      );
                    }
                    return Column(
                      children: docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return _tile(
                          icono: _iconoMarca(d['marca'] ?? ''),
                          titulo: "${d['marca'] ?? 'Tarjeta'} •••• ${d['ultimos_4'] ?? '----'}",
                          subtitulo: (d['alias'] ?? '').toString().isNotEmpty
                              ? d['alias']
                              : "Vence ${d['vencimiento'] ?? '--/--'}",
                          docId: doc.id,
                          context: context,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }

  IconData _iconoMarca(String marca) {
    final m = marca.toLowerCase();
    if (m.contains('visa')) return Icons.credit_card;
    if (m.contains('master')) return Icons.credit_card;
    if (m.contains('amex')) return Icons.credit_card;
    return Icons.credit_card_outlined;
  }

  Widget _tile({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    bool permanente = false,
    String? docId,
    BuildContext? context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: _colorTarjeta, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _colorFuente.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icono, color: _colorFuente),
        ),
        title: Text(titulo,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitulo, style: GoogleFonts.poppins(color: _colorGrisTexto, fontSize: 12)),
        trailing: permanente
            ? const Icon(Icons.lock_outline, color: _colorGrisTexto, size: 18)
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null || docId == null) return;
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .collection('metodos_pago')
                      .doc(docId)
                      .delete();
                },
              ),
      ),
    );
  }

  void _mostrarDialogoTarjeta(BuildContext context) {
    final numeroCtrl = TextEditingController();
    final vencCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    final aliasCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool guardando = false;
        return StatefulBuilder(builder: (context, setS) {
          return AlertDialog(
            backgroundColor: _colorTarjeta,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(children: [
              const Icon(Icons.credit_card, color: _colorFuente),
              const SizedBox(width: 10),
              Text("Nueva Tarjeta",
                  style: GoogleFonts.playfairDisplay(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ]),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _input(numeroCtrl, "Número de tarjeta", Icons.credit_card,
                        keyboard: TextInputType.number, maxLen: 19, formatters: [_FormatoTarjeta()]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: _input(vencCtrl, "MM/AA", Icons.calendar_month,
                            keyboard: TextInputType.number,
                            maxLen: 5,
                            formatters: [_FormatoFecha()]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _input(cvvCtrl, "CVV", Icons.lock_outline,
                            keyboard: TextInputType.number, maxLen: 4, obscure: true),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _input(aliasCtrl, "Alias (Ej. Personal, Empresa)", Icons.label_outline),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancelar", style: TextStyle(color: _colorGrisTexto)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorFuente,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: guardando
                    ? null
                    : () async {
                        final numero = numeroCtrl.text.replaceAll(' ', '');
                        if (numero.length < 13) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Número de tarjeta inválido"),
                              backgroundColor: Colors.orange));
                          return;
                        }
                        if (vencCtrl.text.length != 5) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Vencimiento inválido (MM/AA)"),
                              backgroundColor: Colors.orange));
                          return;
                        }
                        if (cvvCtrl.text.length < 3) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("CVV inválido"), backgroundColor: Colors.orange));
                          return;
                        }
                        setS(() => guardando = true);

                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(uid)
                              .collection('metodos_pago')
                              .add({
                            'marca': _detectarMarca(numero),
                            'ultimos_4': numero.substring(numero.length - 4),
                            'vencimiento': vencCtrl.text,
                            'alias': aliasCtrl.text.trim(),
                            'agregada_en': FieldValue.serverTimestamp(),
                            // NOTA: no se guarda el número completo ni CVV por seguridad
                          });
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Tarjeta guardada 💳"),
                            backgroundColor: Colors.green));
                      },
                child: guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text("Guardar",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  String _detectarMarca(String numero) {
    if (numero.startsWith('4')) return 'Visa';
    if (numero.startsWith('5')) return 'MasterCard';
    if (numero.startsWith('3')) return 'Amex';
    return 'Tarjeta';
  }

  Widget _input(TextEditingController c, String hint, IconData icono,
      {TextInputType keyboard = TextInputType.text,
      int? maxLen,
      List<TextInputFormatter>? formatters,
      bool obscure = false}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLength: maxLen,
      inputFormatters: formatters,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _colorGrisTexto, fontSize: 13),
        prefixIcon: Icon(icono, color: _colorFuente, size: 20),
        filled: true,
        fillColor: _colorInput,
        counterText: '',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

// Inserta espacios cada 4 dígitos: "1234 5678 9012 3456"
class _FormatoTarjeta extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    final solo = newV.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < solo.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(solo[i]);
    }
    return TextEditingValue(
      text: buf.toString(),
      selection: TextSelection.collapsed(offset: buf.length),
    );
  }
}

// Formato MM/AA
class _FormatoFecha extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    final solo = newV.text.replaceAll(RegExp(r'\D'), '');
    String out = solo;
    if (solo.length >= 3) out = '${solo.substring(0, 2)}/${solo.substring(2, solo.length.clamp(2, 4))}';
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}
