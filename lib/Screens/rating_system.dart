
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart'; // Ajustez selon votre structure de projet

class RatingSystem extends StatefulWidget {
  final String placeId;

  const RatingSystem({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  State<RatingSystem> createState() => _RatingSystemState();
}

class _RatingSystemState extends State<RatingSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _userRating = 0; // La note de l'utilisateur actuel (0 signifie pas encore noté)
  bool _isSubmitting = false;
  bool _hasUserRated = false; // L'utilisateur a-t-il déjà noté ce lieu?
  String? _userRatingId; // ID du document de notation de l'utilisateur (pour la mise à jour)
  String _placeName = "ce lieu"; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _checkUserRating();
    _fetchPlaceName(); // Récupérer le nom du lieu
  }

  // Nouvelle méthode pour récupérer le nom du lieu
  Future<void> _fetchPlaceName() async {
    try {
      final doc = await _firestore.collection('places').doc(widget.placeId).get();
      if (doc.exists) {
        // Utilise le champ 'nom' pour récupérer le nom du lieu
        final nom = doc.data()?['nom'] as String?;
        if (nom != null) {
          setState(() {
            _placeName = nom;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom du lieu: $e');
    }
  }

  // Vérifier si l'utilisateur a déjà noté ce lieu
  Future<void> _checkUserRating() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return;
    }

    try {
      final query = await _firestore
          .collection('ratings')
          .where('placeId', isEqualTo: widget.placeId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        setState(() {
          _userRating = (data['rating'] as num).toDouble();
          _hasUserRated = true;
          _userRatingId = query.docs.first.id;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la notation de l\'utilisateur: $e');
    }
  }

  // Soumettre ou mettre à jour la notation
  Future<void> _submitRating(double rating) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      _navigateToLogin();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_hasUserRated && _userRatingId != null) {
        // Mettre à jour la note existante
        await _firestore.collection('ratings').doc(_userRatingId).update({
          'rating': rating,
          'timestamp': Timestamp.now(),
        });
      } else {
        // Créer une nouvelle note
        final docRef = await _firestore.collection('ratings').add({
          'placeId': widget.placeId,
          'userId': user.uid,
          'userEmail': user.email,
          'rating': rating,
          'timestamp': Timestamp.now(),
        });
        setState(() {
          _userRatingId = docRef.id;
        });
      }

      setState(() {
        _userRating = rating;
        _hasUserRated = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merci d\'avoir noté $_placeName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final bool isLoggedIn = user != null && !user.isAnonymous;

    return Column(
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Évaluation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Section de notation moyenne
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('ratings')
              .where('placeId', isEqualTo: widget.placeId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Calculer la note moyenne
            double averageRating = 0;
            int totalRatings = 0;

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              double sum = 0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                sum += (data['rating'] as num).toDouble();
              }
              totalRatings = snapshot.data!.docs.length;
              averageRating = sum / totalRatings;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  // Note moyenne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        totalRatings > 0
                            ? '${averageRating.toStringAsFixed(1)} / 5'
                            : 'Pas encore d\'évaluation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: totalRatings > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Nombre d'évaluations
                  Text(
                    totalRatings > 0
                        ? '$totalRatings évaluation${totalRatings > 1 ? "s" : ""}'
                        : 'Soyez le premier à noter ce lieu!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const Divider(),

        // Section de notation de l'utilisateur
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(
                isLoggedIn
                    ? _hasUserRated
                    ? 'Votre évaluation'
                    : 'Évaluez ce lieu'
                    : 'Connectez-vous pour noter ce lieu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLoggedIn ? Colors.black : Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              // Système d'étoiles interactif
              if (isLoggedIn)
                _buildRatingStars()
              else
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Se connecter pour évaluer'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Construire les étoiles interactives
  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: _isSubmitting ? null : () => _submitRating(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              starValue <= _userRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}*/




/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';

class RatingSystem extends StatefulWidget {
  final String placeId;

  const RatingSystem({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  State<RatingSystem> createState() => _RatingSystemState();
}

class _RatingSystemState extends State<RatingSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _userRating = 0; // La note de l'utilisateur actuel (0 signifie pas encore noté)
  bool _isSubmitting = false;
  bool _hasUserRated = false; // L'utilisateur a-t-il déjà noté ce lieu?
  String? _userRatingId; // ID du document de notation de l'utilisateur (pour la mise à jour)
  String _placeName = "ce lieu"; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _checkUserRating();
    _fetchPlaceName(); // Récupérer le nom du lieu
  }

  // Nouvelle méthode pour récupérer le nom du lieu
  Future<void> _fetchPlaceName() async {
    try {
      final doc = await _firestore.collection('places').doc(widget.placeId).get();
      if (doc.exists) {
        // Utilise le champ 'nom' pour récupérer le nom du lieu
        final nom = doc.data()?['nom'] as String?;
        if (nom != null) {
          setState(() {
            _placeName = nom;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom du lieu: $e');
    }
  }

  // Vérifier si l'utilisateur a déjà noté ce lieu
  Future<void> _checkUserRating() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return;
    }

    try {
      final query = await _firestore
          .collection('ratings')
          .where('placeId', isEqualTo: widget.placeId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        setState(() {
          _userRating = (data['rating'] as num).toDouble();
          _hasUserRated = true;
          _userRatingId = query.docs.first.id;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la notation de l\'utilisateur: $e');
    }
  }

  // Soumettre ou mettre à jour la notation
  Future<void> _submitRating(double rating) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      _navigateToLogin();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Submit or update rating
      if (_hasUserRated && _userRatingId != null) {
        await _firestore.collection('ratings').doc(_userRatingId).update({
          'rating': rating,
          'timestamp': Timestamp.now(),
        });
      } else {
        final docRef = await _firestore.collection('ratings').add({
          'placeId': widget.placeId,
          'userId': user.uid,
          'userEmail': user.email,
          'rating': rating,
          'timestamp': Timestamp.now(),
        });
        setState(() {
          _userRatingId = docRef.id;
        });
      }

      setState(() {
        _userRating = rating;
        _hasUserRated = true;
      });

      //  Recalculate the average rating
      final querySnapshot = await _firestore
          .collection('ratings')
          .where('placeId', isEqualTo: widget.placeId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        double total = 0;
        for (var doc in querySnapshot.docs) {
          total += (doc['rating'] as num).toDouble();
        }
        double average = total / querySnapshot.docs.length;

        // Update average in 'places'
        await _firestore.collection('places').doc(widget.placeId).set({
          'rating': average,
        }, SetOptions(merge: true));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merci d\'avoir noté $_placeName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final bool isLoggedIn = user != null && !user.isAnonymous;

    return Column(
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Évaluation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Section de notation moyenne
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('ratings')
              .where('placeId', isEqualTo: widget.placeId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Calculer la note moyenne
            double averageRating = 0;
            int totalRatings = 0;

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              double sum = 0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                sum += (data['rating'] as num).toDouble();
              }
              totalRatings = snapshot.data!.docs.length;
              averageRating = sum / totalRatings;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  // Note moyenne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        totalRatings > 0
                            ? '${averageRating.toStringAsFixed(1)} / 5'
                            : 'Pas encore évaluer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: totalRatings > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Nombre d'évaluations
                  Text(
                    totalRatings > 0
                        ? '$totalRatings évaluation${totalRatings > 1 ? "s" : ""}'
                        : 'Soyez le premier à noter ce lieu!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const Divider(),

        // Section de notation de l'utilisateur
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(
                isLoggedIn
                    ? _hasUserRated
                    ? 'Votre évaluation'
                    : 'Évaluez ce lieu'
                    : 'Connectez-vous pour noter ce lieu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLoggedIn ? Colors.black : Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              // Système d'étoiles interactif
              if (isLoggedIn)
                _buildRatingStars()
              else
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Se connecter pour évaluer'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Construire les étoiles interactives
  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: _isSubmitting ? null : () => _submitRating(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              starValue <= _userRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}*/








import 'package:app_pfe/services/rating_system_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/rating.dart';
import 'welcome_screen.dart';

class RatingSystem extends StatefulWidget {
  final String placeId;

  const RatingSystem({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  State<RatingSystem> createState() => _RatingSystemState();
}

class _RatingSystemState extends State<RatingSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RatingSystemService _ratingSystemService = RatingSystemService();

  double _userRating = 0; // La note de l'utilisateur actuel (0 signifie pas encore noté)
  bool _isSubmitting = false;
  bool _hasUserRated = false; // L'utilisateur a-t-il déjà noté ce lieu?
  String? _userRatingId; // ID du document de notation de l'utilisateur (pour la mise à jour)
  String _placeName = "ce lieu"; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _checkUserRating();
    _fetchPlaceName(); // Récupérer le nom du lieu
  }

  // Nouvelle méthode pour récupérer le nom du lieu
  Future<void> _fetchPlaceName() async {
    try {
      final nom = await _ratingSystemService.fetchPlaceName(widget.placeId);
      if (nom != null) {
        setState(() {
          _placeName = nom;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom du lieu: $e');
    }
  }

  // Vérifier si l'utilisateur a déjà noté ce lieu
  Future<void> _checkUserRating() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return;
    }

    try {
      final userRate=await _ratingSystemService.fetchUserRating(widget.placeId, user.uid);

      if (userRate != null) {
        setState(() {
          _userRating = (userRate.rating as num).toDouble();
          _hasUserRated = true;
          _userRatingId = userRate.id;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la notation de l\'utilisateur: $e');
    }
  }

  // Soumettre ou mettre à jour la notation
  Future<void> _submitRating(double rating) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      _navigateToLogin();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Submit or update rating
      if (_hasUserRated && _userRatingId != null) {
        await _ratingSystemService.updateRating(_userRatingId!, rating);
      } else {
        final docRef = await _ratingSystemService.submitNewRating(widget.placeId, user.uid, user.email, rating);
        setState(() {
          _userRatingId = docRef?.id;
        });
      }

      setState(() {
        _userRating = rating;
        _hasUserRated = true;
      });

      //  Recalculate the average rating
      await _ratingSystemService.updateAverageRating(widget.placeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merci d\'avoir noté $_placeName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final bool isLoggedIn = user != null && !user.isAnonymous;

    return Column(
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Évaluation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Section de notation moyenne
        StreamBuilder<List<Rating>>(
          stream: _ratingSystemService.fetchRatings(widget.placeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Calculer la note moyenne
            double averageRating = 0;
            int totalRatings = 0;

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              double sum = 0;
              for (var doc in snapshot.data!) {
                sum += (doc.rating as num).toDouble();
              }
              totalRatings = snapshot.data!.length;
              averageRating = sum / totalRatings;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  // Note moyenne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        totalRatings > 0
                            ? '${averageRating.toStringAsFixed(1)} / 5'
                            : 'Pas encore évaluer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: totalRatings > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Nombre d'évaluations
                  Text(
                    totalRatings > 0
                        ? '$totalRatings évaluation${totalRatings > 1 ? "s" : ""}'
                        : 'Soyez le premier à noter ce lieu!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const Divider(),

        // Section de notation de l'utilisateur
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(
                isLoggedIn
                    ? _hasUserRated
                    ? 'Votre évaluation'
                    : 'Évaluez ce lieu'
                    : 'Connectez-vous pour noter ce lieu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLoggedIn ? Colors.black : Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              // Système d'étoiles interactif
              if (isLoggedIn)
                _buildRatingStars()
              else
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Se connecter pour évaluer'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Construire les étoiles interactives
  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: _isSubmitting ? null : () => _submitRating(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              starValue <= _userRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}