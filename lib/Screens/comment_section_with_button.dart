/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart'; // Ajustez selon votre structure de projet

class CommentSectionWithButton extends StatefulWidget {
  final String placeId;

  const CommentSectionWithButton({Key? key, required this.placeId}) : super(key: key);

  @override
  State<CommentSectionWithButton> createState() => _CommentSectionWithButtonState();
}

class _CommentSectionWithButtonState extends State<CommentSectionWithButton> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSubmitting = false;
  bool _showComments = false; // Ceci doit être false initialement

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
      print("État des commentaires: ${_showComments ? 'visible' : 'caché'}");
    });
  }

  Future<void> _toggleLike(String commentId, List<String> currentLikes) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      _navigateToLogin();
      return;
    }

    try {
      final String userId = user.uid;
      final bool isLiked = currentLikes.contains(userId);

      if (isLiked) {
        // Retirer le like
        await _firestore.collection('comments').doc(commentId).update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        // Ajouter le like
        await _firestore.collection('comments').doc(commentId).update({
          'likes': FieldValue.arrayUnion([userId])
        });
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
    }
  }

  Future<void> _addComment() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      _navigateToLogin();
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un commentaire'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firestore.collection('comments').add({
        'placeId': widget.placeId,
        'text': _commentController.text.trim(),
        'timestamp': Timestamp.now(),
        'userId': user.uid,
        'userIdentifier': user.email,
        'userName': user.displayName ?? user.email?.split('@')[0] ?? 'Utilisateur',
        'userPhotoURL': user.photoURL,
        'likes': [], // Initialiser le tableau des likes
      });

      _commentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commentaire ajouté avec succès'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),

        // Bouton pour voir les commentaires (toujours visible)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_showComments ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  const SizedBox(width: 8),
                  Text(_showComments ? "Masquer les commentaires" : "Voir les commentaires"),
                ],
              ),
            ),
          ),
        ),

        // Tout le reste ne s'affiche que si _showComments est true
        if (_showComments) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: Text(
              'Commentaires',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ) ?? const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Liste des commentaires existants
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('comments')
                .where('placeId', isEqualTo: widget.placeId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Erreur de chargement: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Aucun commentaire pour le moment. Soyez le premier à commenter!',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                );
              }

              // Afficher les commentaires
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final commentData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final Timestamp timestamp = commentData['timestamp'] as Timestamp;
                  final DateTime date = timestamp.toDate();
                  final String formattedDate =
                      '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                  final String text = commentData['text'] ?? '';
                  final String userName = commentData['userName'] ?? commentData['userIdentifier'] ?? 'Utilisateur';
                  final String? userPhotoURL = commentData['userPhotoURL'];
                  final String userId = commentData['userId'] ?? '';
                  final List<String> likes = (commentData['likes'] as List<dynamic>?)?.cast<String>() ?? [];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    color: Colors.grey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Nom de l'utilisateur
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Bouton supprimer si l'utilisateur est l'auteur
                            if (user != null && userId == user.uid)
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    await _firestore
                                        .collection('comments')
                                        .doc(snapshot.data!.docs[index].id)
                                        .delete();

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Commentaire supprimé'),
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
                                  }
                                },
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),



                          ],
                        ),

                        // Date
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Texte du commentaire
                        Text(text),

                        const SizedBox(height: 8),

                        // Section des likes
                        Row(
                          children: [
                            GestureDetector(
                              onTap: isLoggedIn
                                  ? () => _toggleLike(snapshot.data!.docs[index].id, likes)
                                  : _navigateToLogin,
                              child: Icon(
                                likes.contains(user?.uid ?? '') ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              likes.length.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // Zone de saisie ou message pour se connecter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoggedIn
                ? Column(
              children: [
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Publier'),
                  ),
                ),
              ],
            )
                : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline, color: Colors.black87),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Connectez-vous pour ajouter vos commentaires sur ce lieu.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Veuillez vous connecter pour commenter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}*/



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';
import '../services/comment_section.dart';

class CommentSectionWithButton extends StatefulWidget {
  final String placeId;

  const CommentSectionWithButton({Key? key, required this.placeId}) : super(key: key);

  @override
  State<CommentSectionWithButton> createState() => _CommentSectionWithButtonState();
}

