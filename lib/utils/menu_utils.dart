// Funciones puras de lógica de menú — sin dependencia de Firebase ni Flutter.
// Pueden probarse con flutter test directamente.

/// Devuelve true si el producto puede tener toppings.
/// Solo aplica a la categoría Chilaquiles (Rojos, Verdes, Divorciados).
bool productoTieneToppings(String nombre) {
  final n = nombre.toLowerCase().trim();
  return n == 'chilaquiles rojos' ||
      n == 'chilaquiles verdes' ||
      n == 'chilaquiles divorciados';
}

/// Suma el precio de cada extra al precio base.
double calcularPrecioUnitario(
    double precioBase, List<Map<String, dynamic>> extras) {
  double totalExtras = 0;
  for (final extra in extras) {
    totalExtras += (extra['precio'] as num).toDouble();
  }
  return precioBase + totalExtras;
}

/// Calcula el precio total: (precioBase + extras) × cantidad.
double calcularTotal(
    double precioBase, List<Map<String, dynamic>> extras, int cantidad) {
  return calcularPrecioUnitario(precioBase, extras) * cantidad;
}
