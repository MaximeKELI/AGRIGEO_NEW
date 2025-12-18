# Intégration des Capteurs IoT - Documentation

## Vue d'ensemble

Le système d'analyse du sol a été étendu pour supporter l'intégration de données provenant de capteurs IoT. Les capteurs peuvent envoyer automatiquement leurs données qui seront intégrées dans les analyses de sol.

## Architecture

### Backend

#### Modèles

1. **Sensor** (`backend/models/sensor.py`)
   - Représente un capteur IoT enregistré
   - Champs : `sensor_id`, `sensor_name`, `sensor_type`, `parcelle_id`, `exploitation_id`, `latitude`, `longitude`, `is_active`, etc.

2. **SensorData** (`backend/models/sensor.py`)
   - Représente une mesure individuelle d'un capteur
   - Champs : `sensor_id`, `sensor_type`, `value`, `unit`, `timestamp`, `battery_level`, `signal_strength`, `metadata`, etc.

3. **AnalyseSol** (modifié)
   - Nouveaux champs :
     - `sensor_data` : JSON des données de capteurs utilisées
     - `sensor_ids` : Liste des IDs de capteurs (JSON array)
     - `data_source` : 'manual', 'sensor', ou 'mixed'

#### Routes API

**`/api/sensors`** - Gestion des capteurs
- `GET /api/sensors` : Liste des capteurs
- `POST /api/sensors` : Enregistrer un nouveau capteur
- `GET /api/sensors/<id>` : Récupérer un capteur
- `PUT /api/sensors/<id>` : Mettre à jour un capteur

**`/api/sensors/data`** - Données des capteurs
- `POST /api/sensors/data` : Recevoir des données de capteur (endpoint public)
- `GET /api/sensors/data` : Récupérer les données de capteurs (avec filtres)

**`/api/analyses-sols`** (modifié)
- `POST /api/analyses-sols` : Accepte maintenant `sensor_data` dans le payload

### Frontend

#### Modèles

1. **SensorModel** (`lib/data/models/sensor_data_model.dart`)
   - Modèle pour un capteur IoT

2. **SensorDataModel** (`lib/data/models/sensor_data_model.dart`)
   - Modèle pour les données d'un capteur
   - Méthode `toAnalyseSolData()` : Convertit les données de capteur en données d'analyse

3. **AnalyseSolModel** (modifié)
   - Nouveaux champs : `sensorData`, `sensorIds`, `dataSource`

#### Services

**SensorService** (`lib/data/services/sensor_service.dart`)
- `getSensors()` : Récupère la liste des capteurs
- `getSensorData()` : Récupère les données d'un capteur
- `sendSensorData()` : Envoie des données de capteur
- `convertSensorDataToAnalyseSol()` : Convertit les données de capteurs en données d'analyse
- `getLatestSensorDataForAnalyse()` : Récupère les dernières données pour créer une analyse

## Types de capteurs supportés

### Types de capteurs reconnus

1. **soil_moisture** / **humidite**
   - Mesure : Humidité du sol (%)
   - Mappe vers : `humidite` dans AnalyseSol

2. **ph**
   - Mesure : pH du sol
   - Mappe vers : `ph` dans AnalyseSol

3. **nitrogen** / **azote** / **n**
   - Mesure : Azote (mg/kg)
   - Mappe vers : `azote_n` dans AnalyseSol

4. **phosphorus** / **phosphore** / **p**
   - Mesure : Phosphore (mg/kg)
   - Mappe vers : `phosphore_p` dans AnalyseSol

5. **potassium** / **k**
   - Mesure : Potassium (mg/kg)
   - Mappe vers : `potassium_k` dans AnalyseSol

6. **temperature**
   - Mesure : Température (°C)
   - Stocké dans `metadata`

## Utilisation

### 1. Enregistrer un capteur

```dart
final sensorService = SensorService();
final sensor = SensorModel(
  sensorId: 'SENSOR_001',
  sensorName: 'Capteur humidité Parcelle A',
  sensorType: 'soil_moisture',
  exploitationId: 1,
  parcelleId: 1,
  latitude: 6.1375,
  longitude: 1.2123,
);

await sensorService.createSensor(sensor);
```

### 2. Recevoir des données de capteur (depuis le capteur IoT)

```dart
final sensorData = SensorDataModel(
  sensorId: 'SENSOR_001',
  sensorType: 'soil_moisture',
  value: 45.5,
  unit: '%',
  timestamp: DateTime.now().toIso8601String(),
  exploitationId: 1,
  parcelleId: 1,
  batteryLevel: 85,
);

await sensorService.sendSensorData(sensorData);
```

### 3. Créer une analyse avec données de capteurs