class _CommentSectionWithButtonState extends State<CommentSectionWithButton> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  bool _isSubmitting = false;
  bool _showComments = false;
  List<QueryDocumentSnapshot>? _comments;
  bool _isLoadingComments = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Pas de chargement initial, on attend que l'utilisateur clique sur "Voir les commentaires"
  }

  Future<void> _loadComments() async {
    if (!_showComments) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final comments = await _commentService.loadCommentsForPlace(widget.placeId);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      print("Erreur de chargement des commentaires: $e");
      setState(() {
        _isLoadingComments = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement des commentaires: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });

    if (_showComments) {
      _loadComments();
    }
  }

  Future<void> _toggleLike(String commentId, List<String> currentLikes) async {
    try {
      await _commentService.toggleLike(commentId, currentLikes);
      await _loadComments(); // Recharger les commentaires après le like
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (e.toString().contains('non connecté')) {
        _navigateToLogin();
      }
    }
  }

  Future<void> _addComment() async {
    if (!_commentService.canUserComment()) {
      _navigateToLogin();
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un commentaire'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _commentService.addComment(widget.placeId, _commentController.text);
      _commentController.clear();

      // Recharger les commentaires après l'ajout
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commentaire ajouté avec succès'),
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

  Future<void> _deleteComment(String commentId) async {
    // Afficher un dialogue de confirmation
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le commentaire'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce commentaire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldDelete) return;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Suppression en cours..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      final success = await _commentService.deleteComment(commentId);

      // Fermer le dialogue de chargement
      Navigator.of(context).pop();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commentaire supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Recharger les commentaires après suppression
        await _loadComments();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la suppression du commentaire'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    final user = _commentService.getCurrentUser();
    final bool isLoggedIn = user != null && !user.isAnonymous;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),

        // Bouton pour voir les commentaires (toujours visible)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_showComments ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  const SizedBox(width: 8),
                  Text(_showComments ? "Masquer les commentaires" : "Voir les commentaires"),
                ],
              ),
            ),
          ),
        ),

        // Tout le reste ne s'affiche que si _showComments est true
        if (_showComments) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: Text(
              'Commentaires',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ) ?? const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),



          // Liste des commentaires existants
          if (_isLoadingComments)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_comments == null || _comments!.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Aucun commentaire pour le moment. Soyez le premier à commenter!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments!.length,
              itemBuilder: (context, index) {
                final commentData =
                _comments![index].data() as Map<String, dynamic>;
                final Timestamp timestamp = commentData['timestamp'] as Timestamp;
                final DateTime date = timestamp.toDate();
                final String formattedDate =
                    '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                final String text = commentData['text'] ?? '';
                final String userName = commentData['userName'] ?? commentData['userIdentifier'] ?? 'Utilisateur';
                final String? userPhotoURL = commentData['userPhotoURL'];
                final String userId = commentData['userId'] ?? '';
                final List<String> likes = (commentData['likes'] as List<dynamic>?)?.cast<String>() ?? [];



                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  padding: const EdgeInsets.all(12.0),
                  color: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nom de l'utilisateur avec photo de profil
                          Row(
                            children: [
                              if (userPhotoURL != null)
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(userPhotoURL),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Bouton supprimer si l'utilisateur est l'auteur
                          if (user != null && userId == user.uid)
                            GestureDetector(
                              onTap: () => _deleteComment(_comments![index].id),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                        ],
                      ),

                      // Date
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Texte du commentaire
                      Text(text),

                      const SizedBox(height: 8),

                      // Section des likes
                      Row(
                        children: [
                          GestureDetector(
                            onTap: isLoggedIn
                                ? () => _toggleLike(_comments![index].id, likes)
                                : _navigateToLogin,
                            child: Icon(
                              likes.contains(user?.uid ?? '') ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likes.length.toString(),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          // Section de saisie de commentaire
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: isLoggedIn
                        ? 'Partagez votre avis...'
                        : 'Connectez-vous pour commenter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    enabled: isLoggedIn,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoggedIn && !_isSubmitting ? _addComment : isLoggedIn ? null : _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(isLoggedIn ? 'Publier' : 'Se connecter pour commenter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}