import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        backgroundColor: const Color(0xFF0F6134),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Politique de confidentialité de Tour Explorer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6134),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'Introduction',
              'Tour Explorer s\'engage à protéger votre vie privée. Cette politique explique comment nous collectons, utilisons et protégeons vos données personnelles lors de l\'utilisation de notre application.',
            ),

            _buildSection(
              'Données collectées',
              'Nous collectons les informations suivantes :\n'
                  '• Informations de profil (nom, email)\n'
                  '• Données de localisation (avec votre permission)\n'
                  '• Préférences de voyage\n'
                  '• Historique des lieux visités',
            ),

            _buildSection(
              'Utilisation des données',
              'Nous utilisons vos données pour :\n'
                  '• Personnaliser votre expérience\n'
                  '• Améliorer notre service\n'
                  '• Vous montrer des lieux pertinents\n'
                  '• Sauvegarder vos préférences',
            ),

            _buildSection(
              'Protection des données',
              'Nous protégeons vos données en :\n'
                  '• Limitant l\'accès aux données\n'
                  '• Ne partageant pas vos informations avec des tiers\n'
                  '• Respectant les normes de sécurité',
            ),

            _buildSection(
              'Vos droits',
              'Vous avez le droit de :\n'
                  '• Accéder à vos données\n'
                  '• Modifier vos informations\n'
                  '• Supprimer votre compte\n'
                  '• Désactiver la localisation',
            ),

            /*_buildSection(
              'Cookies et stockage',
              'Nous utilisons le stockage local pour :\n'
                  '• Sauvegarder vos préférences\n'
                  '• Améliorer les performances\n'
                  '• Maintenir votre session',
            ),*/

            _buildSection(
              'Partage des données',
              'Nous ne partageons pas vos données personnelles avec des tiers. Vos informations restent confidentielles et sont uniquement utilisées pour améliorer votre expérience sur Tour Explorer.',
            ),

            _buildSection(
              'Modifications',
              'Nous nous réservons le droit de modifier cette politique. Les changements seront notifiés via l\'application et prendront effet immédiatement.',
            ),

            _buildSection(
              'Contact',
              'Pour toute question concernant votre vie privée, contactez-nous à :\n'
                  'tourexplorer.support@gmail.com',
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                '© ${DateTime.now().year} Tour Explorer. Tous droits réservés.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F6134),
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}
