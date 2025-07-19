/*


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'place_details_screen.dart'; // Pour naviguer vers les détails du lieu

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({Key? key}) : super(key: key);

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mes avis'),
        backgroundColor: Color(0xFF0F6134),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Évaluations', icon: Icon(Icons.star)),
            Tab(text: 'Commentaires', icon: Icon(Icons.comment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRatingsTab(),
          _buildCommentsTab(),
        ],
      ),
    );
  }

  // Onglet des évaluations (notes)
  Widget _buildRatingsTab() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Vous devez être connecté pour voir vos évaluations'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ratings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final ratings = snapshot.data?.docs ?? [];

        if (ratings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Vous n\'avez pas encore évalué de lieux',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Vos évaluations apparaîtront ici',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: ratings.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final ratingData = ratings[index].data() as Map<String, dynamic>;
            final String placeId = ratingData['placeId'] ?? '';
            final double rating = (ratingData['rating'] as num?)?.toDouble() ?? 0.0;
            final Timestamp timestamp = ratingData['timestamp'] as Timestamp;
            final DateTime date = timestamp.toDate();
            final String formattedDate =
                '${date.day}/${date.month}/${date.year}';

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('places').doc(placeId).get(),
              builder: (context, placeSnapshot) {
                if (!placeSnapshot.hasData || placeSnapshot.data == null) {
                  return const SizedBox.shrink();
                }

                final placeData = placeSnapshot.data!.data() as Map<String, dynamic>?;
                if (placeData == null) return const SizedBox.shrink();

                final String placeName = placeData['nom'] ?? 'Lieu inconnu';
                final List<dynamic> images = placeData['images'] ?? [];
                final String? imageUrl = images.isNotEmpty ? images[0] : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsScreen(
                            placeId: placeId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image du lieu
                        if (imageUrl != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nom du lieu
                              Text(
                                placeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Note et date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Étoiles
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),

                                  // Date
                                  Text(
                                    'Noté le $formattedDate',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Boutons d'action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Bouton modifier
                                  TextButton.icon(
                                    onPressed: () {
                                      _showRatingDialog(
                                        context,
                                        placeId,
                                        placeName,
                                        rating,
                                        ratings[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Modifier'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF0F6134),
                                    ),
                                  ),

                                  // Bouton supprimer
                                  TextButton.icon(
                                    onPressed: () {
                                      _showDeleteDialog(
                                        context,
                                        'évaluation',
                                        ratings[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Supprimer'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Onglet des commentaires
  Widget _buildCommentsTab() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Vous devez être connecté pour voir vos commentaires'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('comments')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final comments = snapshot.data?.docs ?? [];

        if (comments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Vous n\'avez pas encore commenté de lieux',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Vos commentaires apparaîtront ici',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: comments.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final commentData = comments[index].data() as Map<String, dynamic>;
            final String placeId = commentData['placeId'] ?? '';
            final String commentText = commentData['text'] ?? '';
            final Timestamp timestamp = commentData['timestamp'] as Timestamp;
            final DateTime date = timestamp.toDate();
            final String formattedDate =
                '${date.day}/${date.month}/${date.year}';
            final List<dynamic> likes = commentData['likes'] ?? [];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('places').doc(placeId).get(),
              builder: (context, placeSnapshot) {
                if (!placeSnapshot.hasData || placeSnapshot.data == null) {
                  return const SizedBox.shrink();
                }

                final placeData = placeSnapshot.data!.data() as Map<String, dynamic>?;
                if (placeData == null) return const SizedBox.shrink();

                final String placeName = placeData['nom'] ?? 'Lieu inconnu';
                final List<dynamic> images = placeData['images'] ?? [];
                final String? imageUrl = images.isNotEmpty ? images[0] : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsScreen(
                            placeId: placeId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image du lieu
                        if (imageUrl != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nom du lieu
                              Text(
                                placeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Texte du commentaire
                              Text(
                                commentText,
                                style: const TextStyle(fontSize: 14),
                              ),

                              const SizedBox(height: 8),

                              // Likes et date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Nombre de likes
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${likes.length}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Date
                                  Text(
                                    'Publié le $formattedDate',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Boutons d'action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Bouton modifier
                                  TextButton.icon(
                                    onPressed: () {
                                      _showCommentDialog(
                                        context,
                                        placeId,
                                        placeName,
                                        commentText,
                                        comments[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Modifier'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF0F6134),
                                    ),
                                  ),

                                  // Bouton supprimer
                                  TextButton.icon(
                                    onPressed: () {
                                      _showDeleteDialog(
                                        context,
                                        'commentaire',
                                        comments[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Supprimer'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // NOUVELLE IMPLÉMENTATION: Dialogue pour modifier une évaluation avec un widget personnalisé
  void _showRatingDialog(
      BuildContext context,
      String placeId,
      String placeName,
      double currentRating,
      String ratingId,
      ) {
    double newRating = currentRating;

    // Créons un widget complètement personnalisé au lieu d'utiliser AlertDialog
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Assombrir l'arrière-plan
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Text(
                    'Modifier votre note pour $placeName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Sous-titre
                  const Text(
                    'Sélectionnez votre nouvelle note:',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 16),

                  // Système d'étoiles
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < newRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                newRating = index + 1.0;
                              });
                            },
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Sauvegarder
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F6134),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await _firestore.collection('ratings').doc(ratingId).update({
                                'rating': newRating,
                                'timestamp': Timestamp.now(),
                              });

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Évaluation mise à jour avec succès')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: const Text('Sauvegarder'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogue pour modifier un commentaire - version personnalisée
  void _showCommentDialog(
      BuildContext context,
      String placeId,
      String placeName,
      String currentComment,
      String commentId,
      ) {
    final TextEditingController commentController = TextEditingController(text: currentComment);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Text(
                    'Modifier votre commentaire pour $placeName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Champ de texte
                  TextField(
                    controller: commentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Écrivez votre commentaire ici...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Sauvegarder
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F6134),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            if (commentController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Le commentaire ne peut pas être vide')),
                              );
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await _firestore.collection('comments').doc(commentId).update({
                                'text': commentController.text.trim(),
                                'timestamp': Timestamp.now(),
                              });

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Commentaire mis à jour avec succès')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: const Text('Sauvegarder'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogue de confirmation pour supprimer un avis - version personnalisée
  void _showDeleteDialog(
      BuildContext context,
      String type,
      String documentId,
      ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Text(
                    'Supprimer cet $type ?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  Text(
                    'Êtes-vous sûr de vouloir supprimer cet $type ? Cette action est irréversible.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Supprimer
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final collection = type == 'évaluation' ? 'ratings' : 'comments';
                              await _firestore.collection(collection).doc(documentId).delete();

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$type supprimé avec succès')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: const Text('Supprimer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}*/





