/*


import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Méthode de connexion anonyme
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      print('Connexion anonyme réussie');
      print('UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('Erreur lors de la connexion anonyme: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Vérifier si un utilisateur Google existe déjà avec cet email
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Sélection du compte Google annulée';
      }

      print('Tentative de connexion avec: ${googleUser.email}');

      // 2. Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Déconnecter l'utilisateur actuel s'il est anonyme
      if (_auth.currentUser?.isAnonymous ?? false) {
        await _auth.currentUser?.delete();
      }

      // 4. Tenter de se connecter avec les credentials Google
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 5. Vérifications post-connexion
        if (user.isAnonymous) {
          print('ERREUR: Utilisateur toujours anonyme après connexion Google');
          await _auth.signOut();
          throw 'Erreur de connexion: utilisateur resté anonyme';
        }

        // Vérifier le provider
        final isGoogleProvider = user.providerData
            .any((element) => element.providerId == 'google.com');

        if (!isGoogleProvider) {
          print('ERREUR: Provider Google non trouvé');
          await _auth.signOut();
          throw 'Erreur de connexion: provider Google non trouvé';
        }

        print('Connexion Google réussie:');
        print('Email: ${user.email}');
        print('Nom: ${user.displayName}');
        print('Provider ID: google.com');
        print('UID: ${user.uid}');
      }

      return userCredential;

    } on FirebaseAuthException catch (e) {
      print('Erreur FirebaseAuth: ${e.code} - ${e.message}');
      if (e.code == 'account-exists-with-different-credential') {
        // Gérer le cas où le compte existe déjà
        final String email = e.email ?? '';
        final List<String> providers = await _auth.fetchSignInMethodsForEmail(email);
        print('Compte existant pour $email. Providers disponibles: $providers');
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
      rethrow;
    } catch (e) {
      print('Erreur générale: $e');
      await _googleSignIn.signOut();
      await _auth.signOut();
      rethrow;
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'état de l'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Vérifier le statut de connexion actuel
  Future<void> checkCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      print('Utilisateur actuel:');
      print('UID: ${user.uid}');
      print('Email: ${user.email}');
      print('Anonyme: ${user.isAnonymous}');
      print('Providers: ${user.providerData.map((e) => e.providerId).join(', ')}');
    } else {
      print('Aucun utilisateur connecté');
    }
  }
}*/

