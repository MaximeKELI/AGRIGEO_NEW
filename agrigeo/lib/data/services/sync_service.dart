import 'dart:convert';
import '../../core/utils/network_info.dart';
import '../datasources/api_service.dart';
import '../datasources/local_database.dart';
import '../repositories/exploitation_repository.dart';

/// Service de synchronisation des données hors-ligne
class SyncService {
  final LocalDatabase _localDb;
  final ApiService _apiService;
  final NetworkInfo _networkInfo;

  SyncService({
    LocalDatabase? localDb,
    ApiService? apiService,
    NetworkInfo? networkInfo,
  })  : _localDb = localDb ?? LocalDatabase(),
        _apiService = apiService ?? ApiService(),
        _networkInfo = networkInfo ?? NetworkInfoImpl();

  /// Synchronise toutes les données non synchronisées
  Future<SyncResult> syncAll() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return SyncResult(
        success: false,
        message: 'Pas de connexion internet',
        syncedCount: 0,
      );
    }

    int syncedCount = 0;
    List<String> errors = [];

    try {
      // Synchroniser les exploitations
      final exploitationsResult = await _syncExploitations();
      syncedCount += exploitationsResult.syncedCount;
      if (exploitationsResult.errors.isNotEmpty) {
        errors.addAll(exploitationsResult.errors);
      }

      // Synchroniser les analyses de sol
      final analysesResult = await _syncAnalysesSols();
      syncedCount += analysesResult.syncedCount;
      if (analysesResult.errors.isNotEmpty) {
        errors.addAll(analysesResult.errors);
      }

      // Synchroniser les intrants
      final intrantsResult = await _syncIntrants();
      syncedCount += intrantsResult.syncedCount;
      if (intrantsResult.errors.isNotEmpty) {
        errors.addAll(intrantsResult.errors);
      }

      // Traiter la queue de synchronisation
      final queueResult = await _processSyncQueue();
      syncedCount += queueResult.syncedCount;
      if (queueResult.errors.isNotEmpty) {
        errors.addAll(queueResult.errors);
      }

      return SyncResult(
        success: errors.isEmpty,
        message: errors.isEmpty
            ? '$syncedCount éléments synchronisés avec succès'
            : '$syncedCount éléments synchronisés, ${errors.length} erreurs',
        syncedCount: syncedCount,
        errors: errors,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Erreur lors de la synchronisation: ${e.toString()}',
        syncedCount: syncedCount,
        errors: [e.toString()],
      );
    }
  }

  Future<SyncResult> _syncExploitations() async {
    final unsynced = await _localDb.getUnsyncedItems(LocalDatabase.tableExploitations);
    int syncedCount = 0;
    List<String> errors = [];

    for (final item in unsynced) {
      try {
        final data = Map<String, dynamic>.from(item);
        data.remove('id');
        data.remove('server_id');
        data.remove('synced');

        final response = await _apiService.createExploitation(data);
        final serverId = response.data['exploitation']['id'];
        await _localDb.markAsSynced(
          LocalDatabase.tableExploitations,
          item['id'] as int,
          serverId,
        );
        syncedCount++;
      } catch (e) {
        errors.add('Exploitation ${item['id']}: ${e.toString()}');
      }
    }

    return SyncResult(
      success: errors.isEmpty,
      syncedCount: syncedCount,
      errors: errors,
    );
  }

  Future<SyncResult> _syncAnalysesSols() async {
    final unsynced = await _localDb.getUnsyncedItems(LocalDatabase.tableAnalysesSols);
    int syncedCount = 0;
    List<String> errors = [];

    for (final item in unsynced) {
      try {
        final data = Map<String, dynamic>.from(item);
        data.remove('id');
        data.remove('server_id');
        data.remove('synced');

        final response = await _apiService.createAnalyseSol(data);
        final serverId = response.data['analyse']['id'];
        await _localDb.markAsSynced(
          LocalDatabase.tableAnalysesSols,
          item['id'] as int,
          serverId,
        );
        syncedCount++;
      } catch (e) {
        errors.add('Analyse ${item['id']}: ${e.toString()}');
      }
    }

    return SyncResult(
      success: errors.isEmpty,
      syncedCount: syncedCount,
      errors: errors,
    );
  }

  Future<SyncResult> _syncIntrants() async {
    final unsynced = await _localDb.getUnsyncedItems(LocalDatabase.tableIntrants);
    int syncedCount = 0;
    List<String> errors = [];

    for (final item in unsynced) {
      try {
        final data = Map<String, dynamic>.from(item);
        data.remove('id');
        data.remove('server_id');
        data.remove('synced');

        final response = await _apiService.createIntrant(data);
        final serverId = response.data['intrant']['id'];
        await _localDb.markAsSynced(
          LocalDatabase.tableIntrants,
          item['id'] as int,
          serverId,
        );
        syncedCount++;
      } catch (e) {
        errors.add('Intrant ${item['id']}: ${e.toString()}');
      }
    }

    return SyncResult(
      success: errors.isEmpty,
      syncedCount: syncedCount,
      errors: errors,
    );
  }

  Future<SyncResult> _processSyncQueue() async {
    final queue = await _localDb.getSyncQueue();
    int syncedCount = 0;
    List<String> errors = [];

    for (final item in queue) {
      try {
        // Traiter l'action de la queue
        // TODO: Implémenter selon le type d'action
        await _localDb.removeFromSyncQueue(item['id'] as int);
        syncedCount++;
      } catch (e) {
        errors.add('Queue item ${item['id']}: ${e.toString()}');
        // Incrémenter retry_count
      }
    }

    return SyncResult(
      success: errors.isEmpty,
      syncedCount: syncedCount,
      errors: errors,
    );
  }

  /// Télécharge les données depuis le serveur et les met à jour localement
  Future<void> downloadFromServer() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return;

    try {
      // Télécharger les exploitations
      final exploitations = await _apiService.getExploitations();
      // TODO: Sauvegarder localement

      // Télécharger les analyses
      // TODO: Implémenter

      // Télécharger les intrants
      // TODO: Implémenter
    } catch (e) {
      // Gérer l'erreur
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    this.errors = const [],
  });
}

