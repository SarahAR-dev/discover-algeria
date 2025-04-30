import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_info_screen.dart';
import 'security_screen.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF0F6134),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Section Compte
          _buildSectionTitle('Compte'),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF0F6134)),
            title: const Text('Informations du compte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileInfoScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.security, color: Color(0xFF0F6134)),
            title: const Text('Sécurité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityScreen()),
              );
            },
          ),

          const Divider(),

          // Section Application
          _buildSectionTitle('Application'),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Activer les notifications push'),
            secondary: const Icon(
              Icons.notifications,
              color: Color(0xFF0F6134),
            ),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Localisation'),
            subtitle: const Text('Autoriser l\'accès à la localisation'),
            secondary: const Icon(Icons.location_on, color: Color(0xFF0F6134)),
            value: _locationEnabled,
            onChanged: (bool value) {
              setState(() {
                _locationEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Mode sombre'),
            subtitle: const Text('Changer l\'apparence de l\'application'),
            secondary: const Icon(Icons.dark_mode, color: Color(0xFF0F6134)),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF0F6134)),
            title: const Text('Langue'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
              items:
                  <String>[
                    'Français',
                    'English',
                    'العربية',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
          ),

          const Divider(),

          // Section Aide et Support
          _buildSectionTitle('Aide et Support'),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF0F6134)),
            title: const Text('Centre d\'aide'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF0F6134)),
            title: const Text('À propos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Color(0xFF0F6134),
            ),
            title: const Text('Politique de confidentialité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Section Données
          _buildSectionTitle('Données'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Supprimer mon compte'),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),

          const SizedBox(height: 32),

          // Version de l'application
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F6134),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.currentUser?.delete();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Une erreur est survenue lors de la suppression du compte',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