```dart
// Option 1 : Utiliser les dernières données de capteurs
final sensorService = SensorService();
final latestData = await sensorService.getLatestSensorDataForAnalyse(
  exploitationId: 1,
  parcelleId: 1,
);

final analyseData = {
  ...latestData,
  'date_prelevement': '2024-01-15',
  'technicien_id': currentUserId,
};

await apiService.createAnalyseSol(analyseData);

// Option 2 : Fournir manuellement les données de capteurs
final sensorDataList = [
  SensorDataModel(
    sensorId: 'SENSOR_001',
    sensorType: 'soil_moisture',
    value: 45.5,
    unit: '%',
    timestamp: DateTime.now().toIso8601String(),
  ),
  SensorDataModel(
    sensorId: 'SENSOR_002',
    sensorType: 'ph',
    value: 6.8,
    unit: 'pH',
    timestamp: DateTime.now().toIso8601String(),
  ),
];

final analyseData = sensorService.convertSensorDataToAnalyseSol(
  sensorDataList: sensorDataList,
  datePrelevement: '2024-01-15',
  exploitationId: 1,
  parcelleId: 1,
  observations: 'Analyse basée sur données capteurs',
);

await apiService.createAnalyseSol(analyseData);
```

### 4. Format JSON pour l'API

**Créer une analyse avec données de capteurs :**

```json
{
  "date_prelevement": "2024-01-15",
  "exploitation_id": 1,
  "parcelle_id": 1,
  "sensor_data": [
    {
      "sensor_id": "SENSOR_001",
      "sensor_type": "soil_moisture",
      "value": 45.5,
      "unit": "%",
      "timestamp": "2024-01-15T10:30:00Z"
    },
    {
      "sensor_id": "SENSOR_002",
      "sensor_type": "ph",
      "value": 6.8,
      "unit": "pH",
      "timestamp": "2024-01-15T10:30:00Z"
    }
  ],
  "observations": "Analyse automatique depuis capteurs"
}
```

**Envoyer des données de capteur :**

```json
{
  "sensor_id": "SENSOR_001",
  "sensor_type": "soil_moisture",
  "value": 45.5,
  "unit": "%",
  "timestamp": "2024-01-15T10:30:00Z",
  "exploitation_id": 1,
  "parcelle_id": 1,
  "latitude": 6.1375,
  "longitude": 1.2123,
  "battery_level": 85,
  "signal_strength": -65,
  "metadata": {
    "temperature": 25.5,
    "pressure": 1013.25
  }
}
```

## Sources de données

Le champ `data_source` dans AnalyseSol indique la source des données :

- **`manual`** : Analyse créée manuellement (par défaut)
- **`sensor`** : Analyse créée uniquement à partir de données de capteurs
- **`mixed`** : Analyse combinant données manuelles et données de capteurs

## Validation

Les données de capteurs sont validées selon leur type :

- **pH** : Entre 0 et 14
- **Humidité** : Entre 0 et 100%
- **Nutriments** : Entre 0 et 10000 mg/kg

## Sécurité

- L'endpoint `/api/sensors/data` (POST) est public pour permettre aux capteurs IoT d'envoyer des données
- Il est recommandé d'ajouter une authentification par API key pour sécuriser cet endpoint en production
- Les capteurs doivent être enregistrés avant de pouvoir envoyer des données

## Exemple d'intégration complète

```dart
// 1. Enregistrer le capteur
final sensor = SensorModel(
  sensorId: 'SENSOR_001',
  sensorName: 'Capteur Parcelle A',
  sensorType: 'soil_moisture',
  exploitationId: 1,
  parcelleId: 1,
);
await sensorService.createSensor(sensor);

// 2. Le capteur envoie des données périodiquement
// (simulé ici, mais normalement fait par le capteur IoT)
final sensorData = SensorDataModel(
  sensorId: 'SENSOR_001',
  sensorType: 'soil_moisture',
  value: 45.5,
  unit: '%',
  timestamp: DateTime.now().toIso8601String(),
  exploitationId: 1,
  parcelleId: 1,
);
await sensorService.sendSensorData(sensorData);

// 3. Créer une analyse à partir des données de capteurs
final latestData = await sensorService.getLatestSensorDataForAnalyse(
  exploitationId: 1,
  parcelleId: 1,
);

final analyseData = {
  ...latestData,
  'date_prelevement': DateTime.now().toIso8601String().split('T')[0],
  'technicien_id': currentUserId,
};

final response = await apiService.createAnalyseSol(analyseData);
```

## Prochaines étapes

- [ ] Créer une interface utilisateur pour visualiser les capteurs
- [ ] Ajouter des graphiques pour visualiser les données de capteurs dans le temps
- [ ] Implémenter des alertes basées sur les seuils de capteurs
- [ ] Ajouter l'authentification par API key pour les capteurs
- [ ] Créer un dashboard de monitoring des capteurs




