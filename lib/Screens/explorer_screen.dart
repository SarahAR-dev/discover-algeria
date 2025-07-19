
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'place_details_screen.dart';
import 'search_screenn.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'comment_section_with_button.dart';
import 'rating_system.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb


class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({Key? key}) : super(key: key);


  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  bool _isSearchFocused = false;
  String _selectedFilter = 'Tous';
  // 1. Ajoutez une variable pour stocker la position de l'utilisateur
  Position? _userPosition;
  // 2. Ajoutez une fonction qui sera appelée dans initState pour obtenir la position
  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }
  // 3. Fonction pour obtenir la position actuelle
  Future<void> _getCurrentPosition() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions refusées
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions refusées de façon permanente
        return;
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      print('Erreur de localisation: $e');
    }
  }

  // 4. Fonction pour calculer les lieux à proximité
  List<DocumentSnapshot> _getNearbyPlaces(List<DocumentSnapshot> allPlaces, Position? userPosition) {
    if (userPosition == null) return [];
    // Distance maximale en kilomètres
    const maxDistance = 50.0;
    // Liste pour stocker les lieux avec leur distance
    final placesWithDistance = <Map<String, dynamic>>[];

    for (final doc in allPlaces) {
      final data = doc.data() as Map<String, dynamic>;
      // Vérifier si le lieu a des coordonnées
      if (data.containsKey('localisation')) {
        final GeoPoint location = data['localisation'];
        // Calculer la distance
        final distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          location.latitude,
          location.longitude,
        ) / 1000; // Convertir en kilomètres
        // Si le lieu est à moins de maxDistance km
        if (distance <= maxDistance) {
          placesWithDistance.add({
            'doc': doc,
            'distance': distance,
          });
        }
      }
    }
    // Trier par distance (du plus proche au plus éloigné)
    placesWithDistance.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double)
    );
    // Retourner seulement les documents (max 10)
    return placesWithDistance
        .take(10)
        .map((item) => item['doc'] as DocumentSnapshot)
        .toList();
  }



  // Utilise un getter pour éviter l’erreur d’accès prématuré
  List<Map<String, dynamic>> get _filters {
    final user = FirebaseAuth.instance.currentUser;
    return [
      {'name': 'Tous', 'icon': Icons.apps},
      if (user != null && !user.isAnonymous) {'name': 'Pour Vous', 'icon': Icons.push_pin},
      {'name': 'Populaire', 'icon': Icons.star},
      {'name': 'Historique', 'icon': Icons.history_edu},
      {'name': 'Nature', 'icon': Icons.landscape},
      {'name': 'Culture', 'icon': Icons.museum},
    ];
  }


  final List<String> carouselImages = [
    'assets/images/header_background.jpg',
    'assets/images/header_background_2.jpg',
    'assets/images/header_background_3.jpg',
    'assets/images/header_background_4.jpg',
    'assets/images/header_background_5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // En-tête avec image de fond
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Ajout de la barre de recherche dans le "title"
            title: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchFocused = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaceSearchPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Rechercher un lieu...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    /*const Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                      size: 20,
                    ),*/
                  ],
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  /*Image.asset(
                    'assets/images/header_background.jpg',
                    fit: BoxFit.cover,
                  ),*/
                  CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items:
                    carouselImages.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Image.asset(image, fit: BoxFit.cover),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  Container(color: Colors.black.withOpacity(0.4)),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Découvrez l\'Algérie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explorez les plus beaux sites touristiques',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              final isSelected =
                                  filter['name'] == _selectedFilter;

                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = filter['name'];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                      isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          filter['icon'],
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          filter['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des lieux
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('places').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(
                      child: Text('Erreur lors du chargement des lieux.')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Aucune donnée disponible.')),
                );
              }

              try {
                var places = snapshot.data!.docs;
                final user = FirebaseAuth.instance.currentUser;

                // ✅ 1. Charger les recommandations si user connecté et "Pour Vous" sélectionné
                Map<String, dynamic> recommendationData = {};
                if (_selectedFilter == 'Pour Vous' && user != null && !user.isAnonymous ){
                  // Charger de manière synchrone via FutureBuilder ou external call
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('recommendation')
                        .where('userId', isEqualTo: user.uid)
                        .get(),
                    builder: (context, recSnapshot) {
                      if (recSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (recSnapshot.hasError) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Text(
                              'Erreur lors du chargement des recommandations')),
                        );
                      }

                      if (recSnapshot.data == null ||
                          recSnapshot.data!.docs.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                  "Suggestions personnalisées à venir."),
                            ),
                          ),
                        );
                      }

                      recommendationData =
                      recSnapshot.data!.docs.first.data() as Map<String,
                          dynamic>;
                      // Poursuivre avec affichage après chargement
                      return _buildFilteredPlaceList(
                          places, _selectedFilter, recommendationData);
                    },
                  );
                }

                // ✅ 2. Pas de "Pour Vous", on affiche normalement
                return _buildFilteredPlaceList(
                    places, _selectedFilter, recommendationData);
              } catch (e) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Erreur interne : ${e.toString()}'),
                  ),
                );
              }
            },
          ),
        ],),

    );
  }
  Widget _buildFilteredPlaceList(List<QueryDocumentSnapshot> places, String filter, Map<String, dynamic> recommendationData) {
    final user = FirebaseAuth.instance.currentUser;

    final filteredPlaces = places.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final categories = data['categorie'] as List<dynamic>? ?? [];
      final placeWilaya = data['wilaya'] as String? ?? '';
      final placeNom = data['nomin'] ?? '';
      final Set<String> displayedPlaceIds = <String>{};

      switch (filter) {
        case 'Pour Vous':
          if (user == null || user.isAnonymous || recommendationData.isEmpty) return false;
          final userCateg = recommendationData['categ'] as List<dynamic>? ?? [];
          final userWilaya = recommendationData['wilaya'] as List<dynamic>? ?? [];
          final userPlaceN = recommendationData['nom'] as String? ?? '';
          final wilayaMatches = userWilaya.contains(placeWilaya);
          final categMatches = categories.any((c) => userCateg.contains(c));
          return wilayaMatches || categMatches;


        case 'Populaire':
          return (data['rating'] ?? 0.0) >= 3.5;

        case 'Historique':
          return categories.contains('historique');

        case 'Nature':
          return categories.contains('naturel');

        case 'Culture':
          return categories.contains('culturel');

        default:
          return true;
      }
    }).toList();

    if (filteredPlaces.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucun lieu trouvé',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (filter == 'Pour Vous') {
      // Grouper les lieux par wilaya
      final wilayaGroups = <String, List<QueryDocumentSnapshot>>{};
      for (var doc in filteredPlaces) {
        final data = doc.data() as Map<String, dynamic>;
        final wilaya = data['wilaya'] as String? ?? 'Autre';
        wilayaGroups.putIfAbsent(wilaya, () => []).add(doc);
      }

      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(() {
              final entries = wilayaGroups.entries.toList();
              entries.sort((a, b) => a.key.compareTo(b.key));
              return entries.map((entry) {
                final wilaya = entry.key;
                final places = entry.value;
                return buildPlaceSection(
                  wilaya.toUpperCase(),
                  'Découvrez des lieux à $wilaya.',
                  places,
                );
              }).toList();
            })(),
          ],
        ),
      );

    }

    // Cas par défaut : affichage Nord/Est/Sud/Ouest
    final nordPlaces = filteredPlaces.where((doc) => (doc.data() as Map<String, dynamic>)['tags']?.contains('nord') ?? false).toList();
    final estPlaces = filteredPlaces.where((doc) => (doc.data() as Map<String, dynamic>)['tags']?.contains('est') ?? false).toList();
    final sudPlaces = filteredPlaces.where((doc) => (doc.data() as Map<String, dynamic>)['tags']?.contains('sud') ?? false).toList();
    final ouestPlaces = filteredPlaces.where((doc) => (doc.data() as Map<String, dynamic>)['tags']?.contains('ouest') ?? false).toList();
    // Récupérer les lieux à proximité (pour tous les filtres)
    //final nearbyPlaces = _userPosition != null ? _getNearbyPlaces(filteredPlaces, _userPosition) : [];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_userPosition != null && _selectedFilter == 'Tous' )
            buildPlaceSection('AUTOUR DE VOUS !', '"Des merveilles à quelques pas de vous"', _getNearbyPlaces(places, _userPosition)),

          buildPlaceSection('NORD !', '"Plages, collines et villages : le Nord vous ouvre ses bras."', nordPlaces),
          buildPlaceSection('EST !', '"Explorez l’Est : là où les traditions rencontrent la nature."', estPlaces),
          buildPlaceSection('SUD !', '"Le Sud ne se visite pas, il se ressent."', sudPlaces),
          buildPlaceSection('OUEST !', '"Dans l’Ouest, on ne vit pas, on célèbre la vie."', ouestPlaces),
        ],
      ),
    );
  }





  Widget buildPlaceCard(DocumentSnapshot doc, {double? distance}) {
    final data = doc.data() as Map<String, dynamic>;
    final List images = (data['images'] ?? []);
    final imageUrl = images.isNotEmpty ? images.first.toString() : '';

    return SizedBox(
      width: 260,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(placeId: doc.id),
              ),
            );
          },
          child: Stack(  // Changé en Stack pour pouvoir positionner le badge de distance
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 40)),
                        ),
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['nom'] ?? 'Sans nom',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data['wilaya'] ?? 'Emplacement inconnu',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('${data['rating'] ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Badge de distance (affiché seulement si distance est fournie)
              if (distance != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    /*child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),*/

                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),  // Icône de localisation au lieu de directions
                        const SizedBox(width: 4),
                        Text(
                          'À proximité',  // Texte "À proximité" au lieu de la distance
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlaceSection(String title, String citas, List<DocumentSnapshot> sectionPlaces) {
    // Vérifier si c'est la section "AUTOUR DE VOUS"
    final bool isNearbySection = title == 'AUTOUR DE VOUS !';
    if (sectionPlaces.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                citas,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < (sectionPlaces.length / 6).ceil(); i++)
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sectionPlaces.length,
              itemBuilder: (context, index) {
                if (index < i * 6 || index >= (i + 1) * 6) return const SizedBox.shrink();

                // Si c'est la section "Autour de vous", calculer la distance
                if (isNearbySection && _userPosition != null) {
                  final data = sectionPlaces[index].data() as Map<String, dynamic>;
                  if (data.containsKey('localisation')) {
                    final GeoPoint location = data['localisation'];

                    // Calculer la distance
                    final distance = Geolocator.distanceBetween(
                      _userPosition!.latitude,
                      _userPosition!.longitude,
                      location.latitude,
                      location.longitude,
                    ) / 1000; // Convertir en kilomètres

                    return buildPlaceCard(sectionPlaces[index], distance: distance);
                  }
                }

                // Pour les autres sections ou si pas de localisation
                return buildPlaceCard(sectionPlaces[index]);
                },
            ),
          ),
      ],
    );
  }




}*/





