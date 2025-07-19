/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Fonction de validation d'email
  bool isValidEmail(String email) {
    // Expression régulière pour la validation d'email
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Créer un nouveau compte
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Mettre à jour le profil de l'utilisateur avec le nom d'utilisateur
        await userCredential.user?.updateDisplayName(
          _usernameController.text.trim(),
        );

        // Si la création réussit, retourner à l'écran de connexion
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Compte créé avec succès! Vous pouvez maintenant vous connecter.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'Le mot de passe est trop faible.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Un compte existe déjà avec cet email.';
        } else {
          message = 'Une erreur est survenue: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  // Nouveau champ Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nom d'utilisateur",
                      hintText: "Entrez votre nom d'utilisateur",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d'utilisateur";
                      }
                      if (value.length < 3) {
                        return "Le nom d'utilisateur doit contenir au moins 3 caractères";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Entrez votre email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Entrez à nouveau votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child:
                    _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text('Créer un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
*/

/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Fonction de validation d'email
  bool isValidEmail(String email) {
    // Vérifie le format de base de l'email
    if (email.contains(' ')) return false; // Pas d'espaces
    if (email.split('@').length != 2) return false; // Un seul @

    // Expression régulière pour email
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]*@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$',
    );

    if (!emailRegExp.hasMatch(email)) return false;

    // Vérification supplémentaire du domaine
    final domain = email.split('@')[1];
    if (!domain.contains('.')) return false;

    final topLevelDomain = domain.split('.').last;
    if (topLevelDomain.length < 2) return false;

    return true;
  }

  // Fonction de validation du nom d'utilisateur
  bool isValidUsername(String username) {
    if (username.length < 3 || username.length > 20) return false;

    // Vérifie si commence ou termine par . ou _
    if (username.startsWith('.') ||
        username.startsWith('_') ||
        username.endsWith('.') ||
        username.endsWith('_')) {
      return false;
    }

    // Vérifie les caractères consécutifs spéciaux
    if (username.contains('..') ||
        username.contains('__') ||
        username.contains('._') ||
        username.contains('_.')) {
      return false;
    }

    // Expression régulière pour username
    // Autorise seulement les lettres, chiffres, underscores et points
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9._]+$');
    return usernameRegExp.hasMatch(username);
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Créer un nouveau compte
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Mettre à jour le profil de l'utilisateur avec le nom d'utilisateur
        await userCredential.user?.updateDisplayName(
          _usernameController.text.trim(),
        );

        // Si la création réussit, retourner à l'écran de connexion
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Compte créé avec succès! Vous pouvez maintenant vous connecter.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'Le mot de passe est trop faible.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Un compte existe déjà avec cet email.';
        } else {
          message = 'Une erreur est survenue: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  // Champ Username avec nouvelle validation
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nom d'utilisateur",
                      hintText: "Entrez votre nom d'utilisateur",
                      prefixIcon: Icon(Icons.person_outline),
                      helperText: "3-20 caractères: lettres, chiffres, . et _",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d'utilisateur";
                      }
                      if (!isValidUsername(value)) {
                        return "Format invalide. Utilisez 3-20 caractères:\n"
                            "• Lettres, chiffres, . et _\n"
                            "• Ne pas commencer/finir par . ou _\n"
                            "• Pas de caractères spéciaux consécutifs";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Email avec nouvelle validation
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Entrez votre email',
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: "Format: exemple@domaine.com",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Email invalide. Vérifiez:\n'
                            '• Format exemple@domaine.com\n'
                            '• Pas d\'espaces\n'
                            '• Domaine valide (.com, .fr, etc.)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Entrez à nouveau votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child:
                    _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text('Créer un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}*/

/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Validation de l'email
  bool isValidEmail(String email) {
    if (email.contains(' ')) return false;
    if (email.split('@').length != 2) return false;

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]*@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$',
    );

    if (!emailRegExp.hasMatch(email)) return false;

    final domain = email.split('@')[1];
    if (!domain.contains('.')) return false;

    final topLevelDomain = domain.split('.').last;
    if (topLevelDomain.length < 2) return false;

    return true;
  }

  // Validation du nom d'utilisateur
  bool isValidUsername(String username) {
    if (username.length < 3 || username.length > 20) return false;

    if (username.startsWith('.') ||
        username.startsWith('_') ||
        username.endsWith('.') ||
        username.endsWith('_')) {
      return false;
    }

    if (username.contains('..') ||
        username.contains('__') ||
        username.contains('._') ||
        username.contains('_.')) {
      return false;
    }

    final usernameRegExp = RegExp(r'^[a-zA-Z0-9._]+$');
    return usernameRegExp.hasMatch(username);
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Créer un nouveau compte
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Mettre à jour le profil avec le nom d'utilisateur
        await userCredential.user?.updateDisplayName(
          _usernameController.text.trim(),
        );

        if (mounted) {
          // Redirection vers HomeScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compte créé avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'Le mot de passe est trop faible.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Un compte existe déjà avec cet email.';
        } else {
          message = 'Une erreur est survenue: ${e.message}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Une erreur est survenue: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  // Champ Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nom d'utilisateur",
                      hintText: "Entrez votre nom d'utilisateur",
                      prefixIcon: Icon(Icons.person_outline),
                      helperText: "3-20 caractères: lettres, chiffres, . et _",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d'utilisateur";
                      }
                      if (!isValidUsername(value)) {
                        return "Format invalide. Utilisez 3-20 caractères:\n"
                            "• Lettres, chiffres, . et _\n"
                            "• Ne pas commencer/finir par . ou _\n"
                            "• Pas de caractères spéciaux consécutifs";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Entrez votre email',
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: "Format: exemple@domaine.com",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Email invalide. Vérifiez:\n'
                            '• Format exemple@domaine.com\n'
                            '• Pas d\'espaces\n'
                            '• Domaine valide (.com, .fr, etc.)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Mot de passe
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Confirmation mot de passe
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Entrez à nouveau votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Bouton d'inscription
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child:
                    _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text('Créer un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

*/






















////////////////////////////////////////

/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Validation de l'email
  bool isValidEmail(String email) {
    if (email.contains(' ')) return false;
    if (email.split('@').length != 2) return false;

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]*@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$',
    );

    if (!emailRegExp.hasMatch(email)) return false;

    final domain = email.split('@')[1];
    if (!domain.contains('.')) return false;

    final topLevelDomain = domain.split('.').last;
    if (topLevelDomain.length < 2) return false;

    return true;
  }

  // Validation du nom d'utilisateur
  bool isValidUsername(String username) {
    if (username.length < 3 || username.length > 20) return false;

    if (username.startsWith('.') ||
        username.startsWith('_') ||
        username.endsWith('.') ||
        username.endsWith('_')) {
      return false;
    }

    if (username.contains('..') ||
        username.contains('__') ||
        username.contains('._') ||
        username.contains('_.')) {
      return false;
    }

    final usernameRegExp = RegExp(r'^[a-zA-Z0-9._]+$');
    return usernameRegExp.hasMatch(username);
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Créer un nouveau compte
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Mettre à jour le profil avec le nom d'utilisateur
        await userCredential.user?.updateDisplayName(
          _usernameController.text.trim(),
        );

        // Envoyer l'email de vérification
        await userCredential.user?.sendEmailVerification();

        if (mounted) {
          // Afficher le message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Un email de vérification a été envoyé. Veuillez vérifier votre boîte de réception.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );

          // Rediriger vers la page de vérification d'email
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'Le mot de passe est trop faible.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Un compte existe déjà avec cet email.';
        } else {
          message = 'Une erreur est survenue: ${e.message}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Une erreur est survenue: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  ////////////////////////////////////////////////






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: /*const Color(0xFF0F6134)*/ Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: const Color(0xFF0F6134),
                  ),
                  const SizedBox(height: 32),
                  // Champ Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nom d'utilisateur",
                      hintText: "Entrez votre nom d'utilisateur",
                      prefixIcon: Icon(Icons.person_outline),
                      helperText: "3-20 caractères: lettres, chiffres, . et _",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d'utilisateur";
                      }
                      if (!isValidUsername(value)) {
                        return "Format invalide. Utilisez 3-20 caractères:\n"
                            "• Lettres, chiffres, . et _\n"
                            "• Ne pas commencer/finir par . ou _\n"
                            "• Pas de caractères spéciaux consécutifs";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Entrez votre email',
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: "Format: exemple@domaine.com",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Email invalide. Vérifiez:\n'
                            '• Format exemple@domaine.com\n'
                            '• Pas d\'espaces\n'
                            '• Domaine valide (.com, .fr, etc.)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Mot de passe
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Confirmation mot de passe
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Entrez à nouveau votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Bouton d'inscription
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F6134),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Créer un compte',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}*/







//////////////////////////////////












/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Fonction de validation d'email
  bool isValidEmail(String email) {
    // Vérifie le format de base de l'email
    if (email.contains(' ')) return false; // Pas d'espaces
    if (email.split('@').length != 2) return false; // Un seul @

    // Expression régulière pour email
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]*@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$',
    );

    if (!emailRegExp.hasMatch(email)) return false;

    // Vérification supplémentaire du domaine
    final domain = email.split('@')[1];
    if (!domain.contains('.')) return false;

    final topLevelDomain = domain.split('.').last;
    if (topLevelDomain.length < 2) return false;

    return true;
  }

  // Fonction de validation du nom d'utilisateur
  bool isValidUsername(String username) {
    if (username.length < 3 || username.length > 20) return false;

    // Vérifie si commence ou termine par . ou _
    if (username.startsWith('.') ||
        username.startsWith('_') ||
        username.endsWith('.') ||
        username.endsWith('_')) {
      return false;
    }

    // Vérifie les caractères consécutifs spéciaux
    if (username.contains('..') ||
        username.contains('__') ||
        username.contains('._') ||
        username.contains('_.')) {
      return false;
    }

    // Expression régulière pour username
    // Autorise seulement les lettres, chiffres, underscores et points
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9._]+$');
    return usernameRegExp.hasMatch(username);
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Utiliser le service d'authentification mis à jour
        await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );

        // Si la création réussit, retourner à l'écran de connexion
        if (mounted) {
          //Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Compte créé avec succès! Vous pouvez maintenant vous connecter.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        String message;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'weak-password':
              message = 'Le mot de passe est trop faible.';
              break;
            case 'email-already-in-use':
              message = 'Un compte existe déjà avec cet email.';
              break;
            default:
              message = 'Une erreur est survenue: ${e.message}';
          }
        } else {
          message = 'Une erreur est survenue: $e';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  // Champ Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nom d'utilisateur",
                      hintText: "Entrez votre nom d'utilisateur",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d'utilisateur";
                      }
                      if (value.length < 3) {
                        return "Le nom d'utilisateur doit contenir au moins 3 caractères";
                      }
                      if (!isValidUsername(value)) {
                        return "Le nom d'utilisateur n'est pas valide";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Entrez votre email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Mot de passe
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Confirmation mot de passe
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Entrez à nouveau votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Bouton Créer un compte
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child:
                    _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text('Créer un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}*/




import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  // Ajout des paramètres pour les valeurs initiales
  final String? initialEmail;
  final String? initialPassword;

  const RegisterScreen({
    Key? key,
    this.initialEmail,
    this.initialPassword,
  }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  // Les contrôleurs seront initialisés plus tard
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les valeurs initiales
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController(text: widget.initialPassword ?? '');
    _confirmPasswordController = TextEditingController(text: widget.initialPassword ?? '');
  }

  // Fonction de validation d'email (reste inchangée)
  /*bool isValidEmail(String email) {
    // Votre code existant...
    return true;
  }

  // Fonction de validation du nom d'utilisateur (reste inchangée)
  bool isValidUsername(String username) {
    // Votre code existant...
    return true;
  }*/


  // Fonction de validation d'email
  bool isValidEmail(String email) {
    // Vérifie le format de base de l'email
    if (email.contains(' ')) return false; // Pas d'espaces
    if (email.split('@').length != 2) return false; // Un seul @

    // Expression régulière pour email
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]*@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$',
    );

    if (!emailRegExp.hasMatch(email)) return false;

    // Vérification supplémentaire du domaine
    final domain = email.split('@')[1];
    if (!domain.contains('.')) return false;

    final topLevelDomain = domain.split('.').last;
    if (topLevelDomain.length < 2) return false;

    return true;
  }

  // Fonction de validation du nom d'utilisateur
  bool isValidUsername(String username) {
    if (username.length < 3 || username.length > 20) return false;

    // Vérifie si commence ou termine par . ou _
    if (username.startsWith('.') ||
        username.startsWith('_') ||
        username.endsWith('.') ||
        username.endsWith('_')) {
      return false;
    }

    // Vérifie les caractères consécutifs spéciaux
    if (username.contains('..') ||
        username.contains('__') ||
        username.contains('._') ||
        username.contains('_.')) {
      return false;
    }

    // Expression régulière pour username
    // Autorise seulement les lettres, chiffres, underscores et points
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9._]+$');
    return usernameRegExp.hasMatch(username);
  }


  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Vérifier si l'utilisateur est anonyme
        final currentUser = FirebaseAuth.instance.currentUser;
        final isAnonymous = currentUser?.isAnonymous ?? false;

        if (isAnonymous) {
          // Tenter de lier le compte anonyme avec le nouveau compte
          try {
            // Créer des credentials
            final credential = EmailAuthProvider.credential(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

            // Lier l'utilisateur anonyme au compte email/password
            await currentUser!.linkWithCredential(credential);

            // Mise à jour du profil avec le nom d'utilisateur
            await currentUser.updateDisplayName(_usernameController.text.trim());

            // Envoyer l'email de vérification
            if (currentUser.emailVerified == false) {
              await currentUser.sendEmailVerification();
            }

            // Rediriger vers l'écran principal
            /*if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Compte créé avec succès! Vérifiez votre email pour confirmer.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }*/

            if (mounted) {
              // REDIRIGER VERS L'ÉCRAN DE VÉRIFICATION AU LIEU DE LOGIN
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmailVerificationScreen(),
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email de vérification envoyé!'),
                  backgroundColor: Colors.green,
                ),
              );
            }

          } on FirebaseAuthException catch (e) {
            if (e.code == 'email-already-in-use') {
              // L'email est déjà utilisé par un autre compte
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Cet email est déjà associé à un compte. Essayez de vous connecter.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              throw e; // Relancer pour la gestion d'erreur globale
            }
          }
        } else {
          // Inscription normale pour un utilisateur non anonyme
          await _authService.registerWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _usernameController.text.trim(),
          );

          // Si la création réussit, rediriger vers l'écran d'accueil
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Compte créé avec succès! Vérifiez votre email pour confirmer.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        String message;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'weak-password':
              message = 'Le mot de passe est trop faible.';
              break;
            case 'email-already-in-use':
              message = 'Un compte existe déjà avec cet email.';
              break;
            default:
              message = 'Une erreur est survenue: ${e.message}';
          }
        } else {
          message = 'Une erreur est survenue: $e';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  // Champ Username (reste inchangé)
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nom d'utilisateur",
                      hintText: "Entrez votre nom d'utilisateur",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d'utilisateur";
                      }
                      if (value.length < 3) {
                        return "Le nom d'utilisateur doit contenir au moins 3 caractères";
                      }
                      if (!isValidUsername(value)) {
                        return "Le nom d'utilisateur n'est pas valide";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Email (reste largement inchangé)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Entrez votre email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Mot de passe (reste largement inchangé)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Confirmation mot de passe (reste largement inchangé)
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Entrez à nouveau votre mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Bouton Créer un compte (reste inchangé)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child:
                    _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text('Créer un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}