# ChilaQueen — Sprint 2: Conexiones / Flutter

Aplicación móvil multiplataforma para la gestión de pedidos y operaciones del restaurante **ChilaQueen**, especializado en chilaquiles y comida mexicana.

---

## Objetivo del Sprint

Conectar la aplicación Flutter a servicios externos reales, sustituyendo datos estáticos por una base de datos en la nube. Se implementó **Firebase** como backend completo (autenticación y base de datos en tiempo real), cumpliendo el requisito de *aplicación funcional conectada a servicios externos*.

---

## Tecnologías Utilizadas

| Tecnología | Versión | Uso |
|---|---|---|
| Flutter | SDK ^3.9.0 | Framework multiplataforma (Android, iOS, Web) |
| Dart | ^3.9.0 | Lenguaje de programación |
| Firebase Auth | ^6.2.0 | Autenticación de usuarios y manejo de sesiones |
| Cloud Firestore | ^6.1.3 | Base de datos NoSQL en tiempo real |
| Firebase Core | ^4.5.0 | Inicialización de Firebase |
| Google Fonts | ^6.1.0 | Tipografías (Playfair Display + Poppins) |

---

## Arquitectura del Proyecto

```
lib/
├── main.dart               # Punto de entrada, routing por rol con Firebase Auth
├── firebase_options.dart   # Configuración automática de Firebase
├── login.dart              # Pantalla de inicio de sesión
├── registro.dart           # Registro de nuevos clientes
├── recovery.dart           # Recuperación de contraseña vía email
├── authentication.dart     # Lógica de Firebase Auth + validaciones
├── ventana_user.dart       # App cliente (Menú, Favoritos, Carrito, Pedidos)
└── ventana_employed.dart   # App empleado/admin (Tickets, Stock, Finanzas, Sucursal, Equipo)
```

---

## Funcionalidades Implementadas

### Autenticación y Roles
- Registro e inicio de sesión con **Firebase Auth**
- Recuperación de contraseña por correo electrónico
- Routing automático por rol: `cliente` → app cliente | `empleado`/`admin` → app empleado
- Persistencia de sesión al cerrar y reabrir la app

### App Cliente (`ventana_user.dart`)
- **Menú**: Catálogo de productos cargado desde Firestore en tiempo real
- Favoritos, Carrito y Pedidos (en desarrollo)

### App Empleado/Admin (`ventana_employed.dart`)
| Módulo | Descripción |
|--------|-------------|
| **Tickets** | Gestión de pedidos activos en tiempo real con cambio de estado e historial |
| **Stock** | Control de disponibilidad de productos por categoría (conectado a Firestore) |
| **Finanzas** | Dashboard con ingresos, métricas del día, hora pico y top vendidos (datos reales) |
| **Sucursal** | Control de apertura/cierre y nivel de demanda (persiste en Firestore) |
| **Equipo** | Alta y baja de empleados; permisos diferenciados por rol |

### Permisos por Rol
- **Admin**: acceso completo a todas las funciones de edición
- **Empleado**: solo lectura en Stock, Sucursal y Equipo; edición completa en Tickets

---

## Estructura de Firestore

```
usuarios/{uid}
  ├── nombre, correo, telefono
  ├── puesto: "cliente" | "empleado" | "admin"
  └── fecha_registro, imagen_perfil

productos/{id}
  ├── nombre, descripcion, categoria
  ├── precio
  └── disponible: true | false

pedidos/{id}
  ├── cliente_nombre, platillo, notas[]
  ├── estadoActual, tiempoEstimado
  ├── precio_total
  └── fecha

config/sucursal
  ├── abierta: true | false
  └── nivel_demanda
```

---

## Requisitos Previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado y en PATH
- Android Studio o VS Code con extensiones de Flutter/Dart
- Proyecto Firebase activo (ya configurado en `firebase_options.dart`)
- Dispositivo físico o emulador Android/iOS

Verificar instalación:
```bash
flutter doctor
```

---

## Instrucciones de Ejecución

**1. Clonar el repositorio**
```bash
git clone <url-del-repositorio>
cd ChilaSprint2
```

**2. Instalar dependencias**
```bash
flutter pub get
```

**3. Ejecutar la aplicación**
```bash
# En emulador o dispositivo conectado
flutter run

# Solo para web
flutter run -d chrome
```

**4. Credenciales de prueba**

| Rol | Correo | Contraseña |
|-----|--------|------------|
| Admin | admin@chilaqueen.com | (configurar en Firebase Console) |
| Empleado | empleado@chilaqueen.com | (configurar en Firebase Console) |
| Cliente | cliente@chilaqueen.com | (configurar en Firebase Console) |

> Para promover un usuario a `admin` o `empleado`, usar el módulo **EQUIPO** desde una cuenta admin o editar el campo `puesto` directamente en Firebase Console.

---

## Evidencias

Las capturas de pantalla y videos de funcionamiento se encuentran en la carpeta [`evidencias/`](evidencias/).

---

## Equipo

Proyecto universitario — Taller de Full Stack, Sprint 2
