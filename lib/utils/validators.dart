// Funciones puras de validación — sin dependencia de Firebase ni Flutter.
// Pueden importarse y probarse con flutter test sin inicializar Firebase.

/// Valida el formato del correo. Devuelve null si es válido.
String? validarCorreo(String email) {
  if (email.isEmpty) return "El correo es obligatorio";
  final bool emailValid = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(email);
  if (!emailValid) return "Formato de correo inválido";
  return null;
}

/// Valida la contraseña. Devuelve null si es válida.
String? validarPassword(String password) {
  if (password.isEmpty) return "La contraseña es obligatoria";
  if (password.length < 6) return "Mínimo 6 caracteres";
  return null;
}
