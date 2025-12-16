import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/meteo_provider.dart';
import '../providers/exploitation_provider.dart';
import '../../data/models/exploitation_model.dart';
import 'conseils_irrigation_screen.dart';

class MeteoScreen extends StatelessWidget {
  final ExploitationModel? exploitation;

  const MeteoScreen({
    super.key,
    this.exploitation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo'),
        actions: [
          if (exploitation != null && exploitation!.latitude != null && exploitation!.longitude != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<MeteoProvider>(context, listen: false).loadMeteoComplete(
                  latitude: exploitation!.latitude!,
                  longitude: exploitation!.longitude!,
                );
              },
            ),
        ],
      ),
      body: exploitation == null || exploitation!.latitude == null || exploitation!.longitude == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Coordonnées GPS requises',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Veuillez ajouter les coordonnées GPS\nde l\'exploitation pour afficher la météo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Consumer<MeteoProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.meteoActuelle == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.meteoActuelle == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadMeteoComplete(
                              latitude: exploitation!.latitude!,
                              longitude: exploitation!.longitude!,
                            );
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final meteo = provider.meteoActuelle;
                if (meteo == null) {
                  return const Center(
                    child: Text('Aucune donnée météo disponible'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadMeteoComplete(
                    latitude: exploitation!.latitude!,
                    longitude: exploitation!.longitude!,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte météo actuelle
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMeteoInfo(
                                      icon: Icons.thermostat,
                                      label: 'Min/Max',
                                      value: meteo.temperatureMin != null && meteo.temperatureMax != null
                                          ? '${meteo.temperatureMin!.toStringAsFixed(1)}° / ${meteo.temperatureMax!.toStringAsFixed(1)}°'
                                          : 'N/A',
                                    ),
                                    _buildMeteoInfo(
                                      icon: Icons.water_drop,
                                      label: 'Humidité',
                                      value: meteo.humidite != null
                                          ? '${meteo.humidite!.toStringAsFixed(0)}%'
                                          : 'N/A',
                                    ),
                                    _buildMeteoInfo(
                                      icon: Icons.air,
                                      label: 'Vent',
                                      value: meteo.vitesseVent != null
                                          ? '${meteo.vitesseVent!.toStringAsFixed(1)} m/s'
                                          : 'N/A',
                                    ),
                                  ],
                                ),
                                if (meteo.pluviometrie != null && meteo.pluviometrie! > 0) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                        const SizedBox(height: 16),
                        // Bouton conseils d'irrigation
                        if (exploitation != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ConseilsIrrigationScreen(
                                      exploitation: exploitation!,
                                      meteoActuelle: meteo,
                                      previsions: provider.previsions,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.water_drop),
                              label: const Text('Conseils d\'irrigation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Prévisions
                        if (provider.previsions.isNotEmpty) ...[
                          const Text(
                            'Prévisions (prochaines 24h)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...provider.previsions.take(8).map((prev) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: prev.icon != null
                                      ? Image.network(
                                          'https://openweathermap.org/img/wn/${prev.icon}.png',
                                          width: 40,
                                          height: 40,
                                        )
                                      : const Icon(Icons.cloud),
                                  title: Text(
                                    prev.date != null
                                        ? DateFormat('dd/MM HH:mm').format(prev.date!)
                                        : 'N/A',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (prev.temperature != null)
                                        Text('${prev.temperature!.toStringAsFixed(1)}°C'),
                                      if (prev.description != null) Text(prev.description!),
                                      if (prev.pluviometrie != null && prev.pluviometrie! > 0)
                                        Text(
                                          'Pluie: ${prev.pluviometrie!.toStringAsFixed(1)} mm',
                                          style: const TextStyle(color: Colors.blue),
                                        ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMeteoInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

