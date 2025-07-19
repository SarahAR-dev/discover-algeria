import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: const Color(0xFF0F6134),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo et nom de l'application
            /*Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png', // Assurez-vous d'avoir votre logo dans les assets
                    height: 100,
                    width: 100,
                  ),*/
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.travel_explore, // Icône de voyage/exploration
                    size: 100,
                    color: Color(0xFF0F6134),
                  ),

                  // ... reste du code
                  const SizedBox(height: 16),
                  const Text(
                    'Tour Explorer',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version $_version',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Description de l'application
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'À propos de Tour Explorer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F6134),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tour Explorer est votre guide touristique personnel en Algérie. '
                    'Notre application vous aide à découvrir les merveilles cachées '
                    'et les destinations populaires à travers le pays.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Fonctionnalités principales
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fonctionnalités principales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F6134),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.explore,
                    'Exploration',
                    'Découvrez des lieux fascinants près de chez vous',
                  ),
                  _buildFeatureItem(
                    Icons.map,
                    'Navigation',
                    'Trouvez facilement votre chemin vers les destinations',
                  ),
                  _buildFeatureItem(
                    Icons.favorite,
                    'Favoris',
                    'Sauvegardez vos lieux préférés',
                  ),
                  _buildFeatureItem(
                    Icons.info,
                    'Informations détaillées',
                    'Accédez à des informations complètes sur chaque lieu',
                  ),
                ],
              ),
            ),

            const Divider(),

            // Développeur
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Développé par',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F6134),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Équipe Tour Explorer',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Droits d'auteur
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© ${DateTime.now().year} Tour Explorer. Tous droits réservés.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F6134), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
