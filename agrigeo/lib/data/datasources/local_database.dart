import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

/// Base de données SQLite locale pour le mode hors-ligne
class LocalDatabase {
  static Database? _database;
  static const String _dbName = AppConstants.databaseName;
  static const int _dbVersion = AppConstants.databaseVersion;

  // Tables
  static const String tableExploitations = 'exploitations';
  static const String tableAnalysesSols = 'analyses_sols';
  static const String tableIntrants = 'intrants';
  static const String tableSyncQueue = 'sync_queue';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table exploitations
    await db.execute('''
      CREATE TABLE $tableExploitations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        nom TEXT NOT NULL,
        localisation_texte TEXT,
        latitude REAL,
        longitude REAL,
        superficie_totale REAL NOT NULL,
        type_culture_principal TEXT,
        historique_cultural TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Table analyses_sols
    await db.execute('''
      CREATE TABLE $tableAnalysesSols (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        exploitation_id INTEGER NOT NULL,
        parcelle_id INTEGER,
        date_prelevement TEXT NOT NULL,
        ph REAL,
        humidite REAL,
        texture TEXT,
        azote_n REAL,
        phosphore_p REAL,
        potassium_k REAL,
        observations TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY (exploitation_id) REFERENCES $tableExploitations(id)
      )
    ''');

    // Table intrants
    await db.execute('''
      CREATE TABLE $tableIntrants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        exploitation_id INTEGER NOT NULL,
        parcelle_id INTEGER,
        type_intrant TEXT NOT NULL,
        nom_commercial TEXT,
        quantite REAL NOT NULL,
        unite TEXT DEFAULT 'kg',
        date_application TEXT NOT NULL,
        culture_concernée TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY (exploitation_id) REFERENCES $tableExploitations(id)
      )
    ''');

    // Table queue de synchronisation
    await db.execute('''
      CREATE TABLE $tableSyncQueue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_data TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Index pour améliorer les performances
    await db.execute('CREATE INDEX idx_exploitation_synced ON $tableExploitations(synced)');
    await db.execute('CREATE INDEX idx_analyse_exploitation ON $tableAnalysesSols(exploitation_id)');
    await db.execute('CREATE INDEX idx_intrant_exploitation ON $tableIntrants(exploitation_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gérer les migrations de schéma ici
  }

  // Méthodes pour exploitations
  Future<int> insertExploitation(Map<String, dynamic> exploitation) async {
    final db = await database;
    return await db.insert(tableExploitations, exploitation);
  }

  Future<List<Map<String, dynamic>>> getExploitations() async {
    final db = await database;
    return await db.query(tableExploitations, orderBy: 'created_at DESC');
  }

  Future<int> updateExploitation(int id, Map<String, dynamic> exploitation) async {
    final db = await database;
    return await db.update(
      tableExploitations,
      exploitation,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExploitation(int id) async {
    final db = await database;
    return await db.delete(
      tableExploitations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes pour analyses de sol
  Future<int> insertAnalyseSol(Map<String, dynamic> analyse) async {
    final db = await database;
    return await db.insert(tableAnalysesSols, analyse);
  }

  Future<List<Map<String, dynamic>>> getAnalysesSols({int? exploitationId}) async {
    final db = await database;
    if (exploitationId != null) {
      return await db.query(
        tableAnalysesSols,
        where: 'exploitation_id = ?',
        whereArgs: [exploitationId],
        orderBy: 'date_prelevement DESC',
      );
    }
    return await db.query(tableAnalysesSols, orderBy: 'date_prelevement DESC');
  }

  Future<int> updateAnalyseSol(int id, Map<String, dynamic> analyse) async {
    final db = await database;
    return await db.update(
      tableAnalysesSols,
      analyse,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAnalyseSol(int id) async {
    final db = await database;
    return await db.delete(
      tableAnalysesSols,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes pour intrants
  Future<int> insertIntrant(Map<String, dynamic> intrant) async {
    final db = await database;
    return await db.insert(tableIntrants, intrant);
  }

  Future<List<Map<String, dynamic>>> getIntrants({int? exploitationId}) async {
    final db = await database;
    if (exploitationId != null) {
      return await db.query(
        tableIntrants,
        where: 'exploitation_id = ?',
        whereArgs: [exploitationId],
        orderBy: 'date_application DESC',
      );
    }
    return await db.query(tableIntrants, orderBy: 'date_application DESC');
  }

  Future<int> updateIntrant(int id, Map<String, dynamic> intrant) async {
    final db = await database;
    return await db.update(
      tableIntrants,
      intrant,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIntrant(int id) async {
    final db = await database;
    return await db.delete(
      tableIntrants,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes pour queue de synchronisation
  Future<int> addToSyncQueue(String action, String entityType, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableSyncQueue, {
      'action': action,
      'entity_type': entityType,
      'entity_data': data.toString(), // JSON stringify dans l'implémentation réelle
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query(tableSyncQueue, orderBy: 'created_at ASC');
  }

  Future<int> removeFromSyncQueue(int id) async {
    final db = await database;
    return await db.delete(
      tableSyncQueue,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Marquer comme synchronisé
  Future<void> markAsSynced(String table, int localId, int serverId) async {
    final db = await database;
    await db.update(
      table,
      {'synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Récupérer les éléments non synchronisés
  Future<List<Map<String, dynamic>>> getUnsyncedItems(String table) async {
    final db = await database;
    return await db.query(
      table,
      where: 'synced = 0',
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

