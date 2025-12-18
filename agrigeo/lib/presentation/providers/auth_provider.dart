import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.register(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (await _repository.isLoggedIn()) {
        _user = await _repository.getCurrentUser();
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}




