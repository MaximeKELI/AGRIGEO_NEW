# Analyse IA d'Images Agricoles

Ce document décrit le système d'analyse d'images agricoles avec IA intégré dans AGRIGEO.

## Fonctionnalités

- ✅ Prise de photo directement avec l'appareil photo
- ✅ Import d'images depuis la galerie
- ✅ Analyse avec Gemini Vision API pour détecter :
  - Maladies des plantes
  - Plantes cultivées
  - État du sol
  - Conditions météorologiques
- ✅ Intégration Sentinel Hub pour données satellite
- ✅ Génération automatique de recommandations
- ✅ Support de la localisation GPS pour enrichir l'analyse

## Architecture

### Services

#### 1. GeminiVisionService (`lib/data/services/gemini_vision_service.dart`)

Service pour l'analyse d'images avec Gemini Vision API :
- Analyse d'images avec prompts spécialisés selon le type
- Support de tous les types d'analyse (maladies, plantes, sol, météo, etc.)
- Parsing intelligent des réponses JSON

#### 2. SentinelHubService (`lib/data/services/sentinel_hub_service.dart`)

Service pour récupérer des données satellite depuis Sentinel Hub :
- Authentification OAuth
- Récupération d'images satellite
- Calcul d'indices de végétation (NDVI, EVI)
- Support de différentes couches (True Color, False Color, NDVI, EVI)

#### 3. ImageAnalysisService (`lib/data/services/image_analysis_service.dart`)

Service principal qui orchestre l'analyse :
- Combine Gemini Vision et Sentinel Hub
- Génère des recommandations automatiques
- Gère les erreurs et fallbacks

### Modèles

#### ImageAnalysisResultModel (`lib/data/models/image_analysis_result_model.dart`)

Modèle complet pour les résultats d'analyse :
- `DiseaseDetection` : Détection de maladies
- `PlantDetection` : Détection de plantes
- `WeatherInfo` : Informations météo
- `SoilAnalysis` : Analyse du sol
- `Recommendation` : Recommandations générées

### Provider

#### ImageAnalysisProvider (`lib/presentation/providers/image_analysis_provider.dart`)

Provider pour gérer l'état de l'analyse :
- Sélection d'images
- Types d'analyse
- Historique des analyses
- Gestion des erreurs

## Configuration

### 1. Clé API Gemini

La clé API Gemini est déjà configurée par défaut. Pour utiliser votre propre clé :

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString(AppConstants.geminiApiKey, 'VOTRE_CLE_API');
```

### 2. Credentials Sentinel Hub

Pour utiliser Sentinel Hub, vous devez obtenir :
- **API Key** (Client ID)
- **API Secret** (Client Secret)

Depuis : https://www.sentinel-hub.com/

```dart
final provider = context.read<ImageAnalysisProvider>();
await provider.setSentinelHubCredentials(
  apiKey: 'VOTRE_API_KEY',
  apiSecret: 'VOTRE_API_SECRET',
);
```

## Utilisation

### 1. Prendre ou importer une image

```dart
final imagePicker = ImagePicker();

// Prendre une photo
final photo = await imagePicker.pickImage(source: ImageSource.camera);

// Ou depuis la galerie
final image = await imagePicker.pickImage(source: ImageSource.gallery);

if (image != null) {
  final provider = context.read<ImageAnalysisProvider>();
  provider.selectImage(File(image.path));
}
```

### 2. Analyser une image

```dart
final provider = context.read<ImageAnalysisProvider>();

// Obtenir la position actuelle (optionnel mais recommandé)
final locationProvider = context.read<LocationProvider>();
await locationProvider.getCurrentLocation();

double? lat, lon;
if (locationProvider.currentLocation != null) {
  lat = locationProvider.currentLocation!.latitude;
  lon = locationProvider.currentLocation!.longitude;
}

// Analyser avec un type spécifique
provider.setAnalysisType(AnalysisType.disease);
await provider.analyzeImage(latitude: lat, longitude: lon);

