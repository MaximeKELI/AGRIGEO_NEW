import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exploitation_provider.dart';
import '../providers/chat_provider.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurer la clé API Gemini au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).setApiKey('AIzaSyABPjT80rKdL1WFSCsEyUJehFgUP8PMnrY');
      Provider.of<ExploitationProvider>(context, listen: false).loadExploitations();
    });
    
    return const DashboardScreen();
  }
}