import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'place_details_screen.dart'; // Pour naviguer vers les détails du lieu

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({Key? key}) : super(key: key);

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mes avis'),
        backgroundColor: Color(0xFF0F6134),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Évaluations', icon: Icon(Icons.star)),
            Tab(text: 'Commentaires', icon: Icon(Icons.comment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRatingsTab(),
          _buildCommentsTab(),
        ],
      ),
    );
  }

  // Onglet des évaluations (notes)
  Widget _buildRatingsTab() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Vous devez être connecté pour voir vos évaluations'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ratings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final ratings = snapshot.data?.docs ?? [];

        if (ratings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Vous n\'avez pas encore évalué de lieux',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Vos évaluations apparaîtront ici',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: ratings.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final ratingData = ratings[index].data() as Map<String, dynamic>;
            final String placeId = ratingData['placeId'] ?? '';
            final double rating = (ratingData['rating'] as num?)?.toDouble() ?? 0.0;
            final Timestamp timestamp = ratingData['timestamp'] as Timestamp;
            final DateTime date = timestamp.toDate();
            final String formattedDate =
                '${date.day}/${date.month}/${date.year}';

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('places').doc(placeId).get(),
              builder: (context, placeSnapshot) {
                if (!placeSnapshot.hasData || placeSnapshot.data == null) {
                  return const SizedBox.shrink();
                }

                final placeData = placeSnapshot.data!.data() as Map<String, dynamic>?;
                if (placeData == null) return const SizedBox.shrink();

                final String placeName = placeData['nom'] ?? 'Lieu inconnu';
                final List<dynamic> images = placeData['images'] ?? [];
                final String? imageUrl = images.isNotEmpty ? images[0] : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsScreen(
                            placeId: placeId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image du lieu
                        if (imageUrl != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nom du lieu
                              Text(
                                placeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Note et date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Étoiles
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),

                                  // Date
                                  Text(
                                    'Noté le $formattedDate',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Boutons d'action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Bouton modifier
                                  TextButton.icon(
                                    onPressed: () {
                                      _showRatingDialog(
                                        context,
                                        placeId,
                                        placeName,
                                        rating,
                                        ratings[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Modifier'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF0F6134),
                                    ),
                                  ),

                                  // Bouton supprimer
                                  TextButton.icon(
                                    onPressed: () {
                                      _showDeleteDialog(
                                        context,
                                        'évaluation',
                                        ratings[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Supprimer'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Onglet des commentaires
  Widget _buildCommentsTab() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Vous devez être connecté pour voir vos commentaires'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('comments')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final comments = snapshot.data?.docs ?? [];

        if (comments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Vous n\'avez pas encore commenté de lieux',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Vos commentaires apparaîtront ici',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: comments.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final commentData = comments[index].data() as Map<String, dynamic>;
            final String placeId = commentData['placeId'] ?? '';
            final String commentText = commentData['text'] ?? '';
            final Timestamp timestamp = commentData['timestamp'] as Timestamp;
            final DateTime date = timestamp.toDate();
            final String formattedDate =
                '${date.day}/${date.month}/${date.year}';
            final List<dynamic> likes = commentData['likes'] ?? [];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('places').doc(placeId).get(),
              builder: (context, placeSnapshot) {
                if (!placeSnapshot.hasData || placeSnapshot.data == null) {
                  return const SizedBox.shrink();
                }

                final placeData = placeSnapshot.data!.data() as Map<String, dynamic>?;
                if (placeData == null) return const SizedBox.shrink();

                final String placeName = placeData['nom'] ?? 'Lieu inconnu';
                final List<dynamic> images = placeData['images'] ?? [];
                final String? imageUrl = images.isNotEmpty ? images[0] : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsScreen(
                            placeId: placeId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image du lieu
                        if (imageUrl != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nom du lieu
                              Text(
                                placeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Texte du commentaire
                              Text(
                                commentText,
                                style: const TextStyle(fontSize: 14),
                              ),

                              const SizedBox(height: 8),

                              // Likes et date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Nombre de likes
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${likes.length}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Date
                                  Text(
                                    'Publié le $formattedDate',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Boutons d'action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Bouton modifier
                                  TextButton.icon(
                                    onPressed: () {
                                      _showCommentDialog(
                                        context,
                                        placeId,
                                        placeName,
                                        commentText,
                                        comments[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Modifier'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF0F6134),
                                    ),
                                  ),

                                  // Bouton supprimer
                                  TextButton.icon(
                                    onPressed: () {
                                      _showDeleteDialog(
                                        context,
                                        'commentaire',
                                        comments[index].id,
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Supprimer'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // NOUVELLE IMPLÉMENTATION: Dialogue pour modifier une évaluation avec un widget personnalisé
  void _showRatingDialog(
      BuildContext context,
      String placeId,
      String placeName,
      double currentRating,
      String ratingId,
      ) {
    double newRating = currentRating;

    // Créons un widget complètement personnalisé au lieu d'utiliser AlertDialog
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Assombrir l'arrière-plan
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Text(
                    'Modifier votre note pour $placeName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Sous-titre
                  const Text(
                    'Sélectionnez votre nouvelle note:',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 16),

                  // Système d'étoiles
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < newRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                newRating = index + 1.0;
                              });
                            },
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Sauvegarder
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F6134),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await _firestore.collection('ratings').doc(ratingId).update({
                                'rating': newRating,
                                'timestamp': Timestamp.now(),
                              });

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Évaluation mise à jour avec succès')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: const Text('Sauvegarder'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogue pour modifier un commentaire - version personnalisée
  void _showCommentDialog(
      BuildContext context,
      String placeId,
      String placeName,
      String currentComment,
      String commentId,
      ) {
    final TextEditingController commentController = TextEditingController(text: currentComment);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Text(
                    'Modifier votre commentaire pour $placeName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Champ de texte
                  TextField(
                    controller: commentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Écrivez votre commentaire ici...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Sauvegarder
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F6134),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            if (commentController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Le commentaire ne peut pas être vide')),
                              );
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await _firestore.collection('comments').doc(commentId).update({
                                'text': commentController.text.trim(),
                                'timestamp': Timestamp.now(),
                              });

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Commentaire mis à jour avec succès')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: const Text('Sauvegarder'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogue de confirmation pour supprimer un avis - version personnalisée
  void _showDeleteDialog(
      BuildContext context,
      String type,
      String documentId,
      ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Text(
                    'Supprimer cet $type ?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  Text(
                    'Êtes-vous sûr de vouloir supprimer cet $type ? Cette action est irréversible.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Supprimer
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final collection = type == 'évaluation' ? 'ratings' : 'comments';
                              await _firestore.collection(collection).doc(documentId).delete();

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$type supprimé avec succès')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: const Text('Supprimer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}