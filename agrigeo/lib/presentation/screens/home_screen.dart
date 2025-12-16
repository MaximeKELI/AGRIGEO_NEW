import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exploitation_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/animations/animations.dart';
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
        title: FadeInWidget(
          delay: const Duration(milliseconds: 200),
          child: Row(
            children: [
              ScaleInWidget(
                delay: const Duration(milliseconds: 100),
                beginScale: 0.5,
                child: const Icon(
                  Icons.agriculture,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text('AGRIGEO'),
            ],
          ),
        ),
        actions: [
          FadeInWidget(
            delay: const Duration(milliseconds: 400),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false).logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const LoginScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, -0.1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            )),
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
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
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: const [
            ExploitationsListScreen(),
            AnalysesListScreen(),
            RecommandationsScreen(),
            MeteoScreen(),
            ChatScreen(), // Chatbot IA
          ],
        ),
      ),
      bottomNavigationBar: FadeInWidget(
        delay: const Duration(milliseconds: 500),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
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
      ),
    );
  }
}