/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'état de l'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Méthode de connexion Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. D'abord, déconnexion complète pour nettoyer tout état
      await _auth.signOut();
      await _googleSignIn.signOut();

      // 2. Démarrer le processus de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Sélection du compte Google annulée';
      }

      print('Tentative de connexion avec: ${googleUser.email}');

      // 3. Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Connexion directe avec Firebase (pas de liaison avec compte anonyme)
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 5. Vérifications strictes post-connexion
        if (user.isAnonymous) {
          print('ERREUR: Utilisateur anonyme détecté, nettoyage...');
          await user.delete();
          throw 'Erreur: Connexion anonyme détectée';
        }

        // Vérifier que c'est bien un compte Google
        final isGoogleProvider = user.providerData
            .any((element) => element.providerId == 'google.com');

        if (!isGoogleProvider) {
          print('ERREUR: Ce n\'est pas un compte Google');
          await _auth.signOut();
          throw 'Erreur: Ce n\'est pas un compte Google';
        }

        print('Connexion Google réussie:');
        print('Email: ${user.email}');
        print('Nom: ${user.displayName}');
        print('Provider ID: google.com');
        print('UID: ${user.uid}');

        return userCredential;
      } else {
        throw 'Erreur: Aucun utilisateur retourné';
      }

    } on FirebaseAuthException catch (e) {
      print('Erreur FirebaseAuth: ${e.code} - ${e.message}');
      // Nettoyage en cas d'erreur
      await _googleSignIn.signOut();
      await _auth.signOut();
      rethrow;
    } catch (e) {
      print('Erreur générale: $e');
      // Nettoyage en cas d'erreur
      await _googleSignIn.signOut();
      await _auth.signOut();
      rethrow;
    }
  }

  // Méthode de connexion anonyme
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      print('Connexion anonyme réussie');
      print('UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('Erreur lors de la connexion anonyme: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Vérifier le statut de connexion actuel
  Future<void> checkCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      print('Utilisateur actuel:');
      print('UID: ${user.uid}');
      print('Email: ${user.email}');
      print('Anonyme: ${user.isAnonymous}');
      print('Providers: ${user.providerData.map((e) => e.providerId).join(', ')}');
    } else {
      print('Aucun utilisateur connecté');
    }
  }

  // Ajouter cette méthode dans la classe AuthService
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Email de réinitialisation envoyé à: $email');
    } on FirebaseAuthException catch (e) {
      print('Erreur lors de la réinitialisation du mot de passe: ${e.code}');
      if (e.code == 'user-not-found') {
        throw 'Aucun utilisateur trouvé avec cet email';
      } else if (e.code == 'invalid-email') {
        throw 'Email invalide';
      }
      throw 'Une erreur est survenue';
    }
  }
}*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Vérifier l'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw 'Aucun utilisateur trouvé avec cet email';
        case 'wrong-password':
          throw 'Mot de passe incorrect';
        case 'invalid-email':
          throw 'Format d\'email invalide';
        case 'user-disabled':
          throw 'Ce compte a été désactivé';
        default:
          throw 'Une erreur s\'est produite lors de la connexion';
      }
    }
  }

  // Inscription avec email et mot de passe
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Erreur d\'inscription: ${e.code}');
      switch (e.code) {
        case 'email-already-in-use':
          throw 'Cet email est déjà utilisé';
        case 'invalid-email':
          throw 'Format d\'email invalide';
        case 'weak-password':
          throw 'Le mot de passe doit contenir au moins 6 caractères';
        case 'operation-not-allowed':
          throw 'L\'inscription par email/mot de passe n\'est pas activée';
        default:
          throw 'Une erreur s\'est produite lors de l\'inscription';
      }
    }
  }

  // Connexion avec Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Vérifier si un utilisateur est déjà connecté
      if (_auth.currentUser?.isAnonymous ?? false) {
        await _auth.currentUser?.delete();
      }

      // Déconnexion de Google si déjà connecté
      await _googleSignIn.signOut();

      // Déclencher le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Connexion Google annulée';
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer les credentials pour Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connexion à Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Vérifier que l'utilisateur est bien connecté avec Google
      if (userCredential.user?.providerData.any(
            (provider) => provider.providerId == 'google.com',
          ) !=
          true) {
        throw 'Erreur de connexion avec Google';
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Erreur FirebaseAuth: ${e.code}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw 'Ce compte existe déjà avec une autre méthode de connexion';
        case 'invalid-credential':
          throw 'Les informations de connexion sont invalides';
        case 'operation-not-allowed':
          throw 'La connexion Google n\'est pas activée';
        case 'user-disabled':
          throw 'Ce compte a été désactivé';
        default:
          throw 'Une erreur s\'est produite lors de la connexion Google';
      }
    } catch (e) {
      print('Erreur générale: $e');
      throw 'Une erreur s\'est produite lors de la connexion Google';
    }
  }

  // Connexion anonyme
  Future<UserCredential> signInAnonymously() async {
    try {
      if (_auth.currentUser != null) {
        throw 'Un utilisateur est déjà connecté';
      }
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion anonyme: ${e.code}');
      throw 'Impossible de se connecter en tant qu\'invité';
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('Email de réinitialisation envoyé à: $email');
    } on FirebaseAuthException catch (e) {
      print('Erreur de réinitialisation: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw 'Aucun compte trouvé avec cet email';
        case 'invalid-email':
          throw 'Format d\'email invalide';
        case 'too-many-requests':
          throw 'Trop de tentatives, veuillez réessayer plus tard';
        default:
          throw 'Une erreur s\'est produite lors de l\'envoi de l\'email';
      }
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Erreur de déconnexion: $e');
      throw 'Une erreur s\'est produite lors de la déconnexion';
    }
  }

  // Vérifier l'état actuel de l'utilisateur
  void checkCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      print('Utilisateur actuel:');
      print('UID: ${user.uid}');
      print('Email: ${user.email}');
      print('Anonyme: ${user.isAnonymous}');
      print(
        'Providers: ${user.providerData.map((provider) => provider.providerId).join(', ')}',
      );
    } else {
      print('Aucun utilisateur connecté');
    }
  }
}
