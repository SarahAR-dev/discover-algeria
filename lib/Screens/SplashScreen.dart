
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthState();
  }

  void checkAuthState() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await Future.delayed(Duration(seconds: 5)); // Attente pour afficher le splash

    if (!mounted) return; // Vérifier si le widget est toujours monté

    if (currentUser == null) {
      // Aucun utilisateur connecté, aller à l'écran d'accueil
      //Navigator.pushReplacementNamed(context, '/');
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
    else {
      // Utilisateur déjà connecté, garder la session
      print('Utilisateur déjà connecté: ${currentUser.uid}');
      print('Est anonyme: ${currentUser.isAnonymous}');
      //Navigator.pushReplacementNamed(context, '/home' );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [



            // Logo ou icône de l'application
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            // Nom de l'application
            Text(
              'Tour Explorer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            // Slogan de l'application
            Text(
              'Découvrez les merveilles de l\'Algérie',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            // Indicateur de chargement
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
    ),
    );
  }
}