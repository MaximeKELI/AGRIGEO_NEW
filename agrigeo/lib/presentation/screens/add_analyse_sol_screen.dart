import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/exploitation_model.dart';
import '../../data/models/parcelle_model.dart';
import '../providers/analyse_sol_provider.dart';

class AddAnalyseSolScreen extends StatefulWidget {
  final ExploitationModel exploitation;
  final ParcelleModel? parcelle;

  const AddAnalyseSolScreen({
    super.key,
    required this.exploitation,
    this.parcelle,
  });

  @override
  State<AddAnalyseSolScreen> createState() => _AddAnalyseSolScreenState();
}

class _AddAnalyseSolScreenState extends State<AddAnalyseSolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController();
  final _humiditeController = TextEditingController();
  final _textureController = TextEditingController();
  final _azoteController = TextEditingController();
  final _phosphoreController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _observationsController = TextEditingController();
  
  DateTime? _datePrelevement;
  int? _selectedParcelleId;

  @override
  void initState() {
    super.initState();
    _datePrelevement = DateTime.now();
    _selectedParcelleId = widget.parcelle?.id;
  }

  @override
  void dispose() {
    _phController.dispose();
    _humiditeController.dispose();
    _textureController.dispose();
    _azoteController.dispose();
    _phosphoreController.dispose();
    _potassiumController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _datePrelevement ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _datePrelevement = picked;
      });
    }
  }

  Future<void> _saveAnalyse() async {
    if (_formKey.currentState!.validate() && _datePrelevement != null) {
      final data = {
        'date_prelevement': DateFormat('yyyy-MM-dd').format(_datePrelevement!),
        'exploitation_id': widget.exploitation.id,
        if (_selectedParcelleId != null) 'parcelle_id': _selectedParcelleId,
        if (_phController.text.isNotEmpty) 'ph': double.parse(_phController.text),
        if (_humiditeController.text.isNotEmpty) 'humidite': double.parse(_humiditeController.text),
        if (_textureController.text.isNotEmpty) 'texture': _textureController.text.trim(),
        if (_azoteController.text.isNotEmpty) 'azote_n': double.parse(_azoteController.text),
        if (_phosphoreController.text.isNotEmpty) 'phosphore_p': double.parse(_phosphoreController.text),
        if (_potassiumController.text.isNotEmpty) 'potassium_k': double.parse(_potassiumController.text),
        if (_observationsController.text.isNotEmpty) 'observations': _observationsController.text.trim(),
      };

      final provider = Provider.of<AnalyseSolProvider>(context, listen: false);
      final success = await provider.createAnalyse(data);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analyse de sol créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur lors de la création'),
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
        title: const Text('Nouvelle analyse de sol'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exploitation: ${widget.exploitation.nom}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.parcelle != null)
                        Text('Parcelle: ${widget.parcelle!.nom}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Date de prélèvement
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de prélèvement *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _datePrelevement != null
                        ? DateFormat('dd/MM/yyyy').format(_datePrelevement!)
                        : 'Sélectionner une date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // pH
              TextFormField(
                controller: _phController,
                decoration: const InputDecoration(
                  labelText: 'pH',
                  hintText: 'Ex: 6.5',
                  border: OutlineInputBorder(),
                  helperText: 'pH optimal: 6.0 - 7.5',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final ph = double.tryParse(value);
                    if (ph == null || ph < 0 || ph > 14) {
                      return 'pH doit être entre 0 et 14';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Humidité
              TextFormField(
                controller: _humiditeController,
                decoration: const InputDecoration(
                  labelText: 'Humidité (%)',
                  hintText: 'Ex: 25.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final hum = double.tryParse(value);
                    if (hum == null || hum < 0 || hum > 100) {
                      return 'Humidité doit être entre 0 et 100%';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Texture
              TextFormField(
                controller: _textureController,
                decoration: const InputDecoration(
                  labelText: 'Texture',
                  hintText: 'Ex: Sableux, Argileux, Limoneux',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Nutriments
              const Text(
                'Nutriments (mg/kg)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _azoteController,
                      decoration: const InputDecoration(
                        labelText: 'Azote (N)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phosphoreController,
                      decoration: const InputDecoration(
                        labelText: 'Phosphore (P)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _potassiumController,
                      decoration: const InputDecoration(
                        labelText: 'Potassium (K)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Observations
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  labelText: 'Observations',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Consumer<AnalyseSolProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveAnalyse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Enregistrer l\'analyse'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

