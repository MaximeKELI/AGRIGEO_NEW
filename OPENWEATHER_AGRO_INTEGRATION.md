# Intégration OpenWeather Agro API

Ce document décrit l'intégration de l'API OpenWeather Agro pour la gestion des polygones agricoles dans l'application AGRIGEO.

## Clé API

La clé API fournie est : `45d1412ba24561bcb4b9d4703638e077`

## Documentation

- **API Documentation**: https://agromonitoring.com/api/get
- **Dashboard**: https://agromonitoring.com/dashboard/dashboard-start
- **Guide des polygones**: https://agromonitoring.com/dashboard/dashboard-polygons

## Architecture

L'intégration suit l'architecture en couches de l'application :

### Modèles (`lib/data/models/openweather_polygon_model.dart`)

- `OpenWeatherPolygonModel` : Représente un polygone avec son ID, nom, surface et géométrie
- `GeoJson` : Structure GeoJSON pour la géométrie du polygone
- `PolygonWeatherData` : Données météo pour un polygone
- `PolygonSatelliteData` : Données satellite (NDVI, EVI, etc.) pour un polygone
- `CreatePolygonRequest` : Requête pour créer un polygone
- `UpdatePolygonNameRequest` : Requête pour mettre à jour le nom d'un polygone

### Service (`lib/data/services/openweather_agro_service.dart`)

Le service `OpenWeatherAgroService` fournit les méthodes suivantes :

- `createPolygon()` : Crée un nouveau polygone
- `listPolygons()` : Liste tous les polygones de l'utilisateur
- `getPolygon()` : Récupère les détails d'un polygone
- `updatePolygonName()` : Met à jour le nom d'un polygone
- `deletePolygon()` : Supprime un polygone
- `getPolygonWeather()` : Récupère les données météo d'un polygone
- `getPolygonSatelliteData()` : Récupère les données satellite (NDVI, EVI, etc.)
- `getPolygonSoilData()` : Récupère les données de sol

### Repository (`lib/data/repositories/openweather_polygon_repository.dart`)

Le repository `OpenWeatherPolygonRepository` encapsule le service et gère les erreurs selon le pattern de l'application.

## Utilisation

### 1. Configuration de la clé API

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrigeo/core/constants/app_constants.dart';
import 'package:agrigeo/data/repositories/openweather_polygon_repository.dart';

final prefs = await SharedPreferences.getInstance();
await prefs.setString(AppConstants.openWeatherAgroApiKey, '45d1412ba24561bcb4b9d4703638e077');
```

### 2. Créer un polygone

```dart
final repository = OpenWeatherPolygonRepository();
repository.setApiKey('45d1412ba24561bcb4b9d4703638e077');

// Coordonnées du polygone : [[lon, lat], [lon, lat], ...]
final coordinates = [
  [-0.5, 45.5],  // Point 1
  [0.5, 45.5],   // Point 2
  [0.5, 46.5],   // Point 3
  [-0.5, 46.5],  // Point 4
  [-0.5, 45.5],  // Fermer le polygone
];

final polygon = await repository.createPolygon(
  name: 'Mon exploitation',
  coordinates: coordinates,
);
```

### 3. Lister les polygones

```dart
final polygons = await repository.getPolygons();
for (final polygon in polygons) {
  print('Polygone: ${polygon.name}, Surface: ${polygon.area} ha');
}
```

### 4. Récupérer les données météo

```dart
final weather = await repository.getPolygonWeather(polygonId);
print('Température: ${weather.temp}°C');
print('Humidité: ${weather.humidity}%');
print('Précipitations: ${weather.precipitation} mm');
```

### 5. Récupérer les données satellite NDVI

```dart
final satelliteData = await repository.getPolygonSatelliteData(
  polygonId: polygonId,
  type: 'ndvi', // ou 'evi', 'truecolor', 'falsecolor'
);

for (final data in satelliteData) {
  print('NDVI: ${data.ndvi}, Date: ${data.dt}');
}
```

### 6. Mettre à jour le nom d'un polygone

```dart
final updatedPolygon = await repository.updatePolygonName(
  polygonId: polygonId,
  newName: 'Nouveau nom',
);
```

### 7. Supprimer un polygone

```dart
await repository.deletePolygon(polygonId);
```

## Exemple complet

Voir le fichier `lib/data/services/openweather_agro_example.dart` pour des exemples d'utilisation complets.

## Intégration avec les exploitations

Les polygones OpenWeather Agro peuvent être associés aux exploitations de l'application pour :

1. **Suivi météo précis** : Obtenir des données météo spécifiques à chaque exploitation
2. **Analyse satellite** : Suivre l'évolution de la végétation (NDVI, EVI)
3. **Données de sol** : Obtenir des informations sur l'humidité et la température du sol
4. **Recommandations** : Utiliser les données pour générer des recommandations agricoles

## Prochaines étapes

1. Créer un écran de configuration pour la clé API OpenWeather Agro (similaire à `config_meteo_screen.dart`)
2. Créer un écran de gestion des polygones
3. Intégrer les données météo et satellite dans les écrans d'exploitation
4. Créer un provider pour gérer l'état des polygones (similaire à `MeteoProvider`)

## Notes importantes

- La clé API doit être stockée de manière sécurisée
- Les coordonnées doivent être au format GeoJSON : `[[lon, lat], [lon, lat], ...]`
- Le polygone doit être fermé (le dernier point doit être identique au premier)
- Les données satellite peuvent avoir des délais de disponibilité

