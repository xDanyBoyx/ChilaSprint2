// Pruebas de Widget para la pantalla de login de ChilaQueen.
//
// Se usa un widget de prueba (_TestLoginPage) que replica la lógica del
// formulario de login (validadores, toggle de contraseña, mensajes de error)
// sin depender de Firebase, lo que permite ejecutar estos tests en CI/VM.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint2_chilaqueen/utils/validators.dart';

// ── Widget de prueba ──────────────────────────────────────────────────────

class _TestLoginPage extends StatefulWidget {
  const _TestLoginPage();

  @override
  State<_TestLoginPage> createState() => _TestLoginPageState();
}

class _TestLoginPageState extends State<_TestLoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _ocultarPassword = true;
  String? _mensajeError;
  bool _formularioValido = false;

  void _intentarLogin() {
    final emailError = validarCorreo(_emailCtrl.text);
    final passError = validarPassword(_passCtrl.text);
    final error = emailError ?? passError;
    setState(() {
      _mensajeError = error;
      _formularioValido = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bienvenido de vuelta'),

              TextField(
                key: const Key('email_field'),
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'ejemplo@correo.com'),
              ),

              TextField(
                key: const Key('pass_field'),
                controller: _passCtrl,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  hintText: 'Tu contraseña',
                  suffixIcon: IconButton(
                    key: const Key('toggle_pass'),
                    icon: Icon(
                      _ocultarPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
              ),

              ElevatedButton(
                key: const Key('login_btn'),
                onPressed: _intentarLogin,
                child: const Text('Iniciar Sesión'),
              ),

              if (_mensajeError != null)
                Text(
                  key: const Key('error_msg'),
                  _mensajeError!,
                ),

              if (_formularioValido)
                const Text(
                  key: Key('success_msg'),
                  'Formulario válido',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  // ── Estructura del widget ──────────────────────────────────────────────

  group('Login — estructura del formulario', () {
    testWidgets('renderiza título de bienvenida', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      expect(find.text('Bienvenido de vuelta'), findsOneWidget);
    });

    testWidgets('campo de correo está presente', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      expect(find.byKey(const Key('email_field')), findsOneWidget);
    });

    testWidgets('campo de contraseña está presente', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      expect(find.byKey(const Key('pass_field')), findsOneWidget);
    });

    testWidgets('botón Iniciar Sesión está presente', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      expect(find.byKey(const Key('login_btn')), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('botón toggle de contraseña está presente', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      expect(find.byKey(const Key('toggle_pass')), findsOneWidget);
    });

    testWidgets('no muestra mensaje de error al cargar', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      expect(find.byKey(const Key('error_msg')), findsNothing);
    });
  });

  // ── Toggle de visibilidad de contraseña ───────────────────────────────

  group('Login — toggle de contraseña', () {
    testWidgets('icono inicial es visibility_off (contraseña oculta)',
        (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('tap en toggle cambia icono a visibility (contraseña visible)',
        (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.tap(find.byKey(const Key('toggle_pass')));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('segundo tap en toggle vuelve a ocultar la contraseña',
        (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.tap(find.byKey(const Key('toggle_pass')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('toggle_pass')));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  // ── Validación de correo ──────────────────────────────────────────────

  group('Login — validación de correo', () {
    testWidgets('correo vacío muestra error obligatorio', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.tap(find.byKey(const Key('login_btn')));
      await tester.pump();

      expect(find.text('El correo es obligatorio'), findsOneWidget);
    });

    testWidgets('correo sin @ muestra error de formato', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.enterText(find.byKey(const Key('email_field')), 'nocorreo');
      await tester.tap(find.byKey(const Key('login_btn')));
      await tester.pump();

      expect(find.text('Formato de correo inválido'), findsOneWidget);
    });

    testWidgets('correo sin dominio muestra error de formato', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.enterText(find.byKey(const Key('email_field')), 'user@');
      await tester.tap(find.byKey(const Key('login_btn')));
      await tester.pump();

      expect(find.text('Formato de correo inválido'), findsOneWidget);
    });
  });

  // ── Validación de contraseña ──────────────────────────────────────────

  group('Login — validación de contraseña', () {
    testWidgets('contraseña vacía muestra error obligatorio', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      // Correo válido para llegar a la validación de contraseña
      await tester.enterText(
          find.byKey(const Key('email_field')), 'test@correo.com');
      await tester.tap(find.byKey(const Key('login_btn')));
      await tester.pump();

      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
    });

    testWidgets('contraseña de 3 chars muestra error mínimo 6', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.enterText(
          find.byKey(const Key('email_field')), 'test@correo.com');
      await tester.enterText(find.byKey(const Key('pass_field')), 'abc');
      await tester.tap(find.byKey(const Key('login_btn')));
      await tester.pump();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });
  });

  // ── Formulario válido ─────────────────────────────────────────────────

  group('Login — formulario válido', () {
    testWidgets('correo y contraseña válidos no muestran error', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.enterText(
          find.byKey(const Key('email_field')), 'usuario@gmail.com');
      await tester.enterText(
          find.byKey(const Key('pass_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_btn')));
      await tester.pump();

      expect(find.byKey(const Key('error_msg')), findsNothing);
      expect(find.byKey(const Key('success_msg')), findsOneWidget);
    });

    testWidgets('campos se pueden editar y actualizar', (tester) async {
      await tester.pumpWidget(const _TestLoginPage());

      await tester.enterText(
          find.byKey(const Key('email_field')), 'correo@test.com');
      await tester.enterText(find.byKey(const Key('pass_field')), 'miPass99');

      expect(
        (tester.widget(find.byKey(const Key('email_field'))) as TextField)
            .controller
            ?.text,
        'correo@test.com',
      );
    });
  });
}
