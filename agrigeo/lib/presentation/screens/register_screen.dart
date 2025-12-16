import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/slide_in_widget.dart';
import '../widgets/animations/scale_in_widget.dart';
import '../widgets/animations/staggered_list_widget.dart';
import '../widgets/animations/animated_button.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/user_model.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _zoneInterventionController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int? _selectedRoleId = 1; // Par défaut: Agriculteur (id=1)
  List<RoleModel> _roles = [];
  bool _isLoadingRoles = false;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.getPublicRoles();
      final List<dynamic> rolesData = response.data;
      
      setState(() {
        _roles = rolesData.map((json) => RoleModel.fromJson(json)).toList();
        if (_roles.isNotEmpty) {
          _selectedRoleId = _roles.first.id;
        }
        _isLoadingRoles = false;
      });
    } catch (e) {
      // En cas d'erreur, utiliser les rôles par défaut
      if (mounted) {
        setState(() {
          _roles = [
            RoleModel(id: 1, nom: 'Agriculteur', description: 'Producteur agricole'),
          ];
          _selectedRoleId = 1;
          _isLoadingRoles = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _zoneInterventionController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRoleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un rôle'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final registrationData = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role_id': _selectedRoleId!,
        if (_nomController.text.trim().isNotEmpty) 'nom': _nomController.text.trim(),
        if (_prenomController.text.trim().isNotEmpty) 'prenom': _prenomController.text.trim(),
        if (_telephoneController.text.trim().isNotEmpty) 'telephone': _telephoneController.text.trim(),
        if (_zoneInterventionController.text.trim().isNotEmpty) 
          'zone_intervention': _zoneInterventionController.text.trim(),
      };

      final success = await authProvider.register(registrationData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else if (mounted) {
        final errorMessage = authProvider.error ?? 'Erreur lors de l\'inscription';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Fermer',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInWidget(
          child: const Text('Inscription'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: StaggeredListWidget(
                  staggerDuration: const Duration(milliseconds: 80),
                  children: [
                    ScaleInWidget(
                      delay: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.person_add,
                        size: 80,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: const Text(
                        'Créer un compte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 400),
                      child: const Text(
                        'Rejoignez AGRIGEO pour gérer vos exploitations',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  
                    // Nom d'utilisateur
                    SlideInWidget(
                      delay: const Duration(milliseconds: 500),
                      direction: AxisDirection.left,
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Nom d\'utilisateur *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          helperText: 'Minimum 3 caractères',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom d\'utilisateur';
                          }
                          if (value.length < 3) {
                            return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    SlideInWidget(
                      delay: const Duration(milliseconds: 580),
                      direction: AxisDirection.right,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Mot de passe
                    SlideInWidget(
                      delay: const Duration(milliseconds: 660),
                      direction: AxisDirection.left,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe *',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          helperText: 'Minimum 6 caractères',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirmation mot de passe
                    SlideInWidget(
                      delay: const Duration(milliseconds: 740),
                      direction: AxisDirection.right,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Rôle
                    SlideInWidget(
                      delay: const Duration(milliseconds: 820),
                      direction: AxisDirection.down,
                      child: _isLoadingRoles
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<int>(
                              value: _selectedRoleId,
                              decoration: InputDecoration(
                                labelText: 'Rôle *',
                                prefixIcon: const Icon(Icons.badge),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _roles.map((role) {
                                return DropdownMenuItem<int>(
                                  value: role.id,
                                  child: Text(
                                    role.description != null && role.description!.isNotEmpty
                                        ? '${role.nom} - ${role.description}'
                                        : role.nom,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoleId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un rôle';
                                }
                                return null;
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nom
                    SlideInWidget(
                      delay: const Duration(milliseconds: 900),
                      direction: AxisDirection.left,
                      child: TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Prénom
                    SlideInWidget(
                      delay: const Duration(milliseconds: 980),
                      direction: AxisDirection.right,
                      child: TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Téléphone
                    SlideInWidget(
                      delay: const Duration(milliseconds: 1060),
                      direction: AxisDirection.left,
                      child: TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Zone d'intervention
                    SlideInWidget(
                      delay: const Duration(milliseconds: 1140),
                      direction: AxisDirection.right,
                      child: TextFormField(
                        controller: _zoneInterventionController,
                        decoration: InputDecoration(
                          labelText: 'Zone d\'intervention',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          helperText: 'Région ou zone géographique',
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton d'inscription
                    FadeInWidget(
                      delay: const Duration(milliseconds: 1220),
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return AnimatedButton(
                            text: 'S\'inscrire',
                            icon: Icons.person_add,
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            onPressed: authProvider.isLoading ? null : _handleRegister,
                            isLoading: authProvider.isLoading,
                            borderRadius: 12,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Lien vers connexion
                    FadeInWidget(
                      delay: const Duration(milliseconds: 1300),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'Déjà un compte ? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

