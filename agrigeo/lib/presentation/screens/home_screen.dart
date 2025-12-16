import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exploitation_provider.dart';
import '../providers/chat_provider.dart';
import 'exploitations_list_screen.dart';
import 'analyses_list_screen.dart';
import 'recommandations_screen.dart';
import 'meteo_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Configurer la clé API Gemini au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).setApiKey('AIzaSyCwt5NygybBr9oasALOG7Ht-XhM2Dk-sIk');
      Provider.of<ExploitationProvider>(context, listen: false).loadExploitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AGRIGEO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ExploitationsListScreen(),
          AnalysesListScreen(),
          RecommandationsScreen(),
          MeteoScreen(),
          ChatScreen(), // Chatbot IA
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Exploitations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Analyses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Recommandations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Météo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}