/*
import '../services/recommendations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'place_details_screen.dart';
import 'search_screenn.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'comment_section_with_button.dart';
import 'rating_system.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import '../services/explorer_service.dart';
import '../services/places.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({Key? key}) : super(key: key);


  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  bool _isSearchFocused = false;
  String _selectedFilter = 'Tous';

  late final _explorerService=ExplorerService();
  //late final List<String> carouselImages ;
  final carouselImages = [
    'assets/images/header_background.jpg',
    'assets/images/header_background_2.jpg',
    'assets/images/header_background_3.jpg',
    'assets/images/header_background_4.jpg',
    'assets/images/header_background_5.jpg',];

  // 1. Ajoutez une variable pour stocker la position de l'utilisateur
  Position? _userPosition;

  // 2. Ajoutez une fonction qui sera appelée dans initState pour obtenir la position
  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    //carouselImages = _explorerService.getCarouselImages() as List<String>;

  }

  // 3. Fonction pour obtenir la position actuelle
  Future<void> _getCurrentPosition() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions refusées
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions refusées de façon permanente
        return;
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      print('Erreur de localisation: $e');
    }
  }

  // 4. Fonction pour calculer les lieux à proximité
  List<Place> _getNearbyPlaces(List<Place> allPlaces, Position? userPosition) {
    if (userPosition == null) return [];

    const maxDistance = 50.0;
    final placesWithDistance = <MapEntry<Place, double>>[];

    for (final place in allPlaces) {
      final GeoPoint location = place.localisation;

      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        location.latitude,
        location.longitude,
      ) / 1000;

      if (distance <= maxDistance) {
        placesWithDistance.add(MapEntry(place, distance));
      }
    }

    placesWithDistance.sort((a, b) => a.value.compareTo(b.value));

    return placesWithDistance
        .take(10)
        .map((entry) => entry.key)
        .toList();
  }


  // Utilise un getter pour éviter l’erreur d’accès prématuré
  List<Map<String, dynamic>> get _filters {
    final user = FirebaseAuth.instance.currentUser;
    return [
      {'name': 'Tous', 'icon': Icons.apps},
      if (user != null && !user.isAnonymous) {'name': 'Pour Vous', 'icon': Icons.push_pin},
      {'name': 'Populaire', 'icon': Icons.star},
      {'name': 'Historique', 'icon': Icons.history_edu},
      {'name': 'Nature', 'icon': Icons.landscape},
      {'name': 'Culture', 'icon': Icons.museum},
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // En-tête avec image de fond
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Ajout de la barre de recherche dans le "title"
            title: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchFocused = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaceSearchPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Rechercher un lieu...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    /*const Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                      size: 20,
                    ),*/
                  ],
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  /*Image.asset(
                    'assets/images/header_background.jpg',
                    fit: BoxFit.cover,
                  ),*/

                  CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items:
                    carouselImages.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Image.asset(image, fit: BoxFit.cover),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  Container(color: Colors.black.withOpacity(0.4)),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Découvrez l\'Algérie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explorez les plus beaux sites touristiques',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              final isSelected =
                                  filter['name'] == _selectedFilter;

                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = filter['name'];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                      isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          filter['icon'],
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          filter['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des lieux
          StreamBuilder<List<Place>>(
            stream: _explorerService.getPlaces(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(
                      child: Text('Erreur lors du chargement des lieux.')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Aucune donnée disponible.')),
                );
              }


              try {
                var places = snapshot.data!;
                final user = FirebaseAuth.instance.currentUser;

                //  1. Charger les recommandations si user connecté et "Pour Vous" sélectionné
                List<Recommend> recommendationData= [] ;
                if (_selectedFilter == 'Pour Vous' && user != null && !user.isAnonymous ){
                  // Charger de manière synchrone via FutureBuilder ou external call
                  return StreamBuilder<List<Recommend>>(
                    stream: _explorerService.getUserRecommendations(user.uid),
                    builder: (context, recSnapshot) {
                      if (recSnapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (recSnapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text(
                              'Erreur lors du chargement des recommandations:${recSnapshot.error}')),
                        );
                      }

                      if (recSnapshot.data == null || recSnapshot.data!.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                  "Suggestions personnalisées à venir."),
                            ),
                          ),
                        );
                      }

                      recommendationData = recSnapshot.data!;
                      // Poursuivre avec affichage après chargement
                      return _buildFilteredPlaceList(places, _selectedFilter, recommendationData);
                    },
                  );
                }

                //  2. Pas de "Pour Vous", on affiche normalement
                return _buildFilteredPlaceList(places, _selectedFilter, recommendationData);
              } catch (e) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Erreur interne : ${e.toString()}'),
                  ),
                );
              }
            },
          ),
        ],),

    );
  }

  Widget _buildFilteredPlaceList(List<Place> places, String filter, List<Recommend> recommendationData) {
    final user = FirebaseAuth.instance.currentUser;

    final filteredPlaces = places.where((place) {
      final categories = place.categorie;
      final placeWilaya = place.wilaya;

      switch (filter) {

        case 'Pour Vous':
          if (user == null || user.isAnonymous || recommendationData.isEmpty) return false;
          final userCateg = recommendationData.expand((place) => place.categ).toSet();
          final categMatches = categories.any((c) => userCateg.contains(c));
          final userWilayaLists = recommendationData.map((rec) => rec.wilaya).toList();
          final wilayaMatches = userWilayaLists.any((wilayaList) => wilayaList.contains(placeWilaya));
          return wilayaMatches || categMatches;

        case 'Populaire':
          return (place.rating ?? 0.0) >= 3.5;

        case 'Historique':
          return categories.contains('historique');

        case 'Nature':
          return categories.contains('naturel');

        case 'Culture':
          return categories.contains('culturel');

        default:
          return true;
      }
    }).toList();

    if (filteredPlaces.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucun lieu trouvé',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (filter == 'Pour Vous') {
      // Grouper les lieux par wilaya
      final wilayaGroups = <String, List<Place>>{};
      for (var place in filteredPlaces) {
        final wilaya = place.wilaya as String? ?? 'Autre';
        wilayaGroups.putIfAbsent(wilaya, () => []).add(place);
      }

      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(() {
              final entries = wilayaGroups.entries.toList();
              entries.sort((a, b) => a.key.compareTo(b.key));
              return entries.map((entry) {
                final wilaya = entry.key;
                final places = entry.value;
                return buildPlaceSection(
                  wilaya.toUpperCase(),
                  'Découvrez des lieux à $wilaya.',
                  places,
                );
              }).toList();
            })(),
          ],
        ),
      );

    }

    // Cas par défaut : affichage Nord/Est/Sud/Ouest
    final nordPlaces = filteredPlaces.where((place) => (place.tags.contains('nord'))).toList();
    final estPlaces = filteredPlaces.where((place) => (place.tags.contains('est'))).toList();
    final sudPlaces = filteredPlaces.where((place) => (place.tags.contains('sud'))).toList();
    final ouestPlaces = filteredPlaces.where((place) => (place.tags.contains('ouest'))).toList();
    // Récupérer les lieux à proximité (pour tous les filtres)
    //final nearbyPlaces = _userPosition != null ? _getNearbyPlaces(filteredPlaces, _userPosition) : [];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_userPosition != null && _selectedFilter == 'Tous' )
            buildPlaceSection('AUTOUR DE VOUS !', '"Des merveilles à quelques pas de vous"', _getNearbyPlaces(places, _userPosition)),

          buildPlaceSection('NORD !', '"Plages, collines et villages : le Nord vous ouvre ses bras."', nordPlaces),
          buildPlaceSection('EST !', '"Explorez l’Est : là où les traditions rencontrent la nature."', estPlaces),
          buildPlaceSection('SUD !', '"Le Sud ne se visite pas, il se ressent."', sudPlaces),
          buildPlaceSection('OUEST !', '"Dans l’Ouest, on ne vit pas, on célèbre la vie."', ouestPlaces),
        ],
      ),
    );
  }

  Widget buildPlaceCard(Place place, {double? distance}) {
    final List images = (place.images ?? []);
    final imageUrl = images.isNotEmpty ? images.first.toString() : '';

    return SizedBox(
      width: 260,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(placeId: place.id),
              ),
            );
          },
          child: Stack(  // Changé en Stack pour pouvoir positionner le badge de distance
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: place.images[0],
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.broken_image),
                        fit: BoxFit.cover,
                      )
                      /*Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 40)),
                        ),
                      )*/
                          : Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.nom ?? 'Sans nom',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.wilaya ?? 'Emplacement inconnu',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('${place.rating ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Badge de distance (affiché seulement si distance est fournie)
              if (distance != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    /*child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),  // Icône de localisation au lieu de directions
                        const SizedBox(width: 4),
                        Text(
                          'À proximité',  // Texte "À proximité" au lieu de la distance
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),*/
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlaceSection(String title, String citas, List<Place> sectionPlaces) {
    // Vérifier si c'est la section "AUTOUR DE VOUS"
    final bool isNearbySection = title == 'AUTOUR DE VOUS !';
    if (sectionPlaces.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                citas,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < (sectionPlaces.length / 6).ceil(); i++)
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sectionPlaces.length,
              itemBuilder: (context, index) {
                if (index < i * 6 || index >= (i + 1) * 6) return const SizedBox.shrink();

                // Si c'est la section "Autour de vous", calculer la distance
                if (isNearbySection && _userPosition != null) {
                  final place = sectionPlaces[index];
                  final GeoPoint location = place.localisation;

                  // Calculer la distance
                  final distance = Geolocator.distanceBetween(
                    _userPosition!.latitude,
                    _userPosition!.longitude,
                    location.latitude,
                    location.longitude,
                  ) / 1000; // Convertir en kilomètres

                  return buildPlaceCard(sectionPlaces[index], distance: distance);
                }

                // Pour les autres sections ou si pas de localisation
                return buildPlaceCard(sectionPlaces[index]);
              },
            ),
          ),
      ],
    );
  }

}*/





