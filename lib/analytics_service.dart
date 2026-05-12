import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Autenticación
  static Future<void> logLogin() =>
      _analytics.logLogin(loginMethod: 'email');

  static Future<void> logRegistro() =>
      _analytics.logSignUp(signUpMethod: 'email');

  // Pantallas
  static Future<void> logPantalla(String nombre) =>
      _analytics.logScreenView(screenName: nombre);

  // Tickets
  static Future<void> logPedidoActualizado(String estado) =>
      _analytics.logEvent(
        name: 'pedido_actualizado',
        parameters: {'estado': estado},
      );

  // Stock
  static Future<void> logProductoAgregado(String categoria) =>
      _analytics.logEvent(
        name: 'producto_agregado',
        parameters: {'categoria': categoria},
      );

  // Equipo
  static Future<void> logEmpleadoContratado(String rol) =>
      _analytics.logEvent(
        name: 'empleado_contratado',
        parameters: {'rol': rol},
      );

  // Sucursal
  static Future<void> logSucursalToggle(bool abierta) =>
      _analytics.logEvent(
        name: 'sucursal_toggle',
        parameters: {'estado': abierta ? 'abierta' : 'cerrada'},
      );
}
