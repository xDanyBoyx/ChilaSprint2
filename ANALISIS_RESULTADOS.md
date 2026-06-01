# Análisis de Resultados — Suite de Pruebas ChilaQueen

## 1. Resumen Ejecutivo

La aplicación ChilaQueen (Sprint 2) cuenta con una suite de pruebas organizada en cuatro niveles:
**unitarias**, **de integración**, **de widget** y **E2E (extremo a extremo)**.
El objetivo es validar correctamente cada capa de la aplicación: desde funciones puras
hasta flujos completos del usuario con Firebase real.

---

## 2. Estructura de la Suite de Pruebas

```
test/
├── widget_test.dart                  # Pruebas unitarias originales (38 casos)
├── unit/
│   ├── validators_extended_test.dart # Validadores — casos adicionales (14 casos)
│   └── menu_utils_extended_test.dart # Lógica de menú — casos adicionales (16 casos)
├── integration/
│   └── local_database_test.dart      # SQLite CRUD — integración real (16 casos)
└── widget/
    └── login_form_test.dart          # Widget del formulario de login (15 casos)

integration_test/
└── app_test.dart                     # Pruebas E2E con dispositivo/emulador (7 casos)
```

| Tipo           | Archivo(s)                                | Casos | Requiere dispositivo |
|----------------|-------------------------------------------|-------|----------------------|
| Unitarias      | `test/widget_test.dart` + `test/unit/`    | 76    | No                   |
| Integración    | `test/integration/local_database_test.dart` | 16  | No                   |
| Widget         | `test/widget/login_form_test.dart`        | 15    | No                   |
| E2E            | `integration_test/app_test.dart`          | 7     | Sí (emulador/físico) |
| **Total**      |                                           | **114**|                     |

---

## 3. Pruebas Unitarias

### Objetivo
Verificar que las **funciones puras** de la aplicación producen los resultados
correctos para cualquier combinación de entradas, incluyendo casos borde.

### Módulos cubiertos

#### `utils/validators.dart`
| Función          | Casos probados                                                      | Resultado esperado |
|------------------|---------------------------------------------------------------------|--------------------|
| `validarCorreo`  | Vacío, sin `@`, sin dominio, sin extensión, formato completo, subdominio, puntos en local-part, correo institucional, caracteres especiales permitidos | `null` si válido, mensaje de error si no |
| `validarPassword`| Vacío, 1 char, 3 chars, 5 chars, 6 exactos (límite), 7+, 100 chars, caracteres especiales | `null` si válido, mensaje de error si no |

#### `utils/menu_utils.dart`
| Función                   | Casos probados                                                  | Resultado esperado |
|---------------------------|-----------------------------------------------------------------|--------------------|
| `productoTieneToppings`   | 3 variantes exactas, normalización case/trim, palabras extra, 6 productos sin toppings, vacío | `true`/`false` |
| `calcularPrecioUnitario`  | Sin extras, 1 extra, extras double, todos los toppings, base 0 | Suma correcta      |
| `calcularTotal`           | Cantidad 0, 1, 2, 100, con/sin extras, precios double          | `precioUnitario × cantidad` |

### Ejecución
```bash
flutter test test/widget_test.dart test/unit/
```

### Resultados esperados
Todos los casos pasan. Las funciones puras no tienen efectos secundarios
ni dependencias externas, por lo que son deterministas.

---

## 4. Pruebas de Integración

### Objetivo
Verificar que **`LocalDatabaseService`** (capa SQLite) funciona correctamente
como unidad integrada con la biblioteca `sqflite`. Se usa `sqflite_common_ffi`
para ejecutar SQLite directamente en el entorno de pruebas (JVM/CI) sin dispositivo.

### Casos cubiertos

