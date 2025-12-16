import 'package:json_annotation/json_annotation.dart';

part 'sensor_data_model.g.dart';

/// Modèle pour les données de capteurs IoT
@JsonSerializable()
class SensorDataModel {
  final int? id;
  @JsonKey(name: 'sensor_id')
  final String sensorId; // Identifiant unique du capteur
  @JsonKey(name: 'sensor_type')
  final String sensorType; // Type: 'soil_moisture', 'ph', 'temperature', 'nutrients', etc.
  @JsonKey(name: 'sensor_name')
  final String? sensorName; // Nom du capteur (optionnel)
  final double value; // Valeur mesurée
  final String unit; // Unité de mesure (%, pH, °C, mg/kg, etc.)
  final double? latitude; // Coordonnées GPS (optionnel)
  final double? longitude;
  @JsonKey(name: 'parcelle_id')
  final int? parcelleId; // Parcelle associée (optionnel)
  @JsonKey(name: 'exploitation_id')
  final int? exploitationId; // Exploitation associée (optionnel)
  @JsonKey(name: 'timestamp')
  final String timestamp; // Date/heure de la mesure
  @JsonKey(name: 'battery_level')
  final int? batteryLevel; // Niveau de batterie du capteur (%)
  @JsonKey(name: 'signal_strength')
  final int? signalStrength; // Force du signal (dBm)
  final Map<String, dynamic>? metadata; // Données supplémentaires (JSON)
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  SensorDataModel({
    this.id,
    required this.sensorId,
    required this.sensorType,
    this.sensorName,
    required this.value,
    required this.unit,
    this.latitude,
    this.longitude,
    this.parcelleId,
    this.exploitationId,
    required this.timestamp,
    this.batteryLevel,
    this.signalStrength,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) =>
      _$SensorDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataModelToJson(this);

  /// Convertit les données de capteur en données d'analyse de sol
  Map<String, dynamic> toAnalyseSolData() {
    final data = <String, dynamic>{};

    switch (sensorType.toLowerCase()) {
      case 'soil_moisture':
      case 'humidite':
        data['humidite'] = value;
        break;
      case 'ph':
        data['ph'] = value;
        break;
      case 'nitrogen':
      case 'azote':
      case 'n':
        data['azote_n'] = value;
        break;
      case 'phosphorus':
      case 'phosphore':
      case 'p':
        data['phosphore_p'] = value;
        break;
      case 'potassium':
      case 'potassium_k':
      case 'k':
        data['potassium_k'] = value;
        break;
      case 'temperature':
        // La température peut être stockée dans metadata
        if (metadata != null) {
          data['metadata'] = {...metadata!, 'temperature': value};
        } else {
          data['metadata'] = {'temperature': value};
        }
        break;
    }

    // Ajouter les coordonnées GPS si disponibles
    if (latitude != null && longitude != null) {
      if (data['metadata'] == null) {
        data['metadata'] = {};
      }
      data['metadata']!['latitude'] = latitude;
      data['metadata']!['longitude'] = longitude;
    }

    return data;
  }

  /// Vérifie si les données sont valides
  bool isValid() {
    if (sensorId.isEmpty || sensorType.isEmpty || unit.isEmpty) {
      return false;
    }
    // Vérifier que la valeur est dans une plage raisonnable selon le type
    switch (sensorType.toLowerCase()) {
      case 'ph':
        return value >= 0 && value <= 14;
      case 'soil_moisture':
      case 'humidite':
        return value >= 0 && value <= 100;
      case 'nitrogen':
      case 'phosphorus':
      case 'potassium':
        return value >= 0 && value <= 10000; // mg/kg max
      default:
        return true;
    }
  }
}

/// Modèle pour un capteur IoT
@JsonSerializable()
class SensorModel {
  final int? id;
  @JsonKey(name: 'sensor_id')
  final String sensorId;
  @JsonKey(name: 'sensor_name')
  final String sensorName;
  @JsonKey(name: 'sensor_type')
  final String sensorType;
  final String? description;
  @JsonKey(name: 'parcelle_id')
  final int? parcelleId;
  @JsonKey(name: 'exploitation_id')
  final int? exploitationId;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'last_reading')
  final String? lastReading;
  @JsonKey(name: 'battery_level')
  final int? batteryLevel;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  SensorModel({
    this.id,
    required this.sensorId,
    required this.sensorName,
    required this.sensorType,
    this.description,
    this.parcelleId,
    this.exploitationId,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.lastReading,
    this.batteryLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) =>
      _$SensorModelFromJson(json);
  Map<String, dynamic> toJson() => _$SensorModelToJson(this);
}

