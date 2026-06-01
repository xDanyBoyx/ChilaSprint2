import 'package:flutter_test/flutter_test.dart';
import 'package:sprint2_chilaqueen/utils/validators.dart';
import 'package:sprint2_chilaqueen/utils/menu_utils.dart';

void main() {
  // ==================== VALIDACIÓN DE CORREO ====================
  group('validarCorreo', () {
    test('correo vacío devuelve error obligatorio', () {
      expect(validarCorreo(''), 'El correo es obligatorio');
    });

    test('correo sin @ devuelve error de formato', () {
      expect(validarCorreo('noescorreo'), 'Formato de correo inválido');
    });

    test('correo sin dominio devuelve error de formato', () {
      expect(validarCorreo('usuario@'), 'Formato de correo inválido');
    });

    test('correo sin extensión devuelve error de formato', () {
      expect(validarCorreo('usuario@dominio'), 'Formato de correo inválido');
    });

    test('correo válido devuelve null', () {
      expect(validarCorreo('test@correo.com'), isNull);
    });

    test('correo con subdominio válido devuelve null', () {
      expect(validarCorreo('usuario@gmail.com'), isNull);
    });
  });

  // ==================== VALIDACIÓN DE CONTRASEÑA ====================
  group('validarPassword', () {
    test('contraseña vacía devuelve error obligatorio', () {
      expect(validarPassword(''), 'La contraseña es obligatoria');
    });

    test('contraseña de 3 caracteres devuelve error de longitud', () {
      expect(validarPassword('abc'), 'Mínimo 6 caracteres');
    });

    test('contraseña de 5 caracteres devuelve error de longitud', () {
      expect(validarPassword('abcde'), 'Mínimo 6 caracteres');
    });

    test('contraseña de exactamente 6 caracteres devuelve null', () {
      expect(validarPassword('123456'), isNull);
    });

    test('contraseña larga devuelve null', () {
      expect(validarPassword('contraseña_segura_larga'), isNull);
    });
  });

  // ==================== LÓGICA DE TOPPINGS ====================
  group('productoTieneToppings — productos CON toppings', () {
    test('Chilaquiles Rojos → true', () {
      expect(productoTieneToppings('Chilaquiles Rojos'), isTrue);
    });

    test('Chilaquiles Verdes → true', () {
      expect(productoTieneToppings('Chilaquiles Verdes'), isTrue);
    });

    test('Chilaquiles Divorciados → true', () {
      expect(productoTieneToppings('Chilaquiles Divorciados'), isTrue);
    });

    test('insensible a mayúsculas — CHILAQUILES ROJOS → true', () {
      expect(productoTieneToppings('CHILAQUILES ROJOS'), isTrue);
    });

    test('insensible a mayúsculas — chilaquiles verdes → true', () {
      expect(productoTieneToppings('chilaquiles verdes'), isTrue);
    });

    test('insensible a espacios extra → true', () {
      expect(productoTieneToppings('  Chilaquiles Divorciados  '), isTrue);
    });
  });

  group('productoTieneToppings — productos SIN toppings', () {
    test('Torta de Chilaquiles Rojos → false', () {
      expect(productoTieneToppings('Torta de Chilaquiles Rojos'), isFalse);
    });

    test('Torta de Chilaquiles Verdes → false', () {
      expect(productoTieneToppings('Torta de Chilaquiles Verdes'), isFalse);
    });

    test('Torta de Chilaquiles Divorciados → false', () {
      expect(productoTieneToppings('Torta de Chilaquiles Divorciados'), isFalse);
    });

    test('Molletes Queen → false', () {
      expect(productoTieneToppings('Molletes Queen'), isFalse);
    });

    test('Refresco → false', () {
      expect(productoTieneToppings('Refresco'), isFalse);
    });

    test('Café Americano → false', () {
      expect(productoTieneToppings('Café Americano'), isFalse);
    });

    test('Café de Olla → false', () {
      expect(productoTieneToppings('Café de Olla'), isFalse);
    });

    test('Jugo de Naranja → false', () {
      expect(productoTieneToppings('Jugo de Naranja'), isFalse);
    });

    test('cadena vacía → false', () {
      expect(productoTieneToppings(''), isFalse);
    });
  });

  // ==================== CÁLCULO DE PRECIOS ====================
  group('calcularTotal', () {
    test('precio base sin extras, cantidad 1', () {
      expect(calcularTotal(85, [], 1), 85.0);
    });

    test('precio base sin extras, cantidad 2', () {
      expect(calcularTotal(85, [], 2), 170.0);
    });

    test('\$50 + Pollo \$20 + Huevo \$15 = \$85', () {
      final extras = [
        {'nombre': 'Pollo', 'precio': 20},
        {'nombre': 'Huevo', 'precio': 15},
      ];
      expect(calcularTotal(50, extras, 1), 85.0);
    });

    test('precio con extras × 2 — (50+45)×2 = 190', () {
      final extras = [
        {'nombre': 'Arrachera', 'precio': 45},
      ];
      expect(calcularTotal(50, extras, 2), 190.0);
    });

    test('todos los toppings disponibles × 1', () {
      final extras = [
        {'nombre': 'Pollo', 'precio': 20},
        {'nombre': 'Huevo', 'precio': 15},
        {'nombre': 'Arrachera', 'precio': 45},
        {'nombre': 'Chorizo', 'precio': 25},
        {'nombre': 'Aguacate', 'precio': 15},
        {'nombre': 'Queso extra', 'precio': 10},
        {'nombre': 'Crema extra', 'precio': 8},
      ];
      // 85 + 20+15+45+25+15+10+8 = 85 + 138 = 223
      expect(calcularTotal(85, extras, 1), 223.0);
    });

    test('calcularPrecioUnitario es correcto', () {
      final extras = [
        {'nombre': 'Pollo', 'precio': 20},
        {'nombre': 'Aguacate', 'precio': 15},
      ];
      expect(calcularPrecioUnitario(85, extras), 120.0);
    });

    test('precio base con extra double (precio como double)', () {
      final extras = [
        {'nombre': 'Extra', 'precio': 8.5},
      ];
      expect(calcularTotal(50, extras, 1), 58.5);
    });
  });
}
