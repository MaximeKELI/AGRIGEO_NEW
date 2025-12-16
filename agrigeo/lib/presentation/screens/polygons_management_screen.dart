import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/openweather_polygon_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/openweather_polygon_model.dart';
import 'config_openweather_agro_screen.dart';

class PolygonsManagementScreen extends StatefulWidget {
  const PolygonsManagementScreen({super.key});

  @override
  State<PolygonsManagementScreen> createState() => _PolygonsManagementScreenState();
}

class _PolygonsManagementScreenState extends State<PolygonsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiKeyAndLoad();
    });
  }

  Future<void> _checkApiKeyAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    
    if (apiKey == null || apiKey.isEmpty) {
      if (mounted) {
        _showApiKeyRequiredDialog();
      }
      return;
    }

    final provider = Provider.of<OpenWeatherPolygonProvider>(context, listen: false);
    provider.setApiKey(apiKey);
    await provider.loadPolygons();
  }

  void _showApiKeyRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clé API requise'),
        content: const Text(
          'Vous devez configurer votre clé API OpenWeather Agro pour utiliser cette fonctionnalité.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ConfigOpenWeatherAgroScreen(),
                ),
              );
            },
            child: const Text('Configurer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreatePolygonDialog() async {
    final nameController = TextEditingController();
    final coordinatesController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un polygone'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du polygone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coordinatesController,
                decoration: const InputDecoration(
                  labelText: 'Coordonnées (JSON)',
                  hintText: '[[lon1, lat1], [lon2, lat2], ...]',
                  border: OutlineInputBorder(),
                  helperText: 'Format: [[lon, lat], [lon, lat], ...]',
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || coordinatesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                // Parser les coordonnées JSON simple
                // Format attendu: [[lon1, lat1], [lon2, lat2], ...]
                final text = coordinatesController.text.trim();
                final cleaned = text.replaceAll(RegExp(r'\s+'), '');
                
                // Extraire les coordonnées avec regex
                final regex = RegExp(r'\[([-\d.]+),\s*([-\d.]+)\]');
                final matches = regex.allMatches(cleaned);
                
                if (matches.isEmpty) {
                  throw Exception('Format de coordonnées invalide');
                }
                
                final coordinates = matches.map((match) {
                  final lon = double.parse(match.group(1)!);
                  final lat = double.parse(match.group(2)!);
                  return [lon, lat];
                }).toList();

                final provider = Provider.of<OpenWeatherPolygonProvider>(context, listen: false);
                await provider.createPolygon(
                  name: nameController.text.trim(),
                  coordinates: coordinates,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Polygone créé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPolygonDialog(OpenWeatherPolygonModel polygon) async {
    final nameController = TextEditingController(text: polygon.name);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le polygone'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du polygone',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le nom ne peut pas être vide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final provider = Provider.of<OpenWeatherPolygonProvider>(context, listen: false);
                await provider.updatePolygonName(
                  polygonId: polygon.id,
                  newName: nameController.text.trim(),
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Polygone modifié avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(OpenWeatherPolygonModel polygon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le polygone'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${polygon.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<OpenWeatherPolygonProvider>(context, listen: false);
        await provider.deletePolygon(polygon.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Polygone supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showPolygonDetails(OpenWeatherPolygonModel polygon) async {
    final provider = Provider.of<OpenWeatherPolygonProvider>(context, listen: false);
    
    // Charger les données météo
    await provider.loadPolygonWeather(polygon.id);
    
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Consumer<OpenWeatherPolygonProvider>(
          builder: (context, provider, _) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          polygon.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('ID', polygon.id),
                  _buildInfoRow('Surface', '${polygon.area} ha'),
                  _buildInfoRow('Créé le', polygon.createdAt),
                  const Divider(),
                  const Text(
                    'Données météo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.weatherData != null)
                    _buildWeatherData(provider.weatherData!)
                  else
                    const Text('Aucune donnée météo disponible'),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildWeatherData(PolygonWeatherData weather) {
    return Column(
      children: [
        if (weather.temp != null)
          _buildInfoRow('Température', '${weather.temp!.toStringAsFixed(1)}°C'),
        if (weather.humidity != null)
          _buildInfoRow('Humidité', '${weather.humidity!.toStringAsFixed(1)}%'),
        if (weather.pressure != null)
          _buildInfoRow('Pression', '${weather.pressure!.toStringAsFixed(1)} hPa'),
        if (weather.windSpeed != null)
          _buildInfoRow('Vitesse du vent', '${weather.windSpeed!.toStringAsFixed(1)} m/s'),
        if (weather.precipitation != null)
          _buildInfoRow('Précipitations', '${weather.precipitation!.toStringAsFixed(1)} mm'),
        if (weather.dt != null)
          _buildInfoRow('Date', weather.dt!.toString()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des polygones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ConfigOpenWeatherAgroScreen(),
                ),
              );
            },
            tooltip: 'Configuration',
          ),
        ],
      ),
      body: Consumer<OpenWeatherPolygonProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.polygons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.polygons.isEmpty) {
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
                    onPressed: () => provider.loadPolygons(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.polygons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun polygone',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Créez votre premier polygone',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPolygons(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.polygons.length,
              itemBuilder: (context, index) {
                final polygon = provider.polygons[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.map, color: Colors.green),
                    title: Text(
                      polygon.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Surface: ${polygon.area} ha'),
                        Text('ID: ${polygon.id}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline),
                              SizedBox(width: 8),
                              Text('Détails'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'details':
                            _showPolygonDetails(polygon);
                            break;
                          case 'edit':
                            _showEditPolygonDialog(polygon);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(polygon);
                            break;
                        }
                      },
                    ),
                    onTap: () => _showPolygonDetails(polygon),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePolygonDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

