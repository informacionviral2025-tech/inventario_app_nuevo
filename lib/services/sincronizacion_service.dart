// lib/services/sincronizacion_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';

class SincronizacionService {
  static const String _databaseName = 'inventario.db';
  static const int _databaseVersion = 1;
  static const String _tableArticulos = 'articulos';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableArticulos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebase_id TEXT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio REAL NOT NULL,
        stock INTEGER NOT NULL,
        codigo_barras TEXT,
        categoria TEXT,
        empresa_id TEXT NOT NULL,
        unidad_medida TEXT,
        stock_minimo REAL,
        stock_maximo REAL,
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL,
        fecha_ultima_sincronizacion TEXT,
        sincronizado INTEGER DEFAULT 0,
        pendiente_sincronizacion INTEGER DEFAULT 1,
        conflicto TEXT
      )
    ''');
  }

  Future<int> insertarArticulo(Articulo articulo) async {
    final db = await database;
    return await db.insert(_tableArticulos, articulo.toMap());
  }

  Future<List<Articulo>> obtenerArticulosLocal(String empresaId) async {
    final db = await database;
    final maps = await db.query(
      _tableArticulos,
      where: 'empresa_id = ?',
      whereArgs: [empresaId],
      orderBy: 'fecha_actualizacion DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Articulo.fromMap(maps[i]);
    });
  }

  Future<int> actualizarArticuloLocal(Articulo articulo) async {
    final db = await database;
    return await db.update(
      _tableArticulos,
      articulo.toMap(),
      where: 'id = ?',
      whereArgs: [articulo.id],
    );
  }

  Future<int> eliminarArticuloLocal(int id) async {
    final db = await database;
    return await db.delete(
      _tableArticulos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> sincronizarConFirebase(String empresaId) async {
    try {
      final articuloService = ArticuloService(empresaId);
      
      await _subirCambiosLocales(empresaId, articuloService);
      await _descargarActualizaciones(empresaId, articuloService);
      
    } catch (e) {
      throw Exception('Error en sincronización: $e');
    }
  }

  Future<void> _subirCambiosLocales(
    String empresaId, 
    ArticuloService articuloService
  ) async {
    final db = await database;
    
    final pendientes = await db.query(
      _tableArticulos,
      where: 'pendiente_sincronizacion = 1 AND empresa_id = ?',
      whereArgs: [empresaId],
    );

    final articulosPendientes = pendientes.map((e) => Articulo.fromMap(e)).toList();
    
    for (final articulo in articulosPendientes) {
      try {
        if (articulo.firebaseId == null) {
          final newFirebaseId = await articuloService.agregarArticulo(articulo);
          
          await db.update(
            _tableArticulos,
            {
              'firebase_id': newFirebaseId,
              'sincronizado': 1,
              'pendiente_sincronizacion': 0,
              'fecha_ultima_sincronizacion': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [articulo.id],
          );
        } else {
          await articuloService.actualizarArticulo(articulo);
          
          await db.update(
            _tableArticulos,
            {
              'sincronizado': 1,
              'pendiente_sincronizacion': 0,
              'fecha_ultima_sincronizacion': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [articulo.id],
          );
        }
      } catch (e) {
        await db.update(
          _tableArticulos,
          {
            'conflicto': 'Error al sincronizar: ${e.toString()}',
          },
          where: 'id = ?',
          whereArgs: [articulo.id],
        );
      }
    }
  }

  Future<void> _descargarActualizaciones(
    String empresaId, 
    ArticuloService articuloService
  ) async {
    final db = await database;
    final stream = articuloService.getArticulosActivos();
    
    await for (final articulosFirebase in stream) {
      for (final articuloFirebase in articulosFirebase) {
        final local = await db.query(
          _tableArticulos,
          where: 'firebase_id = ?',
          whereArgs: [articuloFirebase.firebaseId],
        );

        if (local.isEmpty) {
          await insertarArticulo(articuloFirebase);
        } else {
          final localMap = local.first;
          final fechaLocalStr = localMap['fecha_actualizacion'] as String?;
          
          if (fechaLocalStr != null) {
            final fechaLocal = DateTime.parse(fechaLocalStr);
            
            if (articuloFirebase.fechaActualizacion.isAfter(fechaLocal)) {
              await db.update(
                _tableArticulos,
                {
                  ...articuloFirebase.toMap(),
                  'sincronizado': 1,
                  'pendiente_sincronizacion': 0,
                  'fecha_ultima_sincronizacion': DateTime.now().toIso8601String(),
                },
                where: 'firebase_id = ?',
                whereArgs: [articuloFirebase.firebaseId],
              );
            }
          }
        }
      }
    }
  }

  Future<bool> estaConectado() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> obtenerEstadoSincronizacion(String empresaId) async {
    final db = await database;
    
    final total = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableArticulos WHERE empresa_id = ?',
      [empresaId],
    );
    
    final sincronizados = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableArticulos WHERE empresa_id = ? AND sincronizado = 1',
      [empresaId],
    );
    
    final pendientes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableArticulos WHERE empresa_id = ? AND pendiente_sincronizacion = 1',
      [empresaId],
    );
    
    final conConflictos = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableArticulos WHERE empresa_id = ? AND conflicto IS NOT NULL',
      [empresaId],
    );

    return {
      'total': total.first['count'] as int,
      'sincronizados': sincronizados.first['count'] as int,
      'pendientes': pendientes.first['count'] as int,
      'conflictos': conConflictos.first['count'] as int,
    };
  }

  Future<void> limpiarConflictos(String empresaId) async {
    final db = await database;
    await db.update(
      _tableArticulos,
      {'conflicto': null},
      where: 'empresa_id = ? AND conflicto IS NOT NULL',
      whereArgs: [empresaId],
    );
  }

  Future<void> marcarPendienteSincronizacion(int articuloId) async {
    final db = await database;
    await db.update(
      _tableArticulos,
      {
        'pendiente_sincronizacion': 1,
        'sincronizado': 0,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [articuloId],
    );
  }
}
