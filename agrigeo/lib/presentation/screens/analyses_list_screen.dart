import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analyse_sol_provider.dart';
import '../../data/models/exploitation_model.dart';
import '../../data/models/parcelle_model.dart';
import 'add_analyse_sol_screen.dart';
import 'analyse_detail_screen.dart';

class AnalysesListScreen extends StatelessWidget {
  final ExploitationModel? exploitation;
  final ParcelleModel? parcelle;

  const AnalysesListScreen({
    super.key,
    this.exploitation,
    this.parcelle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyses de sol'),
      ),
      body: Consumer<AnalyseSolProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.analyses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.analyses.isEmpty) {
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
                    onPressed: () => provider.loadAnalyses(
                      exploitationId: exploitation?.id,
                      parcelleId: parcelle?.id,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.analyses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.science_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune analyse',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez votre première analyse de sol',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAnalyses(
              exploitationId: exploitation?.id,
              parcelleId: parcelle?.id,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.analyses.length,
              itemBuilder: (context, index) {
                final analyse = provider.analyses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.science, color: Colors.green),
                    title: Text(
                      'Analyse du ${_formatDate(analyse.datePrelevement)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (analyse.ph != null) Text('pH: ${analyse.ph!.toStringAsFixed(2)}'),
                        if (analyse.azoteN != null)
                          Text('N: ${analyse.azoteN!.toStringAsFixed(2)} mg/kg'),
                        if (analyse.phosphoreP != null)
                          Text('P: ${analyse.phosphoreP!.toStringAsFixed(2)} mg/kg'),
                        if (analyse.potassiumK != null)
                          Text('K: ${analyse.potassiumK!.toStringAsFixed(2)} mg/kg'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AnalyseDetailScreen(analyse: analyse),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: exploitation != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddAnalyseSolScreen(
                      exploitation: exploitation!,
                      parcelle: parcelle,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}




