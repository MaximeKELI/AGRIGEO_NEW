import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/openweather_polygon_provider.dart';
import '../../core/constants/app_constants.dart';

class ConfigOpenWeatherAgroScreen extends StatefulWidget {
  const ConfigOpenWeatherAgroScreen({super.key});

  @override
  State<ConfigOpenWeatherAgroScreen> createState() => _ConfigOpenWeatherAgroScreenState();
}

class _ConfigOpenWeatherAgroScreenState extends State<ConfigOpenWeatherAgroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    if (apiKey != null) {
      setState(() {
        _apiKeyController.text = apiKey;
      });
      // Configurer le provider
      Provider.of<OpenWeatherPolygonProvider>(context, listen: false).setApiKey(apiKey);
    }
  }

  Future<void> _saveApiKey() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiKey = _apiKeyController.text.trim();
        
        // Sauvegarder dans les préférences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.openWeatherAgroApiKey, apiKey);
        
        // Configurer le provider
        Provider.of<OpenWeatherPolygonProvider>(context, listen: false).setApiKey(apiKey);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clé API sauvegardée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _openAgroMonitoringWebsite() async {
    final uri = Uri.parse('https://agromonitoring.com/api/get');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration OpenWeather Agro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Clé API OpenWeather Agro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pour utiliser la fonctionnalité de gestion des polygones agricoles, vous devez obtenir une clé API gratuite depuis agromonitoring.com',
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _openAgroMonitoringWebsite,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Obtenir une clé API'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: 'Clé API OpenWeather Agro *',
                  hintText: 'Entrez votre clé API',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureKey = !_obscureKey;
                      });
                    },
                  ),
                  helperText: 'Votre clé API sera stockée localement de manière sécurisée',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La clé API est requise';
                  }
                  if (value.length < 20) {
                    return 'La clé API semble invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

