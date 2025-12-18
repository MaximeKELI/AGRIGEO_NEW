# Localisation en temps réel

Ce document décrit l'intégration de la localisation en temps réel dans l'application AGRIGEO.

## Fonctionnalités

- ✅ Obtention de la position actuelle de l'utilisateur
- ✅ Suivi de la position en temps réel avec Stream
- ✅ Gestion des permissions de localisation
- ✅ Calcul de distance et de direction entre deux points
- ✅ Affichage de la précision, altitude, vitesse
- ✅ Support Android et iOS

## Architecture

### Modèle (`lib/data/models/user_location_model.dart`)

Le modèle `UserLocationModel` représente la position de l'utilisateur avec :
- Latitude et longitude
- Précision (en mètres)
- Altitude (en mètres)
- Vitesse (en m/s)
- Direction (en degrés)
- Timestamp

### Service (`lib/data/services/location_service.dart`)

Le service `LocationService` fournit :
- `getCurrentLocation()` : Obtient la position actuelle
- `getLastKnownLocation()` : Obtient la dernière position connue
- `watchPosition()` : Stream de positions en temps réel
- `checkAndRequestPermission()` : Gestion des permissions
- `calculateDistance()` : Calcul de distance entre deux points
- `calculateBearing()` : Calcul de direction entre deux points

### Provider (`lib/presentation/providers/location_provider.dart`)

Le provider `LocationProvider` gère l'état de la localisation :
- Position actuelle et dernière position connue
- État de chargement et erreurs
- Suivi en temps réel (start/stop)
- Configuration de la précision et du filtre de distance

## Utilisation

### 1. Configuration du Provider

Dans votre `main.dart` ou votre widget racine :

```dart
import 'package:provider/provider.dart';
import 'package:agrigeo/presentation/providers/location_provider.dart';

MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LocationProvider()),
    // ... autres providers
  ],
  child: MyApp(),
)
```

### 2. Obtenir la position actuelle

```dart
final locationProvider = context.read<LocationProvider>();

// Vérifier et demander les permissions
final hasPermission = await locationProvider.checkAndRequestPermission();

if (hasPermission) {
  // Obtenir la position
  await locationProvider.getCurrentLocation();
  
  final location = locationProvider.currentLocation;
  if (location != null) {
    print('Latitude: ${location.latitude}');
    print('Longitude: ${location.longitude}');
    print('Précision: ${location.accuracy} m');
  }
}
```

### 3. Suivi en temps réel

```dart
final locationProvider = context.read<LocationProvider>();

// Démarrer le suivi
await locationProvider.startTracking();

// Écouter les changements avec Consumer
Consumer<LocationProvider>(
  builder: (context, provider, child) {
    final location = provider.currentLocation;
    if (location != null) {
      return Text('Position: ${location.latitude}, ${location.longitude}');
    }
    return const CircularProgressIndicator();
  },
)

// Arrêter le suivi
locationProvider.stopTracking();
```

### 4. Utiliser le widget d'affichage

```dart
import 'package:agrigeo/presentation/widgets/location_display_widget.dart';

LocationDisplayWidget(
  showTrackingControls: true,
  autoStartTracking: false, // Démarrer automatiquement le suivi
)
```

### 5. Calculer la distance

```dart
final locationProvider = context.read<LocationProvider>();

// Distance entre la position actuelle et un point
final distance = locationProvider.distanceTo(
  latitude: 45.5,
  longitude: -0.5,
);

if (distance != null) {
  print('Distance: ${distance.toStringAsFixed(0)} m');
  print('Distance: ${(distance / 1000).toStringAsFixed(2)} km');
}
```

### 6. Calculer la direction

```dart
final bearing = locationProvider.bearingTo(
  latitude: 45.5,
  longitude: -0.5,
);

if (bearing != null) {
  print('Direction: ${bearing.toStringAsFixed(1)}°');
  // 0° = Nord, 90° = Est, 180° = Sud, 270° = Ouest
}
```

### 7. Configuration de la précision

```dart
import 'package:geolocator/geolocator.dart';

final locationProvider = context.read<LocationProvider>();

// Configurer la précision
locationProvider.setAccuracy(LocationAccuracy.high);
// Options: lowest, low, medium, high, best, bestForNavigation

// Configurer le filtre de distance (mise à jour seulement si déplacement > X mètres)
locationProvider.setDistanceFilter(10); // 10 mètres
```

## Permissions

### Android

Les permissions sont déjà configurées dans `android/app/src/main/AndroidManifest.xml` :
- `ACCESS_FINE_LOCATION` : Position précise (GPS)
- `ACCESS_COARSE_LOCATION` : Position approximative (réseau)
- `ACCESS_BACKGROUND_LOCATION` : Position en arrière-plan

### iOS

Les descriptions sont configurées dans `ios/Runner/Info.plist` :
- `NSLocationWhenInUseUsageDescription` : Utilisation pendant l'utilisation
- `NSLocationAlwaysUsageDescription` : Utilisation en arrière-plan

## Gestion des erreurs

Le service gère automatiquement :
- Services de localisation désactivés
- Permissions refusées
- Erreurs de récupération de position

```dart
try {
  await locationProvider.getCurrentLocation();
} catch (e) {
  // Afficher un message d'erreur à l'utilisateur
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
  
  // Proposer d'ouvrir les paramètres
  if (e.toString().contains('refusées')) {
    await locationProvider.openAppSettings();
  }
}
```

## Intégration avec les exploitations

La localisation peut être utilisée pour :

1. **Créer une exploitation à partir de la position actuelle** :
```dart
final location = await locationProvider.getCurrentLocation();
if (location != null) {
  // Créer une exploitation avec la position actuelle
  await exploitationRepository.createExploitation({
    'nom': 'Mon exploitation',
    'latitude': location.latitude,
    'longitude': location.longitude,
    // ...
  });
}
```

2. **Créer un polygone OpenWeather Agro** :
```dart
final location = await locationProvider.getCurrentLocation();
if (location != null) {
  // Créer un polygone autour de la position actuelle
  await polygonRepository.createPolygon(
    name: 'Mon exploitation',
    coordinates: [
      [location.longitude - 0.01, location.latitude - 0.01],
      [location.longitude + 0.01, location.latitude - 0.01],
      [location.longitude + 0.01, location.latitude + 0.01],
      [location.longitude - 0.01, location.latitude + 0.01],
      [location.longitude - 0.01, location.latitude - 0.01],
    ],
  );
}
```

3. **Obtenir la météo pour la position actuelle** :
```dart
final location = await locationProvider.getCurrentLocation();
if (location != null) {
  await meteoProvider.loadMeteoActuelle(
    latitude: location.latitude,
    longitude: location.longitude,
  );
}
```

## Performance

- Le suivi en temps réel utilise un filtre de distance pour éviter les mises à jour trop fréquentes
- La précision peut être ajustée selon les besoins (batterie vs précision)
- Le service gère automatiquement l'arrêt du suivi lors de la destruction du provider

## Notes importantes

- Les permissions doivent être demandées avant d'utiliser la localisation
- Sur iOS, les descriptions de permissions doivent être claires pour l'utilisateur
- Le suivi en temps réel consomme de la batterie, utiliser avec modération
- Toujours arrêter le suivi quand il n'est plus nécessaire




