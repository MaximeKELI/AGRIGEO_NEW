import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exploitation_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/animations/animations.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurer la clé API Gemini au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).setApiKey('AIzaSyCwt5NygybBr9oasALOG7Ht-XhM2Dk-sIk');
      Provider.of<ExploitationProvider>(context, listen: false).loadExploitations();
    });
    
    return const DashboardScreen();
  }
}