// Ou analyse rapide (détection automatique)
await provider.quickAnalyze();
```

### 3. Types d'analyse disponibles

```dart
enum AnalysisType {
  plant,      // Analyse de plantes
  field,      // Analyse de champ/zone agricole
  disease,    // Détection de maladies
  weather,    // Analyse météo
  soil,       // Analyse de sol
  general,    // Analyse générale (recommandé)
}
```

### 4. Accéder aux résultats

```dart
Consumer<ImageAnalysisProvider>(
  builder: (context, provider, _) {
    final result = provider.lastAnalysisResult;
    
    if (result == null) {
      return Text('Aucune analyse disponible');
    }
    
    return Column(
      children: [
        // Maladies détectées
        if (result.diseases != null)
          ...result.diseases!.map((disease) => 
            Text('${disease.name}: ${disease.severity}')
          ),
        
        // Plantes détectées
        if (result.plants != null)
          ...result.plants!.map((plant) => 
            Text('${plant.name} (${plant.scientificName})')
          ),
        
        // Recommandations
        if (result.recommendations != null)
          ...result.recommendations!.map((rec) => 
            Text('${rec.title}: ${rec.description}')
          ),
      ],
    );
  },
)
```

## Intégration Sentinel Hub

### Récupération de données satellite

Quand une image est analysée avec des coordonnées GPS, le service essaie automatiquement de récupérer des données satellite Sentinel Hub pour enrichir l'analyse :

```dart
// Les données Sentinel Hub sont automatiquement récupérées si :
// 1. Les credentials sont configurés
// 2. Des coordonnées GPS sont fournies
// 3. L'API est accessible

final result = await provider.analyzeImage(
  latitude: 45.5,
  longitude: -0.5,
);

// Les données satellite sont dans metadata
final sentinelData = result.metadata?['sentinelHub'];
```

### Indices de végétation

Sentinel Hub fournit des indices de végétation (NDVI, EVI) qui peuvent être utilisés pour :
- Évaluer la santé des cultures
- Détecter les zones stressées
- Suivre la croissance des plantes
- Optimiser l'irrigation

## Recommandations automatiques

Le système génère automatiquement des recommandations basées sur :

1. **Maladies détectées** :
   - Traitements recommandés
   - Priorité selon la sévérité

2. **État du sol** :
   - Besoins d'irrigation
   - Problèmes de drainage
   - Qualité du sol

3. **Données satellite** :
   - État de la végétation (NDVI)
   - Zones à surveiller

4. **Conditions météo** :
   - Adaptations des pratiques agricoles

## Exemple complet

```dart
class MyAnalysisWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageAnalysisProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Sélection d'image
            if (provider.selectedImage == null)
              ElevatedButton(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    provider.selectImage(File(image.path));
                  }
                },
                child: Text('Prendre une photo'),
              ),
            
            // Image sélectionnée
            if (provider.selectedImage != null)
              Image.file(provider.selectedImage!),
            
            // Bouton d'analyse
            if (provider.selectedImage != null && !provider.isAnalyzing)
              ElevatedButton(
                onPressed: () async {
                  // Obtenir la position
                  final locationProvider = context.read<LocationProvider>();
                  await locationProvider.getCurrentLocation();
                  
                  double? lat, lon;
                  if (locationProvider.currentLocation != null) {
                    lat = locationProvider.currentLocation!.latitude;
                    lon = locationProvider.currentLocation!.longitude;
                  }
                  
                  // Analyser
                  await provider.analyzeImage(
                    latitude: lat,
                    longitude: lon,
                  );
                },
                child: Text('Analyser'),
              ),
            
            // Résultats
            if (provider.lastAnalysisResult != null)
              _buildResults(provider.lastAnalysisResult!),
            
            // Erreurs
            if (provider.error != null)
              Text(provider.error!, style: TextStyle(color: Colors.red)),
          ],
        );
      },
    );
  }
  
  Widget _buildResults(ImageAnalysisResultModel result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confiance: ${(result.confidence! * 100).toStringAsFixed(0)}%'),
        
        if (result.diseases != null && result.diseases!.isNotEmpty) ...[
          Text('Maladies détectées:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...result.diseases!.map((d) => Text('- ${d.name} (${d.severity})')),
        ],
        
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          Text('Recommandations:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...result.recommendations!.map((r) => Text('- ${r.title}')),
        ],
      ],
    );
  }
}
```

## Permissions requises

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Cette application a besoin d'accéder à la caméra pour prendre des photos de vos cultures.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette application a besoin d'accéder à vos photos pour analyser vos images agricoles.</string>
```

## Notes importantes

- La clé API Gemini est requise pour l'analyse d'images
- Sentinel Hub est optionnel mais enrichit l'analyse avec des données satellite
- La localisation GPS améliore la précision de l'analyse
- Les images sont analysées localement (pas stockées sur les serveurs)
- Les recommandations sont générées automatiquement mais doivent être validées par un expert

## Prochaines améliorations

1. Cache des analyses pour éviter les re-analyses
2. Export des résultats en PDF
3. Comparaison avec des analyses précédentes
4. Alertes automatiques pour maladies critiques
5. Intégration avec le système de recommandations existant




