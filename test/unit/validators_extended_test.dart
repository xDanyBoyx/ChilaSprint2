import 'package:flutter_test/flutter_test.dart';
import 'package:sprint2_chilaqueen/utils/validators.dart';

void main() {
  // ── CORREO ────────────────────────────────────────────────────────────────

  group('validarCorreo — formatos válidos', () {
    test('correo con puntos en local-part devuelve null', () {
      expect(validarCorreo('nombre.apellido@empresa.mx'), isNull);
    });

    test('correo con números devuelve null', () {
      expect(validarCorreo('user123@gmail.com'), isNull);
    });

    test('correo institucional con subdomain devuelve null', () {
      expect(validarCorreo('alumno@universidad.edu.mx'), isNull);
    });

    test('correo con TLD largo devuelve null', () {
      expect(validarCorreo('test@empresa.com'), isNull);
    });

    test('correo con guión bajo en local-part devuelve null', () {
      expect(validarCorreo('usuario_test@gmail.com'), isNull);
    });
  });

  group('validarCorreo — formatos inválidos', () {
    test('solo @ devuelve formato inválido', () {
      expect(validarCorreo('@'), 'Formato de correo inválido');
    });

    test('cadena con solo espacios devuelve formato inválido', () {
      expect(validarCorreo('   '), 'Formato de correo inválido');
    });

    test('@ al inicio devuelve formato inválido', () {
      expect(validarCorreo('@dominio.com'), 'Formato de correo inválido');
    });

    test('sin punto en dominio devuelve formato inválido', () {
      expect(validarCorreo('user@dominio'), 'Formato de correo inválido');
    });

    test('correo vacío devuelve error obligatorio', () {
      expect(validarCorreo(''), 'El correo es obligatorio');
    });
  });

  // ── CONTRASEÑA ────────────────────────────────────────────────────────────

  group('validarPassword — contraseñas válidas', () {
    test('exactamente 6 caracteres devuelve null', () {
      expect(validarPassword('abcdef'), isNull);
    });

    test('7 caracteres alfanuméricos devuelve null', () {
      expect(validarPassword('abcdefg'), isNull);
    });

    test('contraseña numérica de 9 dígitos devuelve null', () {
      expect(validarPassword('123456789'), isNull);
    });

    test('contraseña con caracteres especiales ≥6 devuelve null', () {
      expect(validarPassword('!@#\$%^'), isNull);
    });

    test('contraseña muy larga (100 chars) devuelve null', () {
      expect(validarPassword('a' * 100), isNull);
    });
  });

  group('validarPassword — contraseñas inválidas', () {
    test('contraseña vacía devuelve error obligatorio', () {
      expect(validarPassword(''), 'La contraseña es obligatoria');
    });

    test('1 carácter devuelve mínimo 6', () {
      expect(validarPassword('x'), 'Mínimo 6 caracteres');
    });

    test('5 caracteres devuelve mínimo 6', () {
      expect(validarPassword('abcde'), 'Mínimo 6 caracteres');
    });

    test('4 espacios devuelve mínimo 6', () {
      expect(validarPassword('    '), 'Mínimo 6 caracteres');
    });
  });
}
