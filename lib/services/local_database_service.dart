// SQLite: almacenamiento local/offline del carrito del cliente.
// Firebase Firestore es la fuente principal (nube); SQLite actúa como caché local.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'chilaqueen_local.db');
    return openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        // Tabla local_cart: respaldo offline del carrito activo del cliente.
        // Los campos replican la estructura del carrito en Firestore para
        // permitir mostrar datos aunque no haya conexión a internet.
        await db.execute('''
          CREATE TABLE local_cart (
            id          TEXT PRIMARY KEY,
            userId      TEXT NOT NULL,
            productId   TEXT NOT NULL,
            name        TEXT NOT NULL,
            quantity    INTEGER NOT NULL DEFAULT 1,
            price       REAL NOT NULL,
            extras      TEXT DEFAULT '',
            note        TEXT DEFAULT '',
            createdAt   TEXT NOT NULL,
            syncStatus  INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Insertar o reemplazar un item en el carrito local
  Future<void> insertCartItem(Map<String, dynamic> item) async {
    final db = await _database;
    await db.insert(
      'local_cart',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todos los items del carrito local de un usuario
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final db = await _database;
    return db.query(
      'local_cart',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );
  }

  // Actualizar campos de un item del carrito local
  Future<void> updateCartItem(String id, Map<String, dynamic> values) async {
    final db = await _database;
    await db.update(
      'local_cart',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar un item del carrito local por id
  Future<void> deleteCartItem(String id) async {
    final db = await _database;
    await db.delete(
      'local_cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Limpiar todo el carrito local de un usuario.
  // Se llama tras confirmar el pedido (sincronizado a Firestore).
  Future<void> clearUserCart(String userId) async {
    final db = await _database;
    await db.delete(
      'local_cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Solo para pruebas: cierra la BD y resetea el singleton para aislar cada test.
  Future<void> closeForTesting() async {
    await _db?.close();
    _db = null;
  }
}
