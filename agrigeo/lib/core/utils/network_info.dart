/// Interface pour vérifier la connectivité réseau
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implémentation basique de NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Implémentation basique - peut être améliorée avec connectivity_plus
    return true;
  }
}

