import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exploitation_provider.dart';
import '../providers/analyse_sol_provider.dart';
import '../providers/intrant_provider.dart';
import '../providers/recommandation_provider.dart';
import '../widgets/animations/animations.dart';
import 'exploitations_list_screen.dart';
import 'analyses_list_screen.dart';
import 'recommandations_screen.dart';
import 'meteo_screen.dart';
import 'chat_screen.dart';
import 'intrants_list_screen.dart';
import 'image_analysis_screen.dart';
import 'add_exploitation_screen.dart';
import 'add_analyse_sol_screen.dart';
import 'add_intrant_screen.dart';
import 'exploitation_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExploitationProvider>(context, listen: false).loadExploitations();
      Provider.of<AnalyseSolProvider>(context, listen: false).loadAnalyses();
      Provider.of<IntrantProvider>(context, listen: false).loadIntrants();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Fermer le drawer
  }

  Widget _buildDashboard() {
    return Consumer<ExploitationProvider>(
      builder: (context, exploitationProvider, _) {
        return Consumer<AnalyseSolProvider>(
          builder: (context, analyseProvider, _) {
            return Consumer<IntrantProvider>(
              builder: (context, intrantProvider, _) {
                return Consumer<RecommandationProvider>(
                  builder: (context, recommandationProvider, _) {
                    final exploitations = exploitationProvider.exploitations;
                    final analyses = analyseProvider.analyses;
                    final intrants = intrantProvider.intrants;
                    final recommandations = recommandationProvider.recommandations;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInWidget(
                            delay: const Duration(milliseconds: 100),
                            child: const Text(
                              'Tableau de bord',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Cartes de statistiques
                          StaggeredListWidget(
                            staggerDuration: const Duration(milliseconds: 100),
                            children: [
                              _buildStatCard(
                                title: 'Exploitations',
                                value: exploitations.length.toString(),
                                icon: Icons.agriculture,
                                color: Colors.green,
                                delay: const Duration(milliseconds: 200),
                              ),
                              _buildStatCard(
                                title: 'Analyses de sol',
                                value: analyses.length.toString(),
                                icon: Icons.science,
                                color: Colors.blue,
                                delay: const Duration(milliseconds: 300),
                              ),
                              _buildStatCard(
                                title: 'Intrants',
                                value: intrants.length.toString(),
                                icon: Icons.eco,
                                color: Colors.orange,
                                delay: const Duration(milliseconds: 400),
                              ),
                              _buildStatCard(
                                title: 'Recommandations',
                                value: recommandations.length.toString(),
                                icon: Icons.lightbulb,
                                color: Colors.purple,
                                delay: const Duration(milliseconds: 500),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Actions rapides
                          FadeInWidget(
                            delay: const Duration(milliseconds: 600),
                            child: const Text(
                              'Actions rapides',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildQuickAction(
                                title: 'Nouvelle exploitation',
                                icon: Icons.add_business,
                                color: Colors.green,
                                onTap: () {
                                  Navigator.pushNamed(context, '/add-exploitation');
                                },
                              ),
                              _buildQuickAction(
                                title: 'Nouvelle analyse',
                                icon: Icons.science_outlined,
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.pushNamed(context, '/add-analyse');
                                },
                              ),
                              _buildQuickAction(
                                title: 'Analyse d\'image',
                                icon: Icons.camera_alt,
                                color: Colors.purple,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ImageAnalysisScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickAction(
                                title: 'Nouvel intrant',
                                icon: Icons.eco_outlined,
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.pushNamed(context, '/add-intrant');
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Dernières activités
                          FadeInWidget(
                            delay: const Duration(milliseconds: 700),
                            child: const Text(
                              'Dernières activités',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (exploitations.isEmpty && analyses.isEmpty)
                            FadeInWidget(
                              delay: const Duration(milliseconds: 800),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Aucune activité récente',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            ...exploitations.take(3).map((exploitation) => 
                              FadeInWidget(
                                delay: Duration(milliseconds: 800 + (exploitations.indexOf(exploitation) * 100)),
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.agriculture, color: Colors.green),
                                    title: Text(exploitation.nom),
                                    subtitle: Text('Exploitation créée'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/exploitation-detail',
                                        arguments: exploitation.id,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Duration delay = Duration.zero,
  }) {
    return ScaleInWidget(
      delay: delay,
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade400,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.agriculture,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'AGRIGEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestion intelligente des sols',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Tableau de bord',
            index: 0,
            isSelected: _selectedIndex == 0,
          ),
          _buildDrawerItem(
            icon: Icons.agriculture,
            title: 'Exploitations',
            index: 1,
            isSelected: _selectedIndex == 1,
          ),
          _buildDrawerItem(
            icon: Icons.science,
            title: 'Analyses de sol',
            index: 2,
            isSelected: _selectedIndex == 2,
          ),
          _buildDrawerItem(
            icon: Icons.eco,
            title: 'Intrants',
            index: 3,
            isSelected: _selectedIndex == 3,
          ),
          _buildDrawerItem(
            icon: Icons.lightbulb,
            title: 'Recommandations',
            index: 4,
            isSelected: _selectedIndex == 4,
          ),
          _buildDrawerItem(
            icon: Icons.cloud,
            title: 'Météo',
            index: 5,
            isSelected: _selectedIndex == 5,
          ),
          _buildDrawerItem(
            icon: Icons.camera_alt,
            title: 'Analyse d\'image',
            index: 6,
            isSelected: _selectedIndex == 6,
          ),
          _buildDrawerItem(
            icon: Icons.chat,
            title: 'Assistant IA',
            index: 7,
            isSelected: _selectedIndex == 7,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers les paramètres
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers l'aide
            },
          ),
          const Divider(),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.green : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.green : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.green.withOpacity(0.1),
      onTap: () => _onItemTapped(index),
    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return _buildDashboard();
      case 1:
        return const ExploitationsListScreen();
      case 2:
        return const AnalysesListScreen();
      case 3:
        return const IntrantsListScreen();
      case 4:
        return const RecommandationsScreen();
      case 5:
        return const MeteoScreen();
      case 6:
        return const ImageAnalysisScreen();
      case 7:
        return const ChatScreen();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AGRIGEO'),
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _getScreenForIndex(_selectedIndex),
      ),
    );
  }
}

