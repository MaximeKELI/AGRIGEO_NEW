import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/recolte_provider.dart';
import '../providers/exploitation_provider.dart';
import '../../data/models/recolte_model.dart';
import '../widgets/animations/animations.dart';
import '../widgets/charts/charts.dart';
import 'add_recolte_screen.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class RecoltesScreen extends StatefulWidget {
  const RecoltesScreen({super.key});

  @override
  State<RecoltesScreen> createState() => _RecoltesScreenState();
}

class _RecoltesScreenState extends State<RecoltesScreen> {
  int? _selectedExploitationId;
  String? _selectedTypeCulture;
  int? _selectedAnnee;
  String _viewMode = 'list'; // 'list' ou 'charts'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RecolteProvider>(context, listen: false);
      final exploitationProvider = Provider.of<ExploitationProvider>(context, listen: false);
      
      exploitationProvider.loadExploitations();
      provider.loadRecoltes();
      
      if (exploitationProvider.exploitations.isNotEmpty) {
        _selectedExploitationId = exploitationProvider.exploitations.first.id;
        provider.loadRecoltes(exploitationId: _selectedExploitationId);
        provider.loadStatistics(exploitationId: _selectedExploitationId);
      }
    });
  }

  void _refreshData() {
    final provider = Provider.of<RecolteProvider>(context, listen: false);
    provider.loadRecoltes(
      exploitationId: _selectedExploitationId,
      typeCulture: _selectedTypeCulture,
      annee: _selectedAnnee,
    );
    if (_selectedExploitationId != null) {
      provider.loadStatistics(
        exploitationId: _selectedExploitationId,
        typeCulture: _selectedTypeCulture,
        annee: _selectedAnnee,
      );
    }
  }

  Future<void> _importFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final csvContent = await file.readAsString();

        if (_selectedExploitationId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner une exploitation'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final provider = Provider.of<RecolteProvider>(context, listen: false);
        final resultImport = await provider.importFromCsv(csvContent, _selectedExploitationId!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultImport['message'] ?? 'Import réussi'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'import: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToCsv() async {
    try {
      final provider = Provider.of<RecolteProvider>(context, listen: false);
      final filePath = await provider.exportToCsv();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export réussi: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Récoltes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importFromCsv,
            tooltip: 'Importer depuis CSV',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCsv,
            tooltip: 'Exporter en CSV',
          ),
          IconButton(
            icon: Icon(_viewMode == 'list' ? Icons.bar_chart : Icons.list),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'list' ? 'charts' : 'list';
              });
            },
            tooltip: 'Changer de vue',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Consumer<ExploitationProvider>(
                  builder: (context, exploitationProvider, _) {
                    return DropdownButtonFormField<int?>(
                      value: _selectedExploitationId,
                      decoration: const InputDecoration(
                        labelText: 'Exploitation',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('Toutes')),
                        ...exploitationProvider.exploitations.map((e) =>
                          DropdownMenuItem<int?>(value: e.id, child: Text(e.nom)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedExploitationId = value;
                        });
                        _refreshData();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: _selectedTypeCulture,
                        decoration: const InputDecoration(
                          labelText: 'Type de culture',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Toutes')),
                          const DropdownMenuItem<String?>(value: 'Maïs', child: Text('Maïs')),
                          const DropdownMenuItem<String?>(value: 'Riz', child: Text('Riz')),
                          const DropdownMenuItem<String?>(value: 'Manioc', child: Text('Manioc')),
                          const DropdownMenuItem<String?>(value: 'Arachide', child: Text('Arachide')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTypeCulture = value;
                          });
                          _refreshData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedAnnee,
                        decoration: const InputDecoration(
                          labelText: 'Année',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('Toutes')),
                          ...List.generate(5, (index) {
                            final annee = DateTime.now().year - index;
                            return DropdownMenuItem<int?>(value: annee, child: Text(annee.toString()));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAnnee = value;
                          });
                          _refreshData();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Contenu
          Expanded(
            child: _viewMode == 'list' ? _buildListView() : _buildChartsView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedExploitationId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez sélectionner une exploitation'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRecolteScreen(exploitationId: _selectedExploitationId!),
            ),
          ).then((_) => _refreshData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle récolte'),
      ),
    );
  }

  Widget _buildListView() {
    return Consumer<RecolteProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.recoltes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Aucune récolte trouvée'),
                const SizedBox(height: 8),
                const Text('Ajoutez votre première récolte'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.recoltes.length,
            itemBuilder: (context, index) {
              final recolte = provider.recoltes[index];
              final moisNoms = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withValues(alpha: 0.2),
                    child: const Icon(Icons.agriculture, color: Colors.green),
                  ),
                  title: Text(recolte.typeCulture),
                  subtitle: Text('${moisNoms[recolte.mois]} ${recolte.annee}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${recolte.quantiteRecoltee.toStringAsFixed(0)} ${recolte.uniteMesure}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (recolte.rendement != null)
                        Text(
                          '${recolte.rendement!.toStringAsFixed(1)} kg/ha',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Naviguer vers les détails de la récolte
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChartsView() {
    return Consumer<RecolteProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.recoltes.isEmpty) {
          return const Center(child: Text('Aucune donnée à afficher'));
        }

        final recoltes = provider.recoltes;
        final statistics = provider.statistics;

        // Grouper par mois
        final Map<int, double> quantitesParMois = {};
        for (final recolte in recoltes) {
          quantitesParMois[recolte.mois] = 
              (quantitesParMois[recolte.mois] ?? 0) + recolte.quantiteRecoltee;
        }

        final lineDataPoints = quantitesParMois.entries.map((entry) {
          final moisNoms = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
          return ChartDataPoint(
            x: entry.key.toDouble(),
            y: entry.value,
            label: moisNoms[entry.key],
          );
        }).toList();

        // Grouper par culture
        final Map<String, double> quantitesParCulture = {};
        for (final recolte in recoltes) {
          quantitesParCulture[recolte.typeCulture] = 
              (quantitesParCulture[recolte.typeCulture] ?? 0) + recolte.quantiteRecoltee;
        }

        final totalQuantite = quantitesParCulture.values.reduce((a, b) => a + b);
        final pieSections = quantitesParCulture.entries.map((entry) {
          final percentage = (entry.value / totalQuantite) * 100;
          return PieChartSection(
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            color: _getColorForCulture(entry.key),
            label: entry.key,
            textColor: Colors.white,
          );
        }).toList();

        // Graphique en barres par mois
        final barDataPoints = quantitesParMois.entries.map((entry) {
          final moisNoms = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
          return BarChartDataPoint(
            y: entry.value,
            label: moisNoms[entry.key],
          );
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (statistics != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Minimum', style: TextStyle(fontSize: 12)),
                              Text(
                                statistics.min.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Maximum', style: TextStyle(fontSize: 12)),
                              Text(
                                statistics.max.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Moyenne', style: TextStyle(fontSize: 12)),
                              Text(
                                statistics.moyenne.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              if (lineDataPoints.isNotEmpty)
                LineChartWidget(
                  dataPoints: lineDataPoints,
                  title: 'Évolution des récoltes par mois',
                  yAxisLabel: recoltes.isNotEmpty ? 'Quantité (${recoltes.first.uniteMesure})' : null,
                ),
              
              const SizedBox(height: 16),
              
              if (barDataPoints.isNotEmpty)
                BarChartWidget(
                  dataPoints: barDataPoints,
                  title: 'Récoltes par mois (barres)',
                  yAxisLabel: recoltes.isNotEmpty ? 'Quantité (${recoltes.first.uniteMesure})' : null,
                ),
              
              const SizedBox(height: 16),
              
              if (pieSections.isNotEmpty)
                PieChartWidget(
                  sections: pieSections,
                  title: 'Répartition par type de culture',
                ),
              
              // Prévision si exploitation et culture sélectionnés
              if (_selectedExploitationId != null && _selectedTypeCulture != null) ...[
                const SizedBox(height: 16),
                Consumer<RecolteProvider>(
                  builder: (context, recolteProvider, _) {
                    if (recolteProvider.prevision != null) {
                      final prevision = recolteProvider.prevision!;
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final prevision = snapshot.data!;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Prévision pour la prochaine récolte',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Text('Quantité prévue: ${prevision.quantitePrevue.toStringAsFixed(0)} ${recoltes.first.uniteMesure}'),
                              const SizedBox(height: 8),
                              Text('Probabilité de bonne récolte: ${prevision.probabiliteBonne.toStringAsFixed(1)}%'),
                              Text('Probabilité de mauvaise récolte: ${prevision.probabiliteMauvaise.toStringAsFixed(1)}%'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getPredictionColor(prevision.prediction).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getPredictionIcon(prevision.prediction),
                                      color: _getPredictionColor(prevision.prediction),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Prévision: ${prevision.prediction.toUpperCase()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _getPredictionColor(prevision.prediction),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (prevision.raison != null) ...[
                                const SizedBox(height: 8),
                                Text(prevision.raison!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getColorForCulture(String culture) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[culture.hashCode % colors.length];
  }

  Color _getPredictionColor(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'excellente':
        return Colors.green;
      case 'bonne':
        return Colors.blue;
      case 'moyenne':
        return Colors.orange;
      case 'mauvaise':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPredictionIcon(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'excellente':
        return Icons.trending_up;
      case 'bonne':
        return Icons.check_circle;
      case 'moyenne':
        return Icons.remove_circle;
      case 'mauvaise':
        return Icons.trending_down;
      default:
        return Icons.help;
    }
  }
}

