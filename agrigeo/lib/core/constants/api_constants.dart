/// Constantes pour l'API
class ApiConstants {
  static const String baseUrl = 'http://localhost:5000/api';
  // Pour Android emulator: 'http://10.0.2.2:5000/api'
  // Pour iOS simulator: 'http://localhost:5000/api'
  // Pour device physique: 'http://<IP_SERVEUR>:5000/api'
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String publicRoles = '/auth/roles';
  
  // Users endpoints
  static const String users = '/users';
  static const String roles = '/users/roles';
  
  // Exploitations endpoints
  static const String exploitations = '/exploitations';
  
  // Parcelles endpoints
  static const String parcelles = '/parcelles';
  
  // Analyses sols endpoints
  static const String analysesSols = '/analyses-sols';
  
  // Données climatiques endpoints
  static const String donneesClimatiques = '/donnees-climatiques';
  
  // Intrants endpoints
  static const String intrants = '/intrants';
  
  // Recommandations endpoints
  static const String recommandations = '/recommandations';
  
  // Sensors endpoints
  static const String sensors = '/sensors';
  static const String sensorData = '/sensors/data';
  
  // Recoltes endpoints
  static const String recoltes = '/recoltes';
  static const String recoltesStatistics = '/recoltes/statistics';
  static const String recoltesPrevision = '/recoltes/prevision';
  static const String recoltesImport = '/recoltes/import';
}

