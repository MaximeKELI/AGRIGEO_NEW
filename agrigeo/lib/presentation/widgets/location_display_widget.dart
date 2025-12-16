import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';
import '../../data/models/user_location_model.dart';

/// Widget pour afficher la localisation de l'utilisateur en temps réel
class LocationDisplayWidget extends StatefulWidget {
  final bool showTrackingControls;
  final bool autoStartTracking;

  const LocationDisplayWidget({
    super.key,
    this.showTrackingControls = true,
    this.autoStartTracking = false,
  });

  @override
  State<LocationDisplayWidget> createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends State<LocationDisplayWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoStartTracking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LocationProvider>().startTracking();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final location = locationProvider.currentLocation;
        final isLoading = locationProvider.isLoading;
        final isTracking = locationProvider.isTracking;
        final error = locationProvider.error;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Localisation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isTracking)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'En direct',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading && location == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text(
                              'Erreur',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(error),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            locationProvider.clearError();
                            locationProvider.getCurrentLocation();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                else if (location != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.my_location,
                        'Latitude',
                        location.latitude.toStringAsFixed(6),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.explore,
                        'Longitude',
                        location.longitude.toStringAsFixed(6),
                      ),
                      if (location.accuracy != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.accuracy_high,
                          'Précision',
                          '${location.accuracy!.toStringAsFixed(1)} m',
                        ),
                      ],
                      if (location.altitude != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.height,
                          'Altitude',
                          '${location.altitude!.toStringAsFixed(1)} m',
                        ),
                      ],
                      if (location.speed != null && location.speed! > 0) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.speed,
                          'Vitesse',
                          '${(location.speed! * 3.6).toStringAsFixed(1)} km/h',
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.access_time,
                        'Dernière mise à jour',
                        _formatTimestamp(location.timestamp),
                      ),
                    ],
                  )
                else
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Aucune position disponible',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            locationProvider.getCurrentLocation();
                          },
                          icon: const Icon(Icons.location_searching),
                          label: const Text('Obtenir la position'),
                        ),
                      ],
                    ),
                  ),
                if (widget.showTrackingControls) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!isTracking)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    locationProvider.startTracking();
                                  },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Démarrer le suivi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              locationProvider.stopTracking();
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('Arrêter le suivi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  locationProvider.getCurrentLocation();
                                },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualiser'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Il y a ${difference.inSeconds} secondes';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heures';
    } else {
      return 'Le ${timestamp.day}/${timestamp.month}/${timestamp.year} à ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

