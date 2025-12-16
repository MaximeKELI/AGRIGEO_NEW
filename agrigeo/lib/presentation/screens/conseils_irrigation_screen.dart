import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/exploitation_model.dart';
import '../../data/models/meteo_model.dart';
import '../../data/datasources/api_service.dart';
import '../../core/errors/failures.dart';

class ConseilsIrrigationScreen extends StatefulWidget {
  final ExploitationModel exploitation;
  final MeteoModel meteoActuelle;
  final List<MeteoModel> previsions;

  const ConseilsIrrigationScreen({
    super.key,
    required this.exploitation,
    required this.meteoActuelle,
    required this.previsions,
  });

  @override
  State<ConseilsIrrigationScreen> createState() => _ConseilsIrrigationScreenState();
}

class _ConseilsIrrigationScreenState extends State<ConseilsIrrigationScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _conseils = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConseils();
  }

  Future<void> _loadConseils() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      
      // Préparer les données météo pour l'API
      final meteoData = {
        'meteo_actuelle': {
          'temperature': widget.meteoActuelle.temperature,
          'temperature_max': widget.meteoActuelle.temperatureMax,
          'humidite': widget.meteoActuelle.humidite,
          'pluviometrie': widget.meteoActuelle.pluviometrie,
        },
        'previsions': widget.previsions.map((p) => {
          'temperature': p.temperature,
          'humidite': p.humidite,
          'pluviometrie': p.pluviometrie,
        }).toList(),
      };

      // Appeler l'API backend pour générer les conseils
      final response = await apiService.generateConseilsIrrigation(
        widget.exploitation.id,
        meteoData,
      );

      setState(() {
        _conseils = List<Map<String, dynamic>>.from(response.data['conseils']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is Failure ? e.message : e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conseils d\'irrigation'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadConseils,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _conseils.isEmpty
                  ? const Center(
                      child: Text('Aucun conseil disponible'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConseils,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _conseils.length,
                        itemBuilder: (context, index) {
                          final conseil = _conseils[index];
                          return _buildConseilCard(conseil);
                        },
                      ),
                    ),
    );
  }

  Widget _buildConseilCard(Map<String, dynamic> conseil) {
    Color priorityColor;
    IconData icon;

    switch (conseil['priorite']) {
      case 'élevée':
        priorityColor = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'moyenne':
        priorityColor = Colors.orange;
        icon = Icons.info;
        break;
      default:
        priorityColor = Colors.blue;
        icon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: priorityColor),
        title: Text(
          conseil['titre'] ?? 'Conseil',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(conseil['type'] ?? ''),
            if (conseil['quantite_recommandee'] != null)
              Text(
                'Quantité: ${conseil['quantite_recommandee']}',
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conseil['description'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                if (conseil['parametres_utilises'] != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Paramètres utilisés:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...conseil['parametres_utilises'].entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