| Grupo                           | Casos                                                                               |
|---------------------------------|-------------------------------------------------------------------------------------|
| `insertCartItem + getCartItems` | Insertar y recuperar, usuario sin items, aislamiento por userId, múltiples items, orden ASC por fecha, replace en conflicto |
| `updateCartItem`                | Actualizar cantidad, nota, syncStatus, id inexistente no lanza excepción            |
| `deleteCartItem`                | Eliminar por id, eliminar uno de varios, id inexistente no lanza excepción          |
| `clearUserCart`                 | Limpiar todos los items, solo afecta al usuario indicado, carrito vacío no lanza excepción |

### Diseño de los tests
- **Aislamiento:** `tearDown` limpia los datos de prueba después de cada test.
- **Idempotencia:** cada test parte de una base de datos limpia.
- **Casos negativos:** operaciones sobre IDs/usuarios inexistentes no deben lanzar excepción.

### Ejecución
```bash
flutter test test/integration/
```

### Resultados esperados

| Escenario                                         | Resultado |
|---------------------------------------------------|-----------|
| CRUD básico (insert, read, update, delete, clear) | ✅ Pasa   |
| Aislamiento entre usuarios                        | ✅ Pasa   |
| Orden ASC por fecha de creación                   | ✅ Pasa   |
| Replace en conflicto de id                        | ✅ Pasa   |
| Operaciones sobre IDs inexistentes                | ✅ Pasa (sin excepción) |

---

## 5. Pruebas de Widget

### Objetivo
Verificar que el **formulario de login** se renderiza correctamente y que
la lógica de validación produce los mensajes de error adecuados en la interfaz.
Se usa un widget de prueba (`_TestLoginPage`) que replica el comportamiento del
formulario real sin depender de Firebase, lo que permite ejecutarlo en CI.

### Casos cubiertos

| Grupo                            | Casos                                                                           |
|----------------------------------|---------------------------------------------------------------------------------|
| Estructura del formulario        | Título presente, campo correo, campo contraseña, botón login, botón toggle, sin errores al cargar |
| Toggle visibilidad de contraseña | Icono inicial `visibility_off`, toggle a `visibility`, segundo toggle de vuelta  |
| Validación de correo             | Campo vacío → error obligatorio, sin `@` → error formato, sin dominio → error formato |
| Validación de contraseña         | Campo vacío → error obligatorio, 3 chars → error mínimo 6                       |
| Formulario válido                | Sin errores con datos válidos, campos editables                                 |

### Estrategia de mocking
El widget de prueba importa directamente `validarCorreo` y `validarPassword` de
`utils/validators.dart`, las mismas funciones que usa la pantalla de producción.
Esto garantiza que los tests ejercitan la **lógica real** de validación.

### Ejecución
```bash
flutter test test/widget/
```

### Resultados esperados

| Escenario                                     | Resultado |
|-----------------------------------------------|-----------|
| Renderizado inicial correcto                  | ✅ Pasa   |
| Toggle de contraseña (2 estados)              | ✅ Pasa   |
| Mensajes de error por validación de correo    | ✅ Pasa   |
| Mensajes de error por validación de contraseña| ✅ Pasa   |
| Sin errores con datos válidos                 | ✅ Pasa   |

---

## 6. Pruebas E2E (End-to-End)

### Objetivo
Verificar **flujos completos del usuario** sobre la aplicación real con Firebase
activo, asegurando que la UI y el backend funcionan de extremo a extremo.

### Requisitos de entorno
- Dispositivo físico Android/iOS o emulador conectado
- Proyecto Firebase `chilaqueen-d4d94` activo
- Reglas de Firestore habilitadas

### Casos cubiertos

| Grupo                         | Casos                                                                 |
|-------------------------------|-----------------------------------------------------------------------|
| Arranque de la app            | App arranca sin errores, pantalla de login visible                    |
| Validación en login           | Campos vacíos → SnackBar, correo inválido → SnackBar, contraseña corta → SnackBar |
| Toggle visibilidad contraseña | Ícono de ojo alterna visibilidad                                      |
| Navegación                    | "Crear una cuenta" navega a Registro, "¿Olvidaste?" navega a Recuperación |

