import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Récupérer l'utilisateur actuel
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Réauthentifier l'utilisateur
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPasswordController.text,
          );

          await user.reauthenticateWithCredential(credential);

          // Changer le mot de passe
          await user.updatePassword(_newPasswordController.text);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mot de passe modifié avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            // Vider les champs
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'wrong-password':
            message = 'Le mot de passe actuel est incorrect';
            break;
          case 'weak-password':
            message = 'Le nouveau mot de passe est trop faible';
            break;
          default:
            message = 'Une erreur est survenue: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        backgroundColor: const Color(0xFF0F6134),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Mot de passe
            const Text(
              'Changer le mot de passe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6134),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Mot de passe actuel
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: !_showCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe actuel',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _showCurrentPassword = !_showCurrentPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe actuel';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nouveau mot de passe
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nouveau mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirmer le nouveau mot de passe
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer le nouveau mot de passe';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bouton de validation
                  ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F6134),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Changer le mot de passe'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section Authentification à deux facteurs
            const Text(
              'Authentification à deux facteurs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6134),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Activer l\'authentification à deux facteurs'),
              subtitle: const Text(
                'Ajouter une couche de sécurité supplémentaire à votre compte',
              ),
              trailing: Switch(
                value: false, // À implémenter plus tard
                onChanged: (bool value) {
                  // TODO: Implémenter l'authentification à deux facteurs
                },
                activeColor: const Color(0xFF0F6134),
              ),
            ),

            const SizedBox(height: 32),

            // Section Appareils connectés
            const Text(
              'Appareils connectés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6134),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.devices, color: Color(0xFF0F6134)),
              title: const Text('Gérer les appareils connectés'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implémenter la gestion des appareils
              },
            ),
          ],
        ),
      ),
    );
  }
}
