import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/image_analysis_provider.dart';
import '../providers/location_provider.dart';
import '../../data/models/image_analysis_result_model.dart';

/// Écran pour l'analyse d'images agricoles avec IA
class ImageAnalysisScreen extends StatefulWidget {
  const ImageAnalysisScreen({super.key});

  @override
  State<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final provider = context.read<ImageAnalysisProvider>();
        provider.selectImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse IA d\'Images'),
        actions: [
          Consumer<ImageAnalysisProvider>(
            builder: (context, provider, _) {
              if (provider.selectedImage != null) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    provider.clearImage();
                    provider.clearResults();
                  },
                  tooltip: 'Effacer l\'image',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ImageAnalysisProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section sélection d'image
                _buildImageSelectionSection(provider),
                
                const SizedBox(height: 24),
                
                // Section type d'analyse
                if (provider.selectedImage != null) ...[
                  _buildAnalysisTypeSection(provider),
                  const SizedBox(height: 24),
                ],
                
                // Section résultats
                if (provider.lastAnalysisResult != null)
                  _buildResultsSection(provider.lastAnalysisResult!),
                
                // Section erreur
                if (provider.error != null)
                  _buildErrorSection(provider.error!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSelectionSection(ImageAnalysisProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sélectionner une image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.selectedImage == null)
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Appuyez pour sélectionner une image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      provider.selectedImage!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      onPressed: _showImageSourceDialog,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.edit, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (provider.selectedImage != null)
              ElevatedButton.icon(
                onPressed: provider.isAnalyzing
                    ? null
                    : () async {
                        // Obtenir la position si disponible
                        final locationProvider = context.read<LocationProvider>();
                        double? lat, lon;
                        
                        if (locationProvider.currentLocation != null) {
                          lat = locationProvider.currentLocation!.latitude;
                          lon = locationProvider.currentLocation!.longitude;
                        }
                        
                        await provider.analyzeImage(
                          latitude: lat,
                          longitude: lon,
                        );
                      },
                icon: provider.isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(provider.isAnalyzing ? 'Analyse en cours...' : 'Analyser l\'image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTypeSection(ImageAnalysisProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type d\'analyse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AnalysisType.values.map((type) {
                final isSelected = provider.selectedAnalysisType == type;
                return FilterChip(
                  label: Text(_getAnalysisTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.setAnalysisType(type);
                    }
                  },
                  avatar: Icon(_getAnalysisTypeIcon(type)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(ImageAnalysisResultModel result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Résultats de l\'analyse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (result.confidence != null)
                  Chip(
                    label: Text('Confiance: ${(result.confidence! * 100).toStringAsFixed(0)}%'),
                    backgroundColor: Colors.green[100],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Maladies détectées
            if (result.diseases != null && result.diseases!.isNotEmpty) ...[
              _buildSectionTitle('Maladies détectées', Icons.bug_report),
              const SizedBox(height: 8),
              ...result.diseases!.map((disease) => _buildDiseaseCard(disease)),
              const SizedBox(height: 16),
            ],
            
            // Plantes détectées
            if (result.plants != null && result.plants!.isNotEmpty) ...[
              _buildSectionTitle('Plantes détectées', Icons.local_florist),
              const SizedBox(height: 8),
              ...result.plants!.map((plant) => _buildPlantCard(plant)),
              const SizedBox(height: 16),
            ],
            
            // Informations météo
            if (result.weather != null) ...[
              _buildSectionTitle('Informations météo', Icons.wb_sunny),
              const SizedBox(height: 8),
              _buildWeatherCard(result.weather!),
              const SizedBox(height: 16),
            ],
            
            // Analyse du sol
            if (result.soilAnalysis != null) ...[
              _buildSectionTitle('Analyse du sol', Icons.landscape),
              const SizedBox(height: 8),
              _buildSoilCard(result.soilAnalysis!),
              const SizedBox(height: 16),
            ],
            
            // Recommandations
            if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
              _buildSectionTitle('Recommandations', Icons.lightbulb),
              const SizedBox(height: 8),
              ...result.recommendations!.map((rec) => _buildRecommendationCard(rec)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseCard(DiseaseDetection disease) {
    return Card(
      color: _getSeverityColor(disease.severity),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.white),
        title: Text(
          disease.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              disease.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Sévérité: ${disease.severity} | Confiance: ${(disease.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            if (disease.treatments != null && disease.treatments!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Traitements recommandés:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ...disease.treatments!.map((treatment) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      '• $treatment',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(PlantDetection plant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.local_florist, color: Colors.green),
        title: Text(
          plant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Nom scientifique: ${plant.scientificName}'),
            if (plant.growthStage != null)
              Text('Stade de croissance: ${plant.growthStage}'),
            if (plant.healthStatus != null)
              Text('État de santé: ${plant.healthStatus}'),
            const SizedBox(height: 4),
            Text(
              'Confiance: ${(plant.confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherInfo weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (weather.condition != null)
              ListTile(
                leading: const Icon(Icons.wb_cloudy),
                title: const Text('Condition'),
                trailing: Text(weather.condition!),
              ),
            if (weather.temperature != null)
              ListTile(
                leading: const Icon(Icons.thermostat),
                title: const Text('Température'),
                trailing: Text('${weather.temperature!.toStringAsFixed(1)}°C'),
              ),
            if (weather.humidity != null)
              ListTile(
                leading: const Icon(Icons.water_drop),
                title: const Text('Humidité'),
                trailing: Text('${weather.humidity!.toStringAsFixed(0)}%'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilCard(SoilAnalysis soil) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (soil.texture != null)
              ListTile(
                leading: const Icon(Icons.landscape),
                title: const Text('Texture'),
                trailing: Text(soil.texture!),
              ),
            if (soil.color != null)
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Couleur'),
                trailing: Text(soil.color!),
              ),
            if (soil.moistureLevel != null)
              ListTile(
                leading: const Icon(Icons.water_drop),
                title: const Text('Humidité'),
                trailing: Text('${(soil.moistureLevel! * 100).toStringAsFixed(0)}%'),
              ),
            if (soil.quality != null)
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Qualité'),
                trailing: Text(soil.quality!),
              ),
            if (soil.issues != null && soil.issues!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Problèmes détectés:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...soil.issues!.map((issue) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $issue'),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _getPriorityColor(recommendation.priority),
      child: ListTile(
        leading: Icon(
          Icons.lightbulb,
          color: _getPriorityIconColor(recommendation.priority),
        ),
        title: Text(
          recommendation.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(recommendation.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(recommendation.category),
                  labelStyle: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Priorité: ${recommendation.priority}'),
                  labelStyle: const TextStyle(fontSize: 11),
                  backgroundColor: _getPriorityColor(recommendation.priority),
                ),
              ],
            ),
            if (recommendation.actions != null && recommendation.actions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...recommendation.actions!.map((action) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $action'),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<ImageAnalysisProvider>().clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'sévère':
      case 'severe':
        return Colors.red;
      case 'modérée':
      case 'moderate':
        return Colors.orange;
      case 'légère':
      case 'light':
      default:
        return Colors.yellow[700]!;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
      case 'high':
        return Colors.red[100]!;
      case 'moyenne':
      case 'medium':
        return Colors.orange[100]!;
      case 'basse':
      case 'low':
      default:
        return Colors.blue[100]!;
    }
  }

  Color _getPriorityIconColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
      case 'high':
        return Colors.red;
      case 'moyenne':
      case 'medium':
        return Colors.orange;
      case 'basse':
      case 'low':
      default:
        return Colors.blue;
    }
  }

  String _getAnalysisTypeLabel(AnalysisType type) {
    switch (type) {
      case AnalysisType.plant:
        return 'Plantes';
      case AnalysisType.field:
        return 'Champ';
      case AnalysisType.disease:
        return 'Maladies';
      case AnalysisType.weather:
        return 'Météo';
      case AnalysisType.soil:
        return 'Sol';
      case AnalysisType.general:
        return 'Général';
    }
  }

  IconData _getAnalysisTypeIcon(AnalysisType type) {
    switch (type) {
      case AnalysisType.plant:
        return Icons.local_florist;
      case AnalysisType.field:
        return Icons.landscape;
      case AnalysisType.disease:
        return Icons.bug_report;
      case AnalysisType.weather:
        return Icons.wb_sunny;
      case AnalysisType.soil:
        return Icons.landscape;
      case AnalysisType.general:
        return Icons.analytics;
    }
  }
}

