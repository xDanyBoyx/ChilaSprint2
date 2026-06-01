// Pruebas de integración para LocalDatabaseService (SQLite).
// Usan sqflite_common_ffi para correr SQLite en el entorno de pruebas (desktop/CI)
// sin necesidad de un dispositivo físico ni Firebase.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sprint2_chilaqueen/services/local_database_service.dart';

void main() {
  setUpAll(() {
    // Inicializar SQLite FFI para ejecutar en VM / CI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final db = LocalDatabaseService();

  // Item base reutilizable — cada test puede sobreescribir campos con spread
  const baseItem = {
    'id': 'test-001',
    'userId': 'user-abc',
    'productId': 'prod-xyz',
    'name': 'Chilaquiles Rojos',
    'quantity': 2,
    'price': 85.0,
    'extras': 'Pollo,Huevo',
    'note': 'Sin cebolla',
    'createdAt': '2024-06-01T10:00:00',
    'syncStatus': 0,
  };

  tearDown(() async {
    // Limpiar datos de prueba después de cada test para aislamiento
    await db.clearUserCart('user-abc');
    await db.clearUserCart('user-xyz');
  });

  tearDownAll(() async {
    await db.closeForTesting();
  });

  // ── INSERT / READ ─────────────────────────────────────────────────────────

  group('insertCartItem + getCartItems', () {
    test('insertar un item y recuperarlo correctamente', () async {
      await db.insertCartItem(Map<String, dynamic>.from(baseItem));

      final items = await db.getCartItems('user-abc');

      expect(items.length, 1);
      expect(items.first['name'], 'Chilaquiles Rojos');
      expect(items.first['quantity'], 2);
      expect(items.first['price'], 85.0);
      expect(items.first['extras'], 'Pollo,Huevo');
    });

    test('usuario sin items devuelve lista vacía', () async {
      final items = await db.getCartItems('usuario-inexistente');
      expect(items, isEmpty);
    });

    test('getCartItems solo devuelve items del userId indicado', () async {
      await db.insertCartItem({
        ...baseItem,
        'id': 'test-u1',
        'userId': 'user-abc',
      });
      await db.insertCartItem({
        ...baseItem,
        'id': 'test-u2',
        'userId': 'user-xyz',
        'name': 'Chilaquiles Verdes',
      });

      final itemsAbc = await db.getCartItems('user-abc');
      final itemsXyz = await db.getCartItems('user-xyz');

      expect(itemsAbc.length, 1);
      expect(itemsAbc.first['name'], 'Chilaquiles Rojos');
      expect(itemsXyz.length, 1);
      expect(itemsXyz.first['name'], 'Chilaquiles Verdes');
    });

    test('insertar múltiples items del mismo usuario', () async {
      await db.insertCartItem({...baseItem, 'id': 'test-001'});
      await db.insertCartItem({
        ...baseItem,
        'id': 'test-002',
        'name': 'Chilaquiles Verdes',
      });

      final items = await db.getCartItems('user-abc');
      expect(items.length, 2);
    });

    test('items se recuperan en orden ASC por createdAt', () async {
      await db.insertCartItem({
        ...baseItem,
        'id': 'test-002',
        'name': 'Segundo',
        'createdAt': '2024-06-01T11:00:00',
      });
      await db.insertCartItem({
        ...baseItem,
        'id': 'test-001',
        'name': 'Primero',
        'createdAt': '2024-06-01T10:00:00',
      });

      final items = await db.getCartItems('user-abc');
      expect(items[0]['name'], 'Primero');
      expect(items[1]['name'], 'Segundo');
    });

    test('conflicto de id reemplaza el item existente (replace)', () async {
      await db.insertCartItem({...baseItem, 'name': 'Original'});
      await db.insertCartItem({...baseItem, 'name': 'Actualizado'});

      final items = await db.getCartItems('user-abc');
      expect(items.length, 1);
      expect(items.first['name'], 'Actualizado');
    });
  });

  // ── UPDATE ────────────────────────────────────────────────────────────────

  group('updateCartItem', () {
    test('actualizar cantidad de un item', () async {
      await db.insertCartItem(Map<String, dynamic>.from(baseItem));
      await db.updateCartItem('test-001', {'quantity': 5});

      final items = await db.getCartItems('user-abc');
      expect(items.first['quantity'], 5);
    });

    test('actualizar nota del item', () async {
      await db.insertCartItem(Map<String, dynamic>.from(baseItem));
      await db.updateCartItem('test-001', {'note': 'Con extra picante'});

      final items = await db.getCartItems('user-abc');
      expect(items.first['note'], 'Con extra picante');
    });

    test('actualizar syncStatus a 1 (sincronizado)', () async {
      await db.insertCartItem(Map<String, dynamic>.from(baseItem));
      await db.updateCartItem('test-001', {'syncStatus': 1});

      final items = await db.getCartItems('user-abc');
      expect(items.first['syncStatus'], 1);
    });

    test('actualizar id inexistente no lanza excepción', () async {
      await expectLater(
        db.updateCartItem('id-que-no-existe', {'quantity': 3}),
        completes,
      );
    });
  });

  // ── DELETE ────────────────────────────────────────────────────────────────

  group('deleteCartItem', () {
    test('eliminar un item por id', () async {
      await db.insertCartItem(Map<String, dynamic>.from(baseItem));
      await db.deleteCartItem('test-001');

      final items = await db.getCartItems('user-abc');
      expect(items, isEmpty);
    });

    test('eliminar uno de varios items deja los demás intactos', () async {
      await db.insertCartItem({...baseItem, 'id': 'test-001'});
      await db.insertCartItem({
        ...baseItem,
        'id': 'test-002',
        'name': 'Chilaquiles Verdes',
      });

      await db.deleteCartItem('test-001');

      final items = await db.getCartItems('user-abc');
      expect(items.length, 1);
      expect(items.first['name'], 'Chilaquiles Verdes');
    });

    test('eliminar id inexistente no lanza excepción', () async {
      await expectLater(db.deleteCartItem('id-fantasma'), completes);
    });
  });

  // ── CLEAR ─────────────────────────────────────────────────────────────────

  group('clearUserCart', () {
    test('limpiar carrito elimina todos los items del usuario', () async {
      await db.insertCartItem({...baseItem, 'id': 'test-001'});
      await db.insertCartItem({...baseItem, 'id': 'test-002'});

      await db.clearUserCart('user-abc');

      final items = await db.getCartItems('user-abc');
      expect(items, isEmpty);
    });

    test('clearUserCart solo afecta al usuario indicado', () async {
      await db.insertCartItem({...baseItem, 'id': 'test-u1', 'userId': 'user-abc'});
      await db.insertCartItem({
        ...baseItem,
        'id': 'test-u2',
        'userId': 'user-xyz',
      });

      await db.clearUserCart('user-abc');

      expect(await db.getCartItems('user-abc'), isEmpty);
      expect(await db.getCartItems('user-xyz'), hasLength(1));
    });

    test('limpiar carrito vacío no lanza excepción', () async {
      await expectLater(db.clearUserCart('usuario-vacio'), completes);
    });
  });
}
