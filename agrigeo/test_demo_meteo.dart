/// Script de démonstration pour tester la fonctionnalité météo
/// 
/// Ce script montre comment utiliser le service météo dans l'application
/// Pour l'exécuter: flutter run test_demo_meteo.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/presentation/providers/meteo_provider.dart';
import 'lib/presentation/providers/exploitation_provider.dart';

void main() {
  runApp(const MeteoDemoApp());
}

class MeteoDemoApp extends StatelessWidget {
  const MeteoDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeteoProvider()),
        ChangeNotifierProvider(create: (_) => ExploitationProvider()),
      ],
      child: MaterialApp(
        title: 'Test Météo AGRIGEO',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MeteoTestScreen(),
      ),
    );
  }
}

class MeteoTestScreen extends StatefulWidget {
  const MeteoTestScreen({super.key});

  @override
  State<MeteoTestScreen> createState() => _MeteoTestScreenState();
}

class _MeteoTestScreenState extends State<MeteoTestScreen> {
  final _latitudeController = TextEditingController(text: '48.8566');
  final _longitudeController = TextEditingController(text: '2.3522');
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _testMeteo() {
    final latitude = double.tryParse(_latitudeController.text);
    final longitude = double.tryParse(_longitudeController.text);
    final apiKey = _apiKeyController.text.trim();

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer des coordonnées valides'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une clé API OpenWeather'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final meteoProvider = Provider.of<MeteoProvider>(context, listen: false);
    meteoProvider.setApiKey(apiKey);
    meteoProvider.loadMeteoComplete(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Météo AGRIGEO'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Clé API OpenWeather',
                        hintText: 'Entrez votre clé API',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              hintText: '48.8566',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              hintText: '2.3522',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _testMeteo,
                      icon: const Icon(Icons.cloud),
                      label: const Text('Tester la météo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<MeteoProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Chargement des données météo...'),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (provider.error != null) {
                  return Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.meteoActuelle == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune donnée météo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cliquez sur "Tester la météo" pour charger les données',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final meteo = provider.meteoActuelle!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Météo actuelle',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${meteo.temperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (meteo.description != null)
                                      Text(
                                        meteo.description!,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                  ],
                                ),
                                if (meteo.icon != null)
                                  Image.network(
                                    'https://openweathermap.org/img/wn/${meteo.icon}@2x.png',
                                    width: 80,
                                    height: 80,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildInfoCard(
                                  'Min/Max',
                                  meteo.temperatureMin != null && meteo.temperatureMax != null
                                      ? '${meteo.temperatureMin!.toStringAsFixed(1)}° / ${meteo.temperatureMax!.toStringAsFixed(1)}°'
                                      : 'N/A',
                                  Icons.thermostat,
                                ),
                                _buildInfoCard(
                                  'Humidité',
                                  meteo.humidite != null
                                      ? '${meteo.humidite!.toStringAsFixed(0)}%'
                                      : 'N/A',
                                  Icons.water_drop,
                                ),
                                _buildInfoCard(
                                  'Vent',
                                  meteo.vitesseVent != null
                                      ? '${meteo.vitesseVent!.toStringAsFixed(1)} m/s'
                                      : 'N/A',
                                  Icons.air,
                                ),
                              ],
                            ),
                            if (meteo.pluviometrie != null && meteo.pluviometrie! > 0) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.cloud, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pluviométrie: ${meteo.pluviometrie!.toStringAsFixed(1)} mm',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (provider.previsions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prévisions (${provider.previsions.length} périodes)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...provider.previsions.take(5).map((prev) => ListTile(
                                    leading: prev.icon != null
                                        ? Image.network(
                                            'https://openweathermap.org/img/wn/${prev.icon}.png',
                                            width: 40,
                                            height: 40,
                                          )
                                        : const Icon(Icons.cloud),
                                    title: Text(
                                      prev.temperature != null
                                          ? '${prev.temperature!.toStringAsFixed(1)}°C'
                                          : 'N/A',
                                    ),
                                    subtitle: prev.description != null
                                        ? Text(prev.description!)
                                        : null,
                                    trailing: prev.pluviometrie != null && prev.pluviometrie! > 0
                                        ? Text(
                                            '${prev.pluviometrie!.toStringAsFixed(1)} mm',
                                            style: const TextStyle(color: Colors.blue),
                                          )
                                        : null,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

