import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/intrant_provider.dart';
import '../../data/models/exploitation_model.dart';
import '../../data/models/parcelle_model.dart';
import 'add_intrant_screen.dart';

class IntrantsListScreen extends StatelessWidget {
  final ExploitationModel? exploitation;
  final ParcelleModel? parcelle;

  const IntrantsListScreen({
    super.key,
    this.exploitation,
    this.parcelle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intrants'),
      ),
      body: Consumer<IntrantProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.intrants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.intrants.isEmpty) {
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
                    onPressed: () => provider.loadIntrants(
                      exploitationId: exploitation?.id,
                      parcelleId: parcelle?.id,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.intrants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun intrant',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez votre premier intrant',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadIntrants(
              exploitationId: exploitation?.id,
              parcelleId: parcelle?.id,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.intrants.length,
              itemBuilder: (context, index) {
                final intrant = provider.intrants[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.agriculture, color: Colors.green),
                    title: Text(
                      intrant.typeIntrant,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (intrant.nomCommercial != null)
                          Text(intrant.nomCommercial!),
                        Text(
                          '${intrant.quantite} ${intrant.unite}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('Date: ${_formatDate(intrant.dateApplication)}'),
                        if (intrant.cultureConcernee != null)
                          Text('Culture: ${intrant.cultureConcernee}'),
                      ],
                    ),
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
                    builder: (_) => AddIntrantScreen(
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
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

