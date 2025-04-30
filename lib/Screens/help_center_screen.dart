import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@tourexplorer.com',
      queryParameters: {'subject': 'Demande d\'assistance - Tour Explorer'},
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      print('Impossible d\'ouvrir l\'email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre d\'aide'),
        backgroundColor: const Color(0xFF0F6134),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0F6134).withOpacity(0.1),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 50,
                    color: Color(0xFF0F6134),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Comment pouvons-nous vous aider ?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trouvez rapidement des réponses à vos questions',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // FAQ
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Questions fréquentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F6134),
                ),
              ),
            ),

            ExpansionTile(
              title: const Text('Comment créer un compte ?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Pour créer un compte, cliquez sur "S\'inscrire" sur l\'écran d\'accueil. '
                    'Remplissez le formulaire avec votre email et un mot de passe sécurisé. '
                    'Vous recevrez un email de confirmation pour activer votre compte.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Comment réinitialiser mon mot de passe ?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Sur l\'écran de connexion, cliquez sur "Mot de passe oublié". '
                    'Entrez votre email et suivez les instructions envoyées '
                    'pour réinitialiser votre mot de passe.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Comment modifier mon profil ?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Accédez à votre profil via l\'icône en bas à droite. '
                    'Cliquez sur "Modifier le profil" pour changer votre photo, '
                    'nom et autres informations personnelles.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Comment signaler un problème ?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Si vous rencontrez un problème, vous pouvez nous contacter '
                    'via le formulaire de contact ci-dessous ou par email. '
                    'Décrivez le problème en détail pour que nous puissions vous aider au mieux.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contact direct
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nous contacter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F6134),
                ),
              ),
            ),

            // Email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF0F6134)),
                  title: const Text('Envoyer un email'),
                  subtitle: const Text('support@tourexplorer.com'),
                  onTap: _launchEmail,
                ),
              ),
            ),

            // Téléphone
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF0F6134)),
                  title: const Text('Appelez-nous'),
                  subtitle: const Text('Lun-Ven, 9h-18h'),
                  trailing: TextButton(
                    onPressed: () async {
                      final Uri phoneUri = Uri(
                        scheme: 'tel',
                        path: '+213XXXXXXXXX', // Remplacez par votre numéro
                      );
                      try {
                        await launchUrl(phoneUri);
                      } catch (e) {
                        print('Impossible d\'appeler: $e');
                      }
                    },
                    child: const Text(
                      'APPELER',
                      style: TextStyle(color: Color(0xFF0F6134)),
                    ),
                  ),
                ),
              ),
            ),

            // Chat en direct (à implémenter plus tard)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.chat, color: Color(0xFF0F6134)),
                  title: const Text('Chat en direct'),
                  subtitle: const Text('Temps de réponse moyen: 5 min'),
                  onTap: () {
                    // TODO: Implémenter le chat en direct
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Le chat en direct sera bientôt disponible',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