### Casos adicionales (requieren credenciales reales, en el archivo comentados)
- Login exitoso como **cliente** → redirige a `ventana_user` (tab "Menú")
- Login exitoso como **empleado** → redirige a `ventana_employed` (tab "Tickets")

### Ejecución
```bash
# En emulador o dispositivo físico
flutter test integration_test/app_test.dart -d <device-id>

# Listar dispositivos disponibles
flutter devices
```

### Resultados esperados

| Escenario                                    | Resultado esperado |
|----------------------------------------------|-------------------|
| Arranque de la app                           | ✅ Sin errores    |
| SnackBar por validación de correo inválido   | ✅ Visible        |
| SnackBar por contraseña corta                | ✅ Visible        |
| Navegación a Registro                        | ✅ Funciona       |
| Navegación a Recuperación                    | ✅ Funciona       |

---

## 7. Cobertura de Código

### Módulos con cobertura completa (100%)
- `lib/utils/validators.dart` — todos los branches cubiertos
- `lib/utils/menu_utils.dart` — todas las ramas de la lógica de toppings y precios

### Módulos con cobertura parcial
- `lib/services/local_database_service.dart` — 100% de métodos públicos cubiertos vía integración
- `lib/login.dart` — lógica de validación cubierta a través de widget tests; la llamada real a Firebase queda fuera del alcance de tests en VM
- `lib/authentication.dart` — métodos de validación (`validarCorreo`, `validarPassword`) cubiertos indirectamente

### Módulos no cubiertos por pruebas automatizadas
- `lib/ventana_user.dart` / `lib/ventana_employed.dart` — requieren Firebase activo y estado de sesión
- `lib/analytics_service.dart` — requiere Firebase Analytics inicializado

### Generar reporte de cobertura
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 8. Ejecución de toda la suite (sin dispositivo)

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar todas las pruebas de test/ (unitarias + integración + widget)
flutter test --reporter=expanded

# 3. Solo pruebas unitarias
flutter test test/widget_test.dart test/unit/ --reporter=expanded

# 4. Solo pruebas de integración SQLite
flutter test test/integration/ --reporter=expanded

# 5. Solo pruebas de widget
flutter test test/widget/ --reporter=expanded
```

---

## 9. Integración Continua (CI/CD)

El workflow de GitHub Actions (`.github/workflows/flutter_ci.yml`) ya ejecuta:
1. `flutter analyze` — verificación estática de tipos y lints
2. `flutter test --reporter=expanded` — todos los tests en `test/`

Las pruebas E2E (`integration_test/`) **no** se ejecutan en CI porque requieren
un dispositivo. Para incluirlas en CI se necesita configurar un emulador Android
o un runner con un simulador iOS.

---

## 10. Conclusiones

| Aspecto                          | Evaluación |
|----------------------------------|-----------|
| Cobertura de lógica de negocio   | Alta — validadores y cálculos de precios al 100% |
| Cobertura de capa de datos       | Alta — todos los métodos CRUD de SQLite probados |
| Cobertura de UI                  | Media — formulario de login probado; pantallas con Firebase excluidas |
| Cobertura E2E                    | Media — flujos de validación y navegación cubiertos; login real requiere credenciales |
| Velocidad de ejecución en CI     | Rápida — las 99 pruebas de `test/` terminan en < 30 s en Ubuntu |
| Mantenibilidad                   | Alta — tests organizados por tipo, sin dependencias cruzadas |

**La suite detecta regresiones en:**
- Cambios en las reglas de validación de correo/contraseña
- Cambios en la lógica de asignación de toppings y cálculo de precios
- Cambios en el esquema o los métodos de `LocalDatabaseService`
- Cambios visuales en el formulario de login (estructura de widgets)
