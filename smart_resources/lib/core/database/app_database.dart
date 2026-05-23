import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'smart_resources.db');

    return openDatabase(
      path,
      version: 8, // Incremented version for notifications table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT,
        status TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE resources(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        courseCode TEXT,
        rating REAL,
        reviewCount INTEGER,
        uses INTEGER,
        fileType TEXT,
        uploader TEXT,
        isApproved INTEGER,
        isBookmarked INTEGER,
        isDownloaded INTEGER,
        file_path TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE requests(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        courseCode TEXT,
        requestedBy TEXT,
        time TEXT,
        status TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE bookmarks(
        user_id TEXT,
        resource_id TEXT,
        PRIMARY KEY(user_id, resource_id)
      );
    ''');

    await db.execute('''
      CREATE TABLE reviews(
        id TEXT PRIMARY KEY,
        resource_id TEXT,
        user_id TEXT,
        user_name TEXT,
        rating REAL,
        comment TEXT,
        time TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE activities(
        id TEXT PRIMARY KEY,
        user_id TEXT,
        user_name TEXT,
        type TEXT,
        title TEXT,
        time TEXT,
        reference_id TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        title TEXT,
        message TEXT,
        time TEXT,
        is_read INTEGER
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmarks(
          user_id TEXT,
          resource_id TEXT,
          PRIMARY KEY(user_id, resource_id)
        );
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reviews(
          id TEXT PRIMARY KEY,
          resource_id TEXT,
          user_id TEXT,
          user_name TEXT,
          rating REAL,
          comment TEXT,
          time TEXT
        );
      ''');
    }
    if (oldVersion < 4) {
      await db.delete('resources');
      await db.delete('requests');
      await db.delete('bookmarks');
      await db.delete('reviews');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activities(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          type TEXT,
          title TEXT,
          time TEXT,
          reference_id TEXT
        );
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('DROP TABLE IF EXISTS activities');
      await db.execute('''
        CREATE TABLE activities(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          user_name TEXT,
          type TEXT,
          title TEXT,
          time TEXT,
          reference_id TEXT
        );
      ''');
    }
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE resources ADD COLUMN file_path TEXT');
      } catch (e) {}
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications(
          id TEXT PRIMARY KEY,
          title TEXT,
          message TEXT,
          time TEXT,
          is_read INTEGER
        );
      ''');
    }
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool distinct = false,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }
}
