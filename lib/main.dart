/*import 'package:app_pfe/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/LoginScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134); // Vert du drapeau algérien

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorer DZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}*/

/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_pfe/firebase_options.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134); // Vert du drapeau algérien

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}*/

/*
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Vérifier l'état initial de l'authentification
  final user = FirebaseAuth.instance.currentUser;
  print('État initial de l\'authentification:');
  print('Utilisateur connecté: ${user != null}');
  if (user != null) {
    print('UID: ${user.uid}');
    print('Est anonyme: ${user.isAnonymous}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134); // Vert du drapeau algérien

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
*/
/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialisé avec succès");

    // Vérifier si l'authentification anonyme fonctionne
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("✅ Test de connexion anonyme réussi");
      print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");

      // Déconnexion du test
      await FirebaseAuth.instance.signOut();
      print("✅ Déconnexion du test réussie");
    } on FirebaseAuthException catch (e) {
      print("❌ Erreur d'authentification anonyme: ${e.code}");
      print("📝 Message: ${e.message}");
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: algeriaDarkGreen,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}*/

/*
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialisé avec succès");

    // Vérifier si l'authentification anonyme fonctionne
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("✅ Test de connexion anonyme réussi");
      print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");

      // Déconnexion du test
      await FirebaseAuth.instance.signOut();
      print("✅ Déconnexion du test réussie");
    } on FirebaseAuthException catch (e) {
      print("❌ Erreur d'authentification anonyme: ${e.code}");
      print("📝 Message: ${e.message}");
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: algeriaDarkGreen,
          ),
        ),
      ),
      home: const WelcomeScreen(),  // Changer ici pour WelcomeScreen
    );
  }
} */

/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Screens/welcome_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/email_verification_screen.dart';
import 'Screens/SplashScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Définir la langue de Firebase en français
    await FirebaseAuth.instance.setLanguageCode('fr');
    print("✅ Firebase initialisé avec succès");

    // Vérifier si l'authentification anonyme fonctionne
    /*try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("✅ Test de connexion anonyme réussi");
      print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");

      // Déconnexion du test
      await FirebaseAuth.instance.signOut();
      print("✅ Déconnexion du test réussie");
    } on FirebaseAuthException catch (e) {
      print("❌ Erreur d'authentification anonyme: ${e.code}");
      print("📝 Message: ${e.message}");
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }*/


    // Activer la persistance
    /*if (kIsWeb) {
      // Persistance pour le web (si votre app tourne sur le web)
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }*/
// Sur mobile, la persistance est activée par défaut si vous ne faites pas de signOut
    print("✅ Firebase initialisé avec succès");

    // Seulement en mode développement
    bool isDebugMode = false ; // Mettez à true uniquement pendant les tests
    if (isDebugMode) {
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        print("✅ Test de connexion anonyme réussi");
        print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");
        // Déconnexion du test
        await FirebaseAuth.instance.signOut();
        print("✅ Déconnexion du test réussie");
      } on FirebaseAuthException catch (e) {
        print("❌ Erreur d'authentification anonyme: ${e.code}");
        print("📝 Message: ${e.message}");
      }
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,



        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: /*Colors.grey[100]*/ Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: algeriaDarkGreen),
        ),
      ),
      // Ajout des routes nommées
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
      },
    );
  }
}*/






/*import 'package:app_pfe/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/LoginScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134); // Vert du drapeau algérien

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorer DZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}*/

/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_pfe/firebase_options.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134); // Vert du drapeau algérien

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}*/

/*
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Vérifier l'état initial de l'authentification
  final user = FirebaseAuth.instance.currentUser;
  print('État initial de l\'authentification:');
  print('Utilisateur connecté: ${user != null}');
  if (user != null) {
    print('UID: ${user.uid}');
    print('Est anonyme: ${user.isAnonymous}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134); // Vert du drapeau algérien

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
*/
/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialisé avec succès");

    // Vérifier si l'authentification anonyme fonctionne
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("✅ Test de connexion anonyme réussi");
      print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");

      // Déconnexion du test
      await FirebaseAuth.instance.signOut();
      print("✅ Déconnexion du test réussie");
    } on FirebaseAuthException catch (e) {
      print("❌ Erreur d'authentification anonyme: ${e.code}");
      print("📝 Message: ${e.message}");
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: algeriaDarkGreen,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}*/

/*
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialisé avec succès");

    // Vérifier si l'authentification anonyme fonctionne
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("✅ Test de connexion anonyme réussi");
      print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");

      // Déconnexion du test
      await FirebaseAuth.instance.signOut();
      print("✅ Déconnexion du test réussie");
    } on FirebaseAuthException catch (e) {
      print("❌ Erreur d'authentification anonyme: ${e.code}");
      print("📝 Message: ${e.message}");
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: algeriaDarkGreen,
          ),
        ),
      ),
      home: const WelcomeScreen(),  // Changer ici pour WelcomeScreen
    );
  }
} */

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Screens/welcome_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/email_verification_screen.dart';
import 'Screens/SplashScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Définir la langue de Firebase en français
    await FirebaseAuth.instance.setLanguageCode('fr');
    print("✅ Firebase initialisé avec succès");

    // Vérifier si l'authentification anonyme fonctionne
    /*try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("✅ Test de connexion anonyme réussi");
      print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");

      // Déconnexion du test
      await FirebaseAuth.instance.signOut();
      print("✅ Déconnexion du test réussie");
    } on FirebaseAuthException catch (e) {
      print("❌ Erreur d'authentification anonyme: ${e.code}");
      print("📝 Message: ${e.message}");
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }*/


    // Activer la persistance
    /*if (kIsWeb) {
      // Persistance pour le web (si votre app tourne sur le web)
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }*/
// Sur mobile, la persistance est activée par défaut si vous ne faites pas de signOut
    print("✅ Firebase initialisé avec succès");

    // Seulement en mode développement
    bool isDebugMode = false ; // Mettez à true uniquement pendant les tests
    if (isDebugMode) {
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        print("✅ Test de connexion anonyme réussi");
        print("📱 UID de l'utilisateur test: ${userCredential.user?.uid}");
        // Déconnexion du test
        await FirebaseAuth.instance.signOut();
        print("✅ Déconnexion du test réussie");
      } on FirebaseAuthException catch (e) {
        print("❌ Erreur d'authentification anonyme: ${e.code}");
        print("📝 Message: ${e.message}");
      }
    }
  } catch (e) {
    print("❌ Erreur d'initialisation Firebase: $e");
  }



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const algeriaDarkGreen = Color(0xFF0F6134);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: algeriaDarkGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: algeriaDarkGreen,
          primary: algeriaDarkGreen,
        ),
        useMaterial3: true,



        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: /*Colors.grey[100]*/ Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: algeriaDarkGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: algeriaDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: algeriaDarkGreen),
        ),
      ),
      // Ajout des routes nommées
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
      },
    );
  }
}

