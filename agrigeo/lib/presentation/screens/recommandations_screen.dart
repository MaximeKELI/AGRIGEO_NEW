import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/recommandation_model.dart';
import '../../data/models/exploitation_model.dart';
import '../providers/recommandation_provider.dart';

class RecommandationsScreen extends StatelessWidget {
  final ExploitationModel? exploitation;

  const RecommandationsScreen({
    super.key,
    this.exploitation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommandationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.recommandations.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final recommandations = provider.recommandations;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Recommandations'),
            actions: [
              if (exploitation != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: provider.isGenerating
                      ? null
                      : () async {
                          final success = await provider.generateRecommandations(exploitation!.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Recommandations générées avec succès'
                                    : provider.error ?? 'Erreur lors de la génération'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  tooltip: 'Générer des recommandations',
                ),
            ],
          ),
          body: provider.isGenerating
              ? const Center(child: CircularProgressIndicator())
              : recommandations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune recommandation',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Générez des recommandations basées sur vos données',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          if (exploitation != null) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: provider.isGenerating
                                  ? null
                                  : () async {
                                      final success = await provider.generateRecommandations(exploitation!.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(success
                                                ? 'Recommandations générées avec succès'
                                                : provider.error ?? 'Erreur'),
                                            backgroundColor: success ? Colors.green : Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Générer des recommandations'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: recommandations.length,
                      itemBuilder: (context, index) {
                        final rec = recommandations[index];
                        return _buildRecommandationCard(context, rec);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildRecommandationCard(BuildContext context, RecommandationModel rec) {
    Color priorityColor;
    IconData priorityIcon;
    
    switch (rec.priorite) {
      case 'élevée':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'moyenne':
        priorityColor = Colors.orange;
        priorityIcon = Icons.remove;
        break;
      default:
        priorityColor = Colors.blue;
        priorityIcon = Icons.arrow_downward;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(priorityIcon, color: priorityColor),
        title: Text(
          rec.titre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          rec.typeRecommandation,
          style: TextStyle(color: priorityColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(rec.priorite),
                      backgroundColor: priorityColor.withValues(alpha: 0.2),
                      labelStyle: TextStyle(color: priorityColor),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(rec.statut),
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ],
                ),
                if (rec.parametresUtilises != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Paramètres utilisés:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec.parametresUtilises!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (rec.statut == 'non_appliquée')
                      Consumer<RecommandationProvider>(
                        builder: (context, provider, _) {
                          return TextButton.icon(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    final success = await provider.updateRecommandationStatus(
                                      rec.id,
                                      'appliquée',
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success
                                              ? 'Recommandation marquée comme appliquée'
                                              : provider.error ?? 'Erreur'),
                                          backgroundColor: success ? Colors.green : Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.check),
                            label: const Text('Marquer comme appliquée'),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

