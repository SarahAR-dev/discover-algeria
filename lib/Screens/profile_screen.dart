import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color(0xFF0F6134),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implémenter les paramètres


              },
          ),
        ],
      ),*/
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color(0xFF0F6134),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête du profil
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Photo de profil
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                    child:
                        user?.photoURL == null
                            ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                  const SizedBox(height: 16),
                  // Nom d'utilisateur
                  Text(
                    user?.displayName ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // Bouton modifier le profil
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implémenter la modification du profil
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier le profil'),
                  ),
                ],
              ),
            ),

            // Statistiques
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Visités', '0'),
                  _buildStatItem('À visiter', '0'),
                  _buildStatItem('Avis', '0'),
                ],
              ),
            ),

            const Divider(),

            // Liste des options
            /*_buildListTile(
              icon: Icons.favorite,
              title: 'Mes favoris',
              onTap: () {},
            ),*/
            _buildListTile(
              icon: Icons.history,
              title: 'Historique des visites',
              onTap: () {},
            ),
            _buildListTile(icon: Icons.star, title: 'Mes avis', onTap: () {}),
            _buildListTile(
              icon: Icons.map,
              title: 'Mes itinéraires',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.help,
              title: 'Aide et support',
              onTap: () {},
            ),

            const Divider(),

            // Bouton de déconnexion
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de la déconnexion'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F6134),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0F6134)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
