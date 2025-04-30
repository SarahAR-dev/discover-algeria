/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;
  final Map<String, dynamic> placeData;

  const PlaceDetailsScreen({
    Key? key,
    required this.placeId,
    required this.placeData,
  }) : super(key: key);

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    if (user == null || user!.isAnonymous) return;

    final doc = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user!.uid)
        .where('placeId', isEqualTo: widget.placeId)
        .get();

    if (mounted) {
      setState(() {
        _isFavorite = doc.docs.isNotEmpty;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (user == null || user!.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour ajouter des favoris'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      // Ajouter aux favoris
      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': user!.uid,
        'placeId': widget.placeId,
        'name': widget.placeData['name'],
        'location': widget.placeData['location'],
        'images': widget.placeData['images'],
        'addedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajouté aux favoris'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Retirer des favoris
      final doc = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user!.uid)
          .where('placeId', isEqualTo: widget.placeId)
          .get();

      for (var document in doc.docs) {
        await document.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retiré des favoris'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openMaps() async {
    final lat = widget.placeData['latitude'];
    final lng = widget.placeData['longitude'];
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image et barre d'app
          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et localisation
                  Text(
                    widget.placeData['name'] ?? 'Sans nom',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.placeData['location'] ?? 'Emplacement inconnu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'À propos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.placeData['description'] ?? 'Aucune description disponible.',
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Horaires
                  if (widget.placeData['hours'] != null) ...[
                    const Text(
                      'Horaires',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.placeData['hours'],
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bouton Google Maps
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.map),
                      label: const Text('Voir sur Google Maps'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF0F6134),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;
  final Map<String, dynamic> placeData;

  const PlaceDetailsScreen({
    Key? key,
    required this.placeId,
    required this.placeData,
  }) : super(key: key);

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    if (user == null || user!.isAnonymous) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user!.uid)
            .where('placeId', isEqualTo: widget.placeId)
            .get();

    if (mounted) {
      setState(() {
        _isFavorite = doc.docs.isNotEmpty;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (user == null || user!.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour ajouter des favoris'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': user!.uid,
        'placeId': widget.placeId,
        'name': widget.placeData['name'],
        'location': widget.placeData['location'],
        'images': widget.placeData['images'],
        'addedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajouté aux favoris'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      final doc =
          await FirebaseFirestore.instance
              .collection('favorites')
              .where('userId', isEqualTo: user!.uid)
              .where('placeId', isEqualTo: widget.placeId)
              .get();

      for (var document in doc.docs) {
        await document.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retiré des favoris'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openMaps() async {
    final lat = widget.placeData['latitude'];
    final lng = widget.placeData['longitude'];
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: 'place_${widget.placeId}',
                child: Builder(
                  builder: (context) {
                    final List<dynamic> images =
                        widget.placeData['images'] ?? [];

                    if (images.isEmpty) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Aucune image disponible'),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 300,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 1.0,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                          autoPlayCurve: Curves.fastOutSlowIn,
                        ),
                        items:
                            images.map<Widget>((image) {
                              String imagePath = image.toString().replaceAll(
                                '"',
                                '',
                              );
                              if (!imagePath.startsWith('assets/')) {
                                imagePath = 'assets/images/$imagePath';
                              }

                              return Container(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $imagePath');
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Erreur de chargement',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.placeData['name'] ?? 'Sans nom',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.placeData['location'] ?? 'Emplacement inconnu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'À propos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.placeData['description'] ??
                        'Aucune description disponible.',
                    style: TextStyle(color: Colors.grey[800], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  if (widget.placeData['hours'] != null) ...[
                    const Text(
                      'Horaires',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.placeData['hours'],
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.map),
                      label: const Text('Voir sur Google Maps'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF0F6134),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
