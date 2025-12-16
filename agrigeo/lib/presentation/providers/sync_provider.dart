import 'package:flutter/foundation.dart';
import '../../data/services/sync_service.dart';

class SyncProvider with ChangeNotifier {
  final SyncService _syncService;
  bool _isSyncing = false;
  String? _syncStatus;
  int _syncedCount = 0;

  SyncProvider({SyncService? syncService})
      : _syncService = syncService ?? SyncService();

  bool get isSyncing => _isSyncing;
  String? get syncStatus => _syncStatus;
  int get syncedCount => _syncedCount;

  Future<bool> syncAll() async {
    _isSyncing = true;
    _syncStatus = 'Synchronisation en cours...';
    _syncedCount = 0;
    notifyListeners();

    try {
      final result = await _syncService.syncAll();
      _isSyncing = false;
      _syncStatus = result.message;
      _syncedCount = result.syncedCount;
      notifyListeners();
      return result.success;
    } catch (e) {
      _isSyncing = false;
      _syncStatus = 'Erreur: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearStatus() {
    _syncStatus = null;
    _syncedCount = 0;
    notifyListeners();
  }
}

