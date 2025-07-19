import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';
import 'my_reviews_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //final user = FirebaseAuth.instance.currentUser;

  bool _wasSignedOut = false;




  @override
  Widget build(BuildContext context){

    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;
    final isAnonymous = user?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
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
        backgroundColor:  const Color(0xFF0F6134) ,
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
                  // Bouton modifier le profil
                  /*OutlinedButton.icon(
                    onPressed: () async {
                      // Naviguer vers l'écran de modification
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );

                      // Si des modifications ont été apportées, actualiser l'écran
                      if (result == true && mounted) {
                        setState(() {
                          // Cela va recharger les données du profil
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier le profil'),
                  ),*/
                ],
              ),
            ),

            // Statistiques
            /*Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Visités', '0'),
                  _buildStatItem('À visiter', '0'),
                  _buildStatItem('Avis', '0'),
                ],
              ),
            ),*/

            //const Divider(),

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
            _buildListTile(icon: Icons.star, title: 'Mes avis', onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyReviewsScreen()),
            );}),

            /*_buildListTile(
              icon: Icons.map,
              title: 'Mes itinéraires',
              onTap: () {},
            ),*/
            /*_buildListTile(
              icon: Icons.help,
              title: 'Aide et support',
              onTap: () {},
            ),*/

            const Divider(),




            // modiiiiiiiiiiiiiiiif

            // Bouton de connexion ou déconnexion
      Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () async {
            if (isAuthenticated && !isAnonymous) {
              // Utilisateur authentifié (pas anonyme) => se déconnecter
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  setState(() {}); // Force le rafraîchissement de l'interface
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la déconnexion: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              // Utilisateur non authentifié ou anonyme => aller à l'écran de connexion
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          icon: Icon(
              isAuthenticated && !isAnonymous ? Icons.logout : Icons.login
          ),
          label: Text(
              isAuthenticated && !isAnonymous ? 'Se déconnecter' : 'Se connecter'
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isAuthenticated && !isAnonymous ? Colors.red : Theme.of(context).primaryColor,
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
          style: const TextStyle(   //Color(0xFF0F6134)
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
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