/*
import '../services/recommendations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'place_details_screen.dart';
import 'search_screenn.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../services/comment_section.dart';
import 'rating_system.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import '../services/explorer_service.dart';
import '../services/places.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({Key? key}) : super(key: key);


  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  bool _isSearchFocused = false;
  String _selectedFilter = 'Tous';

  late final _explorerService=ExplorerService();
  //late final List<String> carouselImages ;
  final carouselImages = [
    'assets/images/header_background.jpg',
    'assets/images/header_background_2.jpg',
    'assets/images/header_background_3.jpg',
    'assets/images/header_background_4.jpg',
    'assets/images/header_background_5.jpg',];

  // 1. Ajoutez une variable pour stocker la position de l'utilisateur
  Position? _userPosition;

  // 2. Ajoutez une fonction qui sera appelée dans initState pour obtenir la position
  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    //carouselImages = _explorerService.getCarouselImages() as List<String>;

  }

  // 3. Fonction pour obtenir la position actuelle
  Future<void> _getCurrentPosition() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions refusées
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions refusées de façon permanente
        return;
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      print('Erreur de localisation: $e');
    }
  }

  // 4. Fonction pour calculer les lieux à proximité
  List<Place> _getNearbyPlaces(List<Place> allPlaces, Position? userPosition) {
    if (userPosition == null) return [];

    const maxDistance = 50.0;
    final placesWithDistance = <MapEntry<Place, double>>[];

    for (final place in allPlaces) {
      final GeoPoint location = place.localisation;

      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        location.latitude,
        location.longitude,
      ) / 1000;

      if (distance <= maxDistance) {
        placesWithDistance.add(MapEntry(place, distance));
      }
    }

    placesWithDistance.sort((a, b) => a.value.compareTo(b.value));

    return placesWithDistance
        .take(10)
        .map((entry) => entry.key)
        .toList();
  }


  // Utilise un getter pour éviter l’erreur d’accès prématuré
  List<Map<String, dynamic>> get _filters {
    final user = FirebaseAuth.instance.currentUser;
    return [
      {'name': 'Tous', 'icon': Icons.apps},
      if (user != null && !user.isAnonymous) {'name': 'Pour Vous', 'icon': Icons.push_pin},
      {'name': 'Populaire', 'icon': Icons.star},
      {'name': 'Historique', 'icon': Icons.history_edu},
      {'name': 'Nature', 'icon': Icons.landscape},
      {'name': 'Culture', 'icon': Icons.museum},
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // En-tête avec image de fond
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Ajout de la barre de recherche dans le "title"
            title: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchFocused = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaceSearchPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Rechercher un lieu...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    /*const Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                      size: 20,
                    ),*/
                  ],
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  /*Image.asset(
                    'assets/images/header_background.jpg',
                    fit: BoxFit.cover,
                  ),*/

                  CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items:
                    carouselImages.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Image.asset(image, fit: BoxFit.cover),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  Container(color: Colors.black.withOpacity(0.4)),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Découvrez l\'Algérie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explorez les plus beaux sites touristiques',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              final isSelected =
                                  filter['name'] == _selectedFilter;

                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = filter['name'];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                      isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          filter['icon'],
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          filter['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des lieux
          StreamBuilder<List<Place>>(
            stream: _explorerService.getPlaces(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(
                      child: Text('Erreur lors du chargement des lieux.')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Aucune donnée disponible.')),
                );
              }


              try {
                var places = snapshot.data!;
                final user = FirebaseAuth.instance.currentUser;

                //  1. Charger les recommandations si user connecté et "Pour Vous" sélectionné
                List<Recommend> recommendationData= [] ;
                if (_selectedFilter == 'Pour Vous' && user != null && !user.isAnonymous ){
                  // Charger de manière synchrone via FutureBuilder ou external call
                  return StreamBuilder<List<Recommend>>(
                    stream: _explorerService.getUserRecommendations(user.uid),
                    builder: (context, recSnapshot) {
                      if (recSnapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (recSnapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text(
                              'Erreur lors du chargement des recommandations:${recSnapshot.error}')),
                        );
                      }

                      if (recSnapshot.data == null || recSnapshot.data!.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                  "Suggestions personnalisées à venir."),
                            ),
                          ),
                        );
                      }

                      recommendationData = recSnapshot.data!;
                      // Poursuivre avec affichage après chargement
                      return _buildFilteredPlaceList(places, _selectedFilter, recommendationData);
                    },
                  );
                }

                //  2. Pas de "Pour Vous", on affiche normalement
                return _buildFilteredPlaceList(places, _selectedFilter, recommendationData);
              } catch (e) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Erreur interne : ${e.toString()}'),
                  ),
                );
              }
            },
          ),
        ],),

    );
  }

  Widget _buildFilteredPlaceList(List<Place> places, String filter, List<Recommend> recommendationData) {
    final user = FirebaseAuth.instance.currentUser;

    final filteredPlaces = places.where((place) {
      final categories = place.categorie;
      final placeWilaya = place.wilaya;

      switch (filter) {

        case 'Pour Vous':
          if (user == null || user.isAnonymous || recommendationData.isEmpty) return false;
          final userCateg = recommendationData.expand((place) => place.categ).toSet();
          final userWilaya = recommendationData.map((place) => place.wilaya).toSet();
          final wilayaMatches = userWilaya.contains(placeWilaya);
          final categMatches = categories.any((c) => userCateg.contains(c));
          return wilayaMatches || categMatches;

        case 'Populaire':
          return (place.rating ?? 0.0) >= 3.5;

        case 'Historique':
          return categories.contains('historique');

        case 'Nature':
          return categories.contains('naturel');

        case 'Culture':
          return categories.contains('culturel');

        default:
          return true;
      }
    }).toList();

    if (filteredPlaces.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucun lieu trouvé',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (filter == 'Pour Vous') {
      // Grouper les lieux par wilaya
      final wilayaGroups = <String, List<Place>>{};
      for (var place in filteredPlaces) {
        final wilaya = place.wilaya as String? ?? 'Autre';
        wilayaGroups.putIfAbsent(wilaya, () => []).add(place);
      }

      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(() {
              final entries = wilayaGroups.entries.toList();
              entries.sort((a, b) => a.key.compareTo(b.key));
              return entries.map((entry) {
                final wilaya = entry.key;
                final places = entry.value;
                return buildPlaceSection(
                  wilaya.toUpperCase(),
                  'Découvrez des lieux à $wilaya.',
                  places,
                );
              }).toList();
            })(),
          ],
        ),
      );

    }

    // Cas par défaut : affichage Nord/Est/Sud/Ouest
    final nordPlaces = filteredPlaces.where((place) => (place.tags.contains('nord'))).toList();
    final estPlaces = filteredPlaces.where((place) => (place.tags.contains('est'))).toList();
    final sudPlaces = filteredPlaces.where((place) => (place.tags.contains('sud'))).toList();
    final ouestPlaces = filteredPlaces.where((place) => (place.tags.contains('ouest'))).toList();
    // Récupérer les lieux à proximité (pour tous les filtres)
    //final nearbyPlaces = _userPosition != null ? _getNearbyPlaces(filteredPlaces, _userPosition) : [];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_userPosition != null && _selectedFilter == 'Tous' )
            buildPlaceSection('AUTOUR DE VOUS !', '"Des merveilles à quelques pas de vous"', _getNearbyPlaces(places, _userPosition)),

          buildPlaceSection('NORD !', '"Plages, collines et villages : le Nord vous ouvre ses bras."', nordPlaces),
          buildPlaceSection('EST !', '"Explorez l’Est : là où les traditions rencontrent la nature."', estPlaces),
          buildPlaceSection('SUD !', '"Le Sud ne se visite pas, il se ressent."', sudPlaces),
          buildPlaceSection('OUEST !', '"Dans l’Ouest, on ne vit pas, on célèbre la vie."', ouestPlaces),
        ],
      ),
    );
  }

  Widget buildPlaceCard(Place place, {double? distance}) {
    final List images = (place.images ?? []);
    final imageUrl = images.isNotEmpty ? images.first.toString() : '';

    return SizedBox(
      width: 260,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(placeId: place.id),
              ),
            );
          },
          child: Stack(  // Changé en Stack pour pouvoir positionner le badge de distance
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 40)),
                        ),
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.nom ?? 'Sans nom',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.wilaya ?? 'Emplacement inconnu',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('${place.rating ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Badge de distance (affiché seulement si distance est fournie)
              if (distance != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    /*child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),  // Icône de localisation au lieu de directions
                        const SizedBox(width: 4),
                        Text(
                          'À proximité',  // Texte "À proximité" au lieu de la distance
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),*/
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlaceSection(String title, String citas, List<Place> sectionPlaces) {
    // Vérifier si c'est la section "AUTOUR DE VOUS"
    final bool isNearbySection = title == 'AUTOUR DE VOUS !';
    if (sectionPlaces.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                citas,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < (sectionPlaces.length / 6).ceil(); i++)
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sectionPlaces.length,
              itemBuilder: (context, index) {
                if (index < i * 6 || index >= (i + 1) * 6) return const SizedBox.shrink();

                // Si c'est la section "Autour de vous", calculer la distance
                if (isNearbySection && _userPosition != null) {
                  final place = sectionPlaces[index];
                  final GeoPoint location = place.localisation;

                  // Calculer la distance
                  final distance = Geolocator.distanceBetween(
                    _userPosition!.latitude,
                    _userPosition!.longitude,
                    location.latitude,
                    location.longitude,
                  ) / 1000; // Convertir en kilomètres

                  return buildPlaceCard(sectionPlaces[index], distance: distance);
                }

                // Pour les autres sections ou si pas de localisation
                return buildPlaceCard(sectionPlaces[index]);
              },
            ),
          ),
      ],
    );
  }

}*/










