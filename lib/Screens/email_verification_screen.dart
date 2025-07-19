/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';



class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

  @override
  void initState() {
    user = auth.currentUser;
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user?.reload();
    if (user!.emailVerified) {
      timer?.cancel();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vérification Email'),
        backgroundColor: Color(0xFF0F6134),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread,
              size: 100,
              color: Color(0xFF0F6134),
            ),
            SizedBox(height: 20),
            Text(
              'Un email de vérification a été envoyé à:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6134),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Veuillez vérifier votre email pour continuer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await user?.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nouvel email de vérification envoyé'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Renvoyer l\'email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F6134),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool canResendEmail = true;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    if (user != null && !user!.emailVerified) {
      sendVerificationEmail();
      startEmailVerificationTimer();
    }
  }

  void startEmailVerificationTimer() {
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await checkEmailVerified();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(minutes: 1));
      if (mounted) setState(() => canResendEmail = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de vérification envoyé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> checkEmailVerified() async {
    try {
      user = auth.currentUser;
      await user?.reload();

      if (user?.emailVerified ?? false) {
        timer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email vérifié avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print('Erreur de vérification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(

      onWillPop: () async {
        // Empêcher le retour arrière accidentel
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vérification Email'),
          backgroundColor: const Color(0xFF0F6134),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  size: 100,
                  color: Color(0xFF0F6134),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Un email de vérification a été envoyé à:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F6134),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Veuillez vérifier votre email pour continuer',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6134),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    canResendEmail
                        ? 'Renvoyer l\'email'
                        : 'Attendre 1 minute...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    await auth.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text(
                    'Retour à la connexion',
                    style: TextStyle(color: Color(0xFF0F6134)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}