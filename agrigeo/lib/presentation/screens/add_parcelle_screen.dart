import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parcelle_provider.dart';
import '../../data/models/exploitation_model.dart';

class AddParcelleScreen extends StatefulWidget {
  final ExploitationModel exploitation;

  const AddParcelleScreen({
    super.key,
    required this.exploitation,
  });

  @override
  State<AddParcelleScreen> createState() => _AddParcelleScreenState();
}

class _AddParcelleScreenState extends State<AddParcelleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _superficieController = TextEditingController();
  final _typeCultureController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _superficieController.dispose();
    _typeCultureController.dispose();
    super.dispose();
  }

  Future<void> _saveParcelle() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        'superficie': double.parse(_superficieController.text),
        'type_culture': _typeCultureController.text.trim().isEmpty
            ? null
            : _typeCultureController.text.trim(),
        'exploitation_id': widget.exploitation.id,
      };

      final provider = Provider.of<ParcelleProvider>(context, listen: false);
      final success = await provider.createParcelle(data);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parcelle créée avec succès'),
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
        title: const Text('Nouvelle parcelle'),
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
                  child: Text(
                    'Exploitation: ${widget.exploitation.nom}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la parcelle *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _superficieController,
                decoration: const InputDecoration(
                  labelText: 'Superficie (ha) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La superficie est requise';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeCultureController,
                decoration: const InputDecoration(
                  labelText: 'Type de culture',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<ParcelleProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveParcelle,
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
                        : const Text('Enregistrer'),
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