import '../services/recommendations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'place_details_screen.dart';
import 'search_screenn.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../services/comment_section.dart';
import 'rating_system.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import '../services/explorer_service.dart';
import '../services/places.dart';


class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({Key? key}) : super(key: key);


  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  bool _isSearchFocused = false;
  String _selectedFilter = 'Tous';

  late final _explorerService=ExplorerService();
  //late final List<String> carouselImages ;
  final carouselImages = [
    'assets/images/header_background.jpg',
    'assets/images/header_background_2.jpg',
    'assets/images/header_background_3.jpg',
    'assets/images/header_background_4.jpg',
    'assets/images/header_background_5.jpg',];

  // 1. Ajoutez une variable pour stocker la position de l'utilisateur
  Position? _userPosition;

  // 2. Ajoutez une fonction qui sera appelée dans initState pour obtenir la position
  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    //carouselImages = _explorerService.getCarouselImages() as List<String>;

  }

  // 3. Fonction pour obtenir la position actuelle
  Future<void> _getCurrentPosition() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions refusées
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions refusées de façon permanente
        return;
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      print('Erreur de localisation: $e');
    }
  }

  // 4. Fonction pour calculer les lieux à proximité
  List<Place> _getNearbyPlaces(List<Place> allPlaces, Position? userPosition) {
    if (userPosition == null) return [];

    const maxDistance = 50.0;
    final placesWithDistance = <MapEntry<Place, double>>[];

    for (final place in allPlaces) {
      final GeoPoint location = place.localisation;

      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        location.latitude,
        location.longitude,
      ) / 1000;

      if (distance <= maxDistance) {
        placesWithDistance.add(MapEntry(place, distance));
      }
    }

    placesWithDistance.sort((a, b) => a.value.compareTo(b.value));

    return placesWithDistance
        .take(10)
        .map((entry) => entry.key)
        .toList();
  }


  // Utilise un getter pour éviter l’erreur d’accès prématuré
  List<Map<String, dynamic>> get _filters {
    final user = FirebaseAuth.instance.currentUser;
    return [
      {'name': 'Tous', 'icon': Icons.apps},
      if (user != null && !user.isAnonymous) {'name': 'Pour Vous', 'icon': Icons.push_pin},
      {'name': 'Populaire', 'icon': Icons.star},
      {'name': 'Historique', 'icon': Icons.history_edu},
      {'name': 'Nature', 'icon': Icons.landscape},
      {'name': 'Culture', 'icon': Icons.museum},
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // En-tête avec image de fond
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Ajout de la barre de recherche dans le "title"
            title: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchFocused = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaceSearchPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Rechercher un lieu...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    /*const Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                      size: 20,
                    ),*/
                  ],
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  /*Image.asset(
                    'assets/images/header_background.jpg',
                    fit: BoxFit.cover,
                  ),*/

                  CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items:
                    carouselImages.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Image.asset(image, fit: BoxFit.cover),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  Container(color: Colors.black.withOpacity(0.4)),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Découvrez l\'Algérie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explorez les plus beaux sites touristiques',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              final isSelected =
                                  filter['name'] == _selectedFilter;

                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = filter['name'];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                      isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          filter['icon'],
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          filter['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des lieux
          StreamBuilder<List<Place>>(
            stream: _explorerService.getPlaces(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(
                      child: Text('Erreur lors du chargement des lieux.')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Aucune donnée disponible.')),
                );
              }


              try {
                var places = snapshot.data!;
                final user = FirebaseAuth.instance.currentUser;

                //  1. Charger les recommandations si user connecté et "Pour Vous" sélectionné
                List<Recommend> recommendationData= [] ;
                if (_selectedFilter == 'Pour Vous' && user != null && !user.isAnonymous ){
                  // Charger de manière synchrone via FutureBuilder ou external call
                  return StreamBuilder<List<Recommend>>(
                    stream: _explorerService.getUserRecommendations(user.uid),
                    builder: (context, recSnapshot) {
                      if (recSnapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (recSnapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text(
                              'Erreur lors du chargement des recommandations:${recSnapshot.error}')),
                        );
                      }

                      if (recSnapshot.data == null || recSnapshot.data!.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                  "Suggestions personnalisées à venir."),
                            ),
                          ),
                        );
                      }

                      recommendationData = recSnapshot.data!;
                      // Poursuivre avec affichage après chargement
                      return _buildFilteredPlaceList(places, _selectedFilter, recommendationData);
                    },
                  );
                }

                //  2. Pas de "Pour Vous", on affiche normalement
                return _buildFilteredPlaceList(places, _selectedFilter, recommendationData);
              } catch (e) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Erreur interne : ${e.toString()}'),
                  ),
                );
              }
            },
          ),
        ],),

    );
  }

  Widget _buildFilteredPlaceList(List<Place> places, String filter, List<Recommend> recommendationData) {
    final user = FirebaseAuth.instance.currentUser;

    final filteredPlaces = places.where((place) {
      final categories = place.categorie;
      final placeWilaya = place.wilaya;

      switch (filter) {

        case 'Pour Vous':
          if (user == null || user.isAnonymous || recommendationData.isEmpty) return false;
          final userCateg = recommendationData.expand((place) => place.categ).toSet();
          final userWilaya = recommendationData.map((place) => place.wilaya).toSet();
          final wilayaMatches = userWilaya.contains(placeWilaya);
          final categMatches = categories.any((c) => userCateg.contains(c));
          return wilayaMatches || categMatches;

        case 'Populaire':
          return (place.rating ?? 0.0) >= 3.5;

        case 'Historique':
          return categories.contains('historique');

        case 'Nature':
          return categories.contains('naturel');

        case 'Culture':
          return categories.contains('culturel');

        default:
          return true;
      }
    }).toList();

    if (filteredPlaces.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucun lieu trouvé',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (filter == 'Pour Vous') {
      // Grouper les lieux par wilaya
      final wilayaGroups = <String, List<Place>>{};
      for (var place in filteredPlaces) {
        final wilaya = place.wilaya as String? ?? 'Autre';
        wilayaGroups.putIfAbsent(wilaya, () => []).add(place);
      }

      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(() {
              final entries = wilayaGroups.entries.toList();
              entries.sort((a, b) => a.key.compareTo(b.key));
              return entries.map((entry) {
                final wilaya = entry.key;
                final places = entry.value;
                return buildPlaceSection(
                  wilaya.toUpperCase(),
                  'Découvrez des lieux à $wilaya.',
                  places,
                );
              }).toList();
            })(),
          ],
        ),
      );

    }

    // Cas par défaut : affichage Nord/Est/Sud/Ouest
    final nordPlaces = filteredPlaces.where((place) => (place.tags.contains('nord'))).toList();
    final estPlaces = filteredPlaces.where((place) => (place.tags.contains('est'))).toList();
    final sudPlaces = filteredPlaces.where((place) => (place.tags.contains('sud'))).toList();
    final ouestPlaces = filteredPlaces.where((place) => (place.tags.contains('ouest'))).toList();
    // Récupérer les lieux à proximité (pour tous les filtres)
    //final nearbyPlaces = _userPosition != null ? _getNearbyPlaces(filteredPlaces, _userPosition) : [];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_userPosition != null && _selectedFilter == 'Tous' )
            buildPlaceSection('AUTOUR DE VOUS !', '"Des merveilles à quelques pas de vous"', _getNearbyPlaces(places, _userPosition)),

          buildPlaceSection('NORD !', '"Plages, collines et villages : le Nord vous ouvre ses bras."', nordPlaces),
          buildPlaceSection('EST !', '"Explorez l’Est : là où les traditions rencontrent la nature."', estPlaces),
          buildPlaceSection('SUD !', '"Le Sud ne se visite pas, il se ressent."', sudPlaces),
          buildPlaceSection('OUEST !', '"Dans l’Ouest, on ne vit pas, on célèbre la vie."', ouestPlaces),
        ],
      ),
    );
  }

  Widget buildPlaceCard(Place place, {double? distance}) {
    final List images = (place.images ?? []);
    final imageUrl = images.isNotEmpty ? images.first.toString() : '';

    return SizedBox(
      width: 260,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(placeId: place.id),
              ),
            );
          },
          child: Stack(  // Changé en Stack pour pouvoir positionner le badge de distance
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 40)),
                        ),
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.nom ?? 'Sans nom',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.wilaya ?? 'Emplacement inconnu',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('${place.rating ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Badge de distance (affiché seulement si distance est fournie)
              if (distance != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    /*child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),  // Icône de localisation au lieu de directions
                        const SizedBox(width: 4),
                        Text(
                          'À proximité',  // Texte "À proximité" au lieu de la distance
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),*/
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlaceSection(String title, String citas, List<Place> sectionPlaces) {
    // Vérifier si c'est la section "AUTOUR DE VOUS"
    final bool isNearbySection = title == 'AUTOUR DE VOUS !';
    if (sectionPlaces.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                citas,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < (sectionPlaces.length / 6).ceil(); i++)
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sectionPlaces.length,
              itemBuilder: (context, index) {
                if (index < i * 6 || index >= (i + 1) * 6) return const SizedBox.shrink();

                // Si c'est la section "Autour de vous", calculer la distance
                if (isNearbySection && _userPosition != null) {
                  final place = sectionPlaces[index];
                  final GeoPoint location = place.localisation;

                  // Calculer la distance
                  final distance = Geolocator.distanceBetween(
                    _userPosition!.latitude,
                    _userPosition!.longitude,
                    location.latitude,
                    location.longitude,
                  ) / 1000; // Convertir en kilomètres

                  return buildPlaceCard(sectionPlaces[index], distance: distance);
                }

                // Pour les autres sections ou si pas de localisation
                return buildPlaceCard(sectionPlaces[index]);
              },
            ),
          ),
      ],
    );
  }

}