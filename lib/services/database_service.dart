// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/articulo.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventario.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE articulos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebase_id TEXT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio REAL NOT NULL,
        stock INTEGER NOT NULL,
        codigo_barras TEXT,
        categoria TEXT,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0,
        pendiente_sincronizacion INTEGER DEFAULT 1,
        conflicto TEXT
      )
    ''');
  }

  Future<int> insertArticulo(Articulo articulo) async {
    final db = await database;
    return await db.insert('articulos', articulo.toMap());
  }

  Future<int> updateArticulo(Articulo articulo) async {
    final db = await database;
    return await db.update(
      'articulos',
      articulo.toMap(),
      where: 'id = ?',
      whereArgs: [articulo.id],
    );
  }

  Future<int> deleteArticulo(int id) async {
    final db = await database;
    return await db.delete('articulos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Articulo>> getArticulos() async {
    final db = await database;
    final maps = await db.query('articulos', orderBy: 'nombre ASC');
    return maps.map((e) => Articulo.fromMap(e)).toList();
  }

  Future<List<Articulo>> getArticulosPendientesSincronizacion() async {
    final db = await database;
    final maps = await db.query(
      'articulos',
      where: 'pendiente_sincronizacion = ?',
      whereArgs: [1],
    );
    return maps.map((e) => Articulo.fromMap(e)).toList();
  }
}