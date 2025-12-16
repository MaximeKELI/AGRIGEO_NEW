import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/intrant_provider.dart';
import '../../data/models/exploitation_model.dart';
import '../../data/models/parcelle_model.dart';

class AddIntrantScreen extends StatefulWidget {
  final ExploitationModel exploitation;
  final ParcelleModel? parcelle;

  const AddIntrantScreen({
    super.key,
    required this.exploitation,
    this.parcelle,
  });

  @override
  State<AddIntrantScreen> createState() => _AddIntrantScreenState();
}

class _AddIntrantScreenState extends State<AddIntrantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _nomCommercialController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _cultureController = TextEditingController();
  String _unite = 'kg';
  DateTime? _dateApplication;

  @override
  void initState() {
    super.initState();
    _dateApplication = DateTime.now();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _nomCommercialController.dispose();
    _quantiteController.dispose();
    _cultureController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateApplication ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateApplication = picked;
      });
    }
  }

  Future<void> _saveIntrant() async {
    if (_formKey.currentState!.validate() && _dateApplication != null) {
      final data = {
        'type_intrant': _typeController.text.trim(),
        'nom_commercial': _nomCommercialController.text.trim().isEmpty
            ? null
            : _nomCommercialController.text.trim(),
        'quantite': double.parse(_quantiteController.text),
        'unite': _unite,
        'date_application': DateFormat('yyyy-MM-dd').format(_dateApplication!),
        'culture_concernée': _cultureController.text.trim().isEmpty
            ? null
            : _cultureController.text.trim(),
        'exploitation_id': widget.exploitation.id,
        if (widget.parcelle != null) 'parcelle_id': widget.parcelle!.id,
      };

      final provider = Provider.of<IntrantProvider>(context, listen: false);
      final success = await provider.createIntrant(data);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Intrant créé avec succès'),
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
        title: const Text('Nouvel intrant'),
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
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type d\'intrant *',
                  hintText: 'Ex: Engrais, Pesticide, Semence',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le type d\'intrant est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomCommercialController,
                decoration: const InputDecoration(
                  labelText: 'Nom commercial',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantiteController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La quantité est requise';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unite,
                      decoration: const InputDecoration(
                        labelText: 'Unité',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'L', child: Text('L')),
                        DropdownMenuItem(value: 'unités', child: Text('unités')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _unite = value ?? 'kg';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'application *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateApplication != null
                        ? DateFormat('dd/MM/yyyy').format(_dateApplication!)
                        : 'Sélectionner une date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cultureController,
                decoration: const InputDecoration(
                  labelText: 'Culture concernée',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<IntrantProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveIntrant,
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

