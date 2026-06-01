// Pruebas E2E (End-to-End) para ChilaQueen.
//
// Requieren un dispositivo físico o emulador con Firebase configurado.
// Comando de ejecución:
//   flutter test integration_test/app_test.dart -d <device-id>
//
// En CI sin dispositivo, ejecutar:
//   flutter test integration_test/app_test.dart --platform=chrome
// (requiere tener configurado el perfil web)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sprint2_chilaqueen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Lanzamiento de la app ───────────────────────────────────────────────

  group('E2E — Arranque de la aplicación', () {
    testWidgets('la app arranca sin errores y muestra la pantalla de login',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // La pantalla de login debe mostrar el texto de bienvenida
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);
    });

    testWidgets('el formulario de login contiene los campos requeridos',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(TextField), findsAtLeastNWidgets(2));
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Crear una cuenta'), findsOneWidget);
    });
  });

  // ── Flujo de validación en la pantalla de login ─────────────────────────

  group('E2E — Validación en login', () {
    testWidgets('presionar Iniciar Sesión con campos vacíos muestra SnackBar',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Iniciar Sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('correo inválido muestra SnackBar de error', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Ingresar correo sin formato válido
      final emailFields = find.byType(TextField);
      await tester.enterText(emailFields.first, 'estonoesunemail');
      await tester.tap(find.text('Iniciar Sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Formato de correo inválido'), findsOneWidget);
    });

    testWidgets('contraseña menor a 6 chars muestra SnackBar de error',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final emailFields = find.byType(TextField);
      await tester.enterText(emailFields.first, 'test@correo.com');
      await tester.enterText(emailFields.at(1), '123');
      await tester.tap(find.text('Iniciar Sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });
  });

  // ── Toggle de contraseña ────────────────────────────────────────────────

  group('E2E — Toggle visibilidad contraseña', () {
    testWidgets('ícono de ojo alterna la visibilidad de la contraseña',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Estado inicial: contraseña oculta
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap sobre el ojo para mostrar
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  // ── Navegación a Registro ───────────────────────────────────────────────

  group('E2E — Navegación', () {
    testWidgets('tap en Crear una cuenta navega a pantalla de registro',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Crear una cuenta'));
      await tester.pumpAndSettle();

      // La pantalla de registro tiene el botón "Registrarse" o el título
      expect(
        find.textContaining('Registr', findRichText: true),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets(
        'tap en ¿Olvidaste tu contraseña? navega a pantalla de recuperación',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('contraseña', findRichText: true, skipOffstage: false),
        findsAtLeastNWidgets(1),
      );
    });
  });

  // ── Login con credenciales reales (requiere Firebase activo) ────────────
  //
  // NOTA: Los siguientes tests solo pasan con un usuario existente en Firebase.
  // Comentar o ignorar en CI. Descomentar y configurar credenciales para
  // pruebas manuales o en entorno con Firebase emulado.

  // group('E2E — Login con Firebase (manual)', () {
  //   testWidgets('login exitoso como cliente redirige a ventana_user',
  //       (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));
  //
  //     final emailFields = find.byType(TextField);
  //     await tester.enterText(emailFields.first, 'cliente@test.com');
  //     await tester.enterText(emailFields.at(1), 'password123');
  //     await tester.tap(find.text('Iniciar Sesión'));
  //     await tester.pumpAndSettle(const Duration(seconds: 8));
  //
  //     // El menú de cliente tiene la tab 'Menú'
  //     expect(find.text('Menú'), findsOneWidget);
  //   });
  //
  //   testWidgets('login exitoso como empleado redirige a ventana_employed',
  //       (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));
  //
  //     final emailFields = find.byType(TextField);
  //     await tester.enterText(emailFields.first, 'empleado@test.com');
  //     await tester.enterText(emailFields.at(1), 'password123');
  //     await tester.tap(find.text('Iniciar Sesión'));
  //     await tester.pumpAndSettle(const Duration(seconds: 8));
  //
  //     expect(find.text('Tickets'), findsOneWidget);
  //   });
  // });
}
