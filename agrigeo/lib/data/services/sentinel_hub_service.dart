import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Service pour interagir avec l'API Sentinel Hub
/// Documentation: https://docs.sentinel-hub.com/
class SentinelHubService {
  final Dio _dio;
  String? _apiKey;
  String? _apiSecret;
  String? _accessToken;
  DateTime? _tokenExpiry;

  // Base URL de l'API Sentinel Hub
  static const String baseUrl = 'https://services.sentinel-hub.com';
  static const String oauthUrl = 'https://services.sentinel-hub.com/oauth/token';

  SentinelHubService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  /// Configure les credentials Sentinel Hub
  Future<void> setCredentials({
    required String apiKey,
    required String apiSecret,
  }) async {
    _apiKey = apiKey;
    _apiSecret = apiSecret;

    // Sauvegarder dans les préférences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.sentinelHubApiKey, apiKey);
    await prefs.setString('${AppConstants.sentinelHubApiKey}_secret', apiSecret);

    // Obtenir un nouveau token
    await _getAccessToken();
  }

  /// Charge les credentials depuis le stockage
  Future<void> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.sentinelHubApiKey);
    final apiSecret = prefs.getString('${AppConstants.sentinelHubApiKey}_secret');

    if (apiKey != null && apiSecret != null) {
      _apiKey = apiKey;
      _apiSecret = apiSecret;
      await _getAccessToken();
    }
  }

  /// Obtient un token d'accès OAuth
  Future<void> _getAccessToken() async {
    if (_apiKey == null || _apiSecret == null) {
      throw Exception('Credentials Sentinel Hub non configurés');
    }

    try {
      final response = await _dio.post(
        oauthUrl,
        data: {
          'grant_type': 'client_credentials',
          'client_id': _apiKey,
          'client_secret': _apiSecret,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      _accessToken = response.data['access_token'];
      final expiresIn = response.data['expires_in'] as int;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60)); // Marge de sécurité
    } catch (e) {
      throw Exception('Erreur lors de l\'obtention du token Sentinel Hub: $e');
    }
  }

  /// Vérifie et renouvelle le token si nécessaire
  Future<void> _ensureValidToken() async {
    if (_accessToken == null ||
        _tokenExpiry == null ||
        DateTime.now().isAfter(_tokenExpiry!)) {
      await _getAccessToken();
    }
  }

  /// Récupère des données satellite pour une zone géographique
  /// [bbox] : Bounding box [minLon, minLat, maxLon, maxLat]
  /// [time] : Période de temps (format ISO ou "latest")
  /// [layers] : Couches à récupérer (ex: "TRUE_COLOR", "NDVI", "EVI")
  Future<Map<String, dynamic>> getSatelliteData({
    required List<double> bbox,
    String time = 'latest',
    List<String>? layers,
    int width = 512,
    int height = 512,
  }) async {
    await _ensureValidToken();

    if (_accessToken == null) {
      throw Exception('Token Sentinel Hub non disponible');
    }

    try {
      // Construire la requête Process API
      final requestBody = {
        'input': {
          'bounds': {
            'bbox': bbox,
            'properties': {'crs': 'http://www.opengis.net/def/crs/EPSG/0/4326'}
          },
          'data': [
            {
              'type': 'sentinel-2-l2a',
              'dataFilter': {
                'timeRange': {
                  'from': _getTimeRangeStart(time),
                  'to': _getTimeRangeEnd(time),
                }
              }
            }
          ]
        },
        'output': {
          'width': width,
          'height': height,
          'responses': [
            {
              'identifier': 'default',
              'format': {'type': 'image/png'}
            }
          ]
        },
        'evalscript': _buildEvalScript(layers ?? ['TRUE_COLOR']),
      };

      final response = await _dio.post(
        '$baseUrl/api/v1/process',
        data: requestBody,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données satellite: $e');
    }
  }

  /// Récupère l'image satellite en base64
  Future<String> getSatelliteImage({
    required List<double> bbox,
    String time = 'latest',
    List<String>? layers,
    int width = 512,
    int height = 512,
  }) async {
    final data = await getSatelliteData(
      bbox: bbox,
      time: time,
      layers: layers,
      width: width,
      height: height,
    );

    // L'image est retournée en base64 dans la réponse
    if (data['outputs'] != null && data['outputs']['default'] != null) {
      return data['outputs']['default']['data'];
    }

    throw Exception('Aucune image trouvée dans la réponse');
  }

  /// Récupère les indices de végétation (NDVI, EVI) pour une zone
  Future<Map<String, dynamic>> getVegetationIndices({
    required List<double> bbox,
    String time = 'latest',
  }) async {
    final ndviData = await getSatelliteData(
      bbox: bbox,
      time: time,
      layers: ['NDVI'],
    );

    final eviData = await getSatelliteData(
      bbox: bbox,
      time: time,
      layers: ['EVI'],
    );

    return {
      'ndvi': ndviData,
      'evi': eviData,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Construit le script d'évaluation pour les couches demandées
  String _buildEvalScript(List<String> layers) {
    final scripts = <String>[];

    for (final layer in layers) {
      switch (layer.toUpperCase()) {
        case 'TRUE_COLOR':
          scripts.add('''
            return [B04, B03, B02];
          ''');
          break;
        case 'FALSE_COLOR':
          scripts.add('''
            return [B08, B04, B03];
          ''');
          break;
        case 'NDVI':
          scripts.add('''
            let ndvi = (B08 - B04) / (B08 + B04);
            return [ndvi];
          ''');
          break;
        case 'EVI':
          scripts.add('''
            let evi = 2.5 * ((B08 - B04) / (B08 + 6 * B04 - 7.5 * B02 + 1));
            return [evi];
          ''');
          break;
        default:
          scripts.add('return [B04, B03, B02];'); // True color par défaut
      }
    }

    return '''
      function setup() {
        return {
          input: [{
            bands: ["B02", "B03", "B04", "B08"]
          }],
          output: {
            bands: ${layers.length}
          }
        };
      }

      function evaluatePixel(samples) {
        ${scripts.join('\n        ')}
      }
    ''';
  }

  String _getTimeRangeStart(String time) {
    if (time == 'latest') {
      // Dernières 30 jours
      final date = DateTime.now().subtract(const Duration(days: 30));
      return date.toIso8601String();
    }
    return time;
  }

  String _getTimeRangeEnd(String time) {
    if (time == 'latest') {
      return DateTime.now().toIso8601String();
    }
    return time;
  }
}

