import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/recolte_provider.dart';
import '../../data/models/recolte_model.dart';

class AddRecolteScreen extends StatefulWidget {
  final int exploitationId;
  final int? parcelleId;
  final RecolteModel? recolte; // Pour l'édition

  const AddRecolteScreen({
    super.key,
    required this.exploitationId,
    this.parcelleId,
    this.recolte,
  });

  @override
  State<AddRecolteScreen> createState() => _AddRecolteScreenState();
}

class _AddRecolteScreenState extends State<AddRecolteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeCultureController = TextEditingController();
  final _moisController = TextEditingController();
  final _anneeController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _uniteController = TextEditingController();
  final _superficieController = TextEditingController();
  final _prixController = TextEditingController();
  final _coutController = TextEditingController();
  final _qualiteController = TextEditingController();
  final _observationsController = TextEditingController();

  int? _selectedMois;
  int? _selectedAnnee;
  String _selectedUnite = 'kg';
  String? _selectedQualite;

  @override
  void initState() {
    super.initState();
    _selectedAnnee = DateTime.now().year;
    
    if (widget.recolte != null) {
      final recolte = widget.recolte!;
      _typeCultureController.text = recolte.typeCulture;
      _selectedMois = recolte.mois;
      _selectedAnnee = recolte.annee;
      _quantiteController.text = recolte.quantiteRecoltee.toString();
      _selectedUnite = recolte.uniteMesure;
      _superficieController.text = recolte.superficieRecoltee?.toString() ?? '';
      _prixController.text = recolte.prixVente?.toString() ?? '';
      _coutController.text = recolte.coutProduction?.toString() ?? '';
      _selectedQualite = recolte.qualite;
      _observationsController.text = recolte.observations ?? '';
    }
  }

  @override
  void dispose() {
    _typeCultureController.dispose();
    _moisController.dispose();
    _anneeController.dispose();
    _quantiteController.dispose();
    _uniteController.dispose();
    _superficieController.dispose();
    _prixController.dispose();
    _coutController.dispose();
    _qualiteController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecolte() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMois == null || _selectedAnnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner le mois et l\'année'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final recolte = RecolteModel(
      id: widget.recolte?.id ?? 0,
      exploitationId: widget.exploitationId,
      parcelleId: widget.parcelleId,
      typeCulture: _typeCultureController.text.trim(),
      mois: _selectedMois!,
      annee: _selectedAnnee!,
      quantiteRecoltee: double.parse(_quantiteController.text),
      uniteMesure: _selectedUnite,
      superficieRecoltee: _superficieController.text.isNotEmpty
          ? double.tryParse(_superficieController.text)
          : null,
      prixVente: _prixController.text.isNotEmpty
          ? double.tryParse(_prixController.text)
          : null,
      coutProduction: _coutController.text.isNotEmpty
          ? double.tryParse(_coutController.text)
          : null,
      qualite: _selectedQualite,
      observations: _observationsController.text.trim().isNotEmpty
          ? _observationsController.text.trim()
          : null,
    );

    final provider = Provider.of<RecolteProvider>(context, listen: false);
    final success = widget.recolte == null
        ? await provider.createRecolte(recolte)
        : await provider.updateRecolte(recolte.id, recolte);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recolte == null
                ? 'Récolte ajoutée avec succès'
                : 'Récolte modifiée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur lors de la sauvegarde'),
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
        title: Text(widget.recolte == null ? 'Nouvelle récolte' : 'Modifier la récolte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _typeCultureController,
                decoration: const InputDecoration(
                  labelText: 'Type de culture *',
                  hintText: 'Ex: Maïs, Riz, Manioc',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le type de culture';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMois,
                      decoration: const InputDecoration(
                        labelText: 'Mois *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) {
                        final moisNoms = [
                          'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
                        ];
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(moisNoms[index]),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedMois = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner le mois';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedAnnee,
                      decoration: const InputDecoration(
                        labelText: 'Année *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) {
                        final annee = DateTime.now().year - index;
                        return DropdownMenuItem<int>(
                          value: annee,
                          child: Text(annee.toString()),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedAnnee = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner l\'année';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantiteController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité récoltée *',
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir la quantité';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Valeur invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnite,
                      decoration: const InputDecoration(
                        labelText: 'Unité',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'tonnes', child: Text('tonnes')),
                        DropdownMenuItem(value: 'sacs', child: Text('sacs')),
                        DropdownMenuItem(value: 'paniers', child: Text('paniers')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedUnite = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _superficieController,
                decoration: const InputDecoration(
                  labelText: 'Superficie récoltée (hectares)',
                  hintText: '0.0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prixController,
                      decoration: const InputDecoration(
                        labelText: 'Prix de vente unitaire',
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _coutController,
                      decoration: const InputDecoration(
                        labelText: 'Coût de production',
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedQualite,
                decoration: const InputDecoration(
                  labelText: 'Qualité',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'excellente', child: Text('Excellente')),
                  DropdownMenuItem(value: 'bonne', child: Text('Bonne')),
                  DropdownMenuItem(value: 'moyenne', child: Text('Moyenne')),
                  DropdownMenuItem(value: 'mauvaise', child: Text('Mauvaise')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedQualite = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  labelText: 'Observations',
                  hintText: 'Notes supplémentaires...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _saveRecolte,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




