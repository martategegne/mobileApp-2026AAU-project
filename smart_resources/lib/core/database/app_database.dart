// Simple stub database layer for web compatibility
// For web, we primarily use the API backend as the source of truth
// This provides a compatible interface with the repository layer

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    // Initialize tables on first use
    _initialized = true;
  }

  // ── Same API as sqflite ───────────────────────────────────────────────────

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
    await _ensureInit();
    // For web, return empty - data comes from backend API
    return [];
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    await _ensureInit();
    // For web, just succeed silently - data stored in backend
    return 1;
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    await _ensureInit();
    // For web, just succeed silently
    return 1;
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    await _ensureInit();
    // For web, just succeed silently
    return 1;
  }
}
