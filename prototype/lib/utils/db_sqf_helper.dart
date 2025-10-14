import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBSqfHelper {
  static Database? _db;

  // Fungsi global untuk mendapatkan instance database
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Inisialisasi database
  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');

    final db = await openDatabase(
      path,
      version: 3, // ⬅️ naikkan versi agar trigger _onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // 🔍 Pastikan tabel wajib selalu ada
    await _ensureTablesExist(db);
    // 🔍 Pastikan kolom tambahan ada
    await _ensureColumnsExist(db);

    return db;
  }

  // Buat tabel ketika database pertama kali dibuat
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pertanyaan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pertanyaan_response TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE jawaban(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jawaban_response TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE opsi_jawaban(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        part_index INTEGER,
        opsi_response TEXT
      )
    ''');
  }

  // Upgrade database jika versi berubah
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Jika upgrade dari versi lama yang belum punya opsi_jawaban
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE opsi_jawaban(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          opsi_response TEXT
        )
      ''');
    }

    // Jika versi < 3, tambahkan kolom part_index
    if (oldVersion < 3) {
      final columns = await _getTableColumns(db, 'opsi_jawaban');
      if (!columns.contains('part_index')) {
        debugPrint("🛠️ Menambahkan kolom part_index ke tabel opsi_jawaban...");
        await db.execute(
          'ALTER TABLE opsi_jawaban ADD COLUMN part_index INTEGER',
        );
      }
    }
  }

  // Pastikan semua tabel penting ada
  static Future<void> _ensureTablesExist(Database db) async {
    final requiredTables = {
      'pertanyaan': '''
        CREATE TABLE pertanyaan(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pertanyaan_response TEXT
        )
      ''',
      'jawaban': '''
        CREATE TABLE jawaban(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          jawaban_response TEXT
        )
      ''',
      'opsi_jawaban': '''
        CREATE TABLE opsi_jawaban(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          part_index INTEGER,
          opsi_response TEXT
        )
      ''',
    };

    for (final table in requiredTables.entries) {
      final exists = await _isTableExists(db, table.key);
      if (!exists) {
        debugPrint("🆕 Membuat tabel baru: ${table.key}");
        await db.execute(table.value);
      }
    }
  }

  // 🔧 Pastikan kolom tambahan ada
  static Future<void> _ensureColumnsExist(Database db) async {
    final columns = await _getTableColumns(db, 'opsi_jawaban');
    if (!columns.contains('part_index')) {
      debugPrint("🛠️ Menambahkan kolom part_index ke opsi_jawaban...");
      await db.execute(
        'ALTER TABLE opsi_jawaban ADD COLUMN part_index INTEGER',
      );
    }
  }

  // Helper untuk mengambil daftar kolom tabel
  static Future<List<String>> _getTableColumns(
    Database db,
    String tableName,
  ) async {
    final res = await db.rawQuery('PRAGMA table_info($tableName)');
    return res.map((e) => e['name'] as String).toList();
  }

  // Cek apakah tabel sudah ada
  static Future<bool> _isTableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // ==== Fungsi CRUD umum ====

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  static Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  static Future<List<Map<String, dynamic>>> getAllPaginated(
    String table, {
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(table, limit: limit, offset: offset);
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List args,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: args);
  }

  static Future<int> delete(String table, String where, List args) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: args);
  }

  static Future<int> bulkDelete(String table, List<int> ids) async {
    if (ids.isEmpty) {
      debugPrint("⚠️ bulkDelete: Tidak ada ID untuk dihapus.");
      return 0;
    }

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    return await db.delete(
      table,
      where: 'id IN ($placeholders)',
      whereArgs: ids.cast<Object?>(),
    );
  }

  static Future<int> deleteAll(String table) async {
    final db = await database;
    return await db.delete(table);
  }
}
