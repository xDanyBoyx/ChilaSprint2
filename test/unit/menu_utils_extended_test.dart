import 'package:flutter_test/flutter_test.dart';
import 'package:sprint2_chilaqueen/utils/menu_utils.dart';

void main() {
  // ── productoTieneToppings ─────────────────────────────────────────────────

  group('productoTieneToppings — variantes exactas', () {
    test('"Chilaquiles Rojos" → true', () {
      expect(productoTieneToppings('Chilaquiles Rojos'), isTrue);
    });

    test('"Chilaquiles Verdes" → true', () {
      expect(productoTieneToppings('Chilaquiles Verdes'), isTrue);
    });

    test('"Chilaquiles Divorciados" → true', () {
      expect(productoTieneToppings('Chilaquiles Divorciados'), isTrue);
    });
  });

  group('productoTieneToppings — normalización de entrada', () {
    test('mayúsculas totales → true', () {
      expect(productoTieneToppings('CHILAQUILES ROJOS'), isTrue);
    });

    test('minúsculas totales → true', () {
      expect(productoTieneToppings('chilaquiles verdes'), isTrue);
    });

    test('mezcla de mayúsculas → true', () {
      expect(productoTieneToppings('ChIlAqUiLeS DiVoRcIaDoS'), isTrue);
    });

    test('espacios al inicio y al final → true', () {
      expect(productoTieneToppings('  Chilaquiles Rojos  '), isTrue);
    });
  });

  group('productoTieneToppings — productos sin toppings', () {
    test('"chilaquiles" sin variante → false (no match exacto)', () {
      expect(productoTieneToppings('chilaquiles'), isFalse);
    });

    test('"Chilaquiles Rojos con pollo" → false (texto extra)', () {
      expect(productoTieneToppings('Chilaquiles Rojos con pollo'), isFalse);
    });

    test('Torta de Chilaquiles Rojos → false', () {
      expect(productoTieneToppings('Torta de Chilaquiles Rojos'), isFalse);
    });

    test('Molletes Queen → false', () {
      expect(productoTieneToppings('Molletes Queen'), isFalse);
    });

    test('cadena vacía → false', () {
      expect(productoTieneToppings(''), isFalse);
    });

    test('Café Americano → false', () {
      expect(productoTieneToppings('Café Americano'), isFalse);
    });
  });

  // ── calcularPrecioUnitario ────────────────────────────────────────────────

  group('calcularPrecioUnitario', () {
    test('lista vacía devuelve precio base intacto', () {
      expect(calcularPrecioUnitario(90.0, []), 90.0);
    });

    test('un extra entero incrementa correctamente', () {
      final extras = [
        {'nombre': 'Chorizo', 'precio': 25},
      ];
      expect(calcularPrecioUnitario(85.0, extras), 110.0);
    });

    test('extra con precio double se suma correctamente', () {
      final extras = [
        {'nombre': 'Crema', 'precio': 8.5},
      ];
      expect(calcularPrecioUnitario(85.0, extras), 93.5);
    });

    test('precio base 0 devuelve solo la suma de extras', () {
      final extras = [
        {'nombre': 'A', 'precio': 10},
        {'nombre': 'B', 'precio': 20},
      ];
      expect(calcularPrecioUnitario(0.0, extras), 30.0);
    });

    test('todos los toppings disponibles suman correctamente', () {
      final extras = [
        {'nombre': 'Pollo', 'precio': 20},
        {'nombre': 'Huevo', 'precio': 15},
        {'nombre': 'Arrachera', 'precio': 45},
        {'nombre': 'Chorizo', 'precio': 25},
        {'nombre': 'Aguacate', 'precio': 15},
        {'nombre': 'Queso extra', 'precio': 10},
        {'nombre': 'Crema extra', 'precio': 8},
      ];
      // 85 + 138 = 223
      expect(calcularPrecioUnitario(85.0, extras), 223.0);
    });
  });

  // ── calcularTotal ─────────────────────────────────────────────────────────

  group('calcularTotal', () {
    test('cantidad 1 sin extras devuelve precio base', () {
      expect(calcularTotal(85.0, [], 1), 85.0);
    });

    test('cantidad 2 sin extras duplica el precio', () {
      expect(calcularTotal(85.0, [], 2), 170.0);
    });

    test('cantidad 0 devuelve 0 (pedido vacío)', () {
      expect(calcularTotal(85.0, [], 0), 0.0);
    });

    test('cantidad grande (100) calcula correctamente', () {
      expect(calcularTotal(10.0, [], 100), 1000.0);
    });

    test('extras + cantidad multiplican correctamente', () {
      final extras = [
        {'nombre': 'Arrachera', 'precio': 45},
      ];
      // (50 + 45) × 2 = 190
      expect(calcularTotal(50.0, extras, 2), 190.0);
    });

    test('extra double con cantidad 2', () {
      final extras = [
        {'nombre': 'Crema', 'precio': 8.5},
      ];
      expect(calcularTotal(85.0, extras, 2), (85.0 + 8.5) * 2);
    });
  });
}
