




/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailsScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Map<String, dynamic>? placeData;
  bool isLoading = true;
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;

  /*for Map

  Position? currentPosition;
  List<LatLng> routeCoordinates = [];
  String? distance; // Distance du trajet
  String? duration; // Durée du trajet
  late MapController mapController; // Contrôleur de carte

  // Votre clé OpenRouteService
  final String apiKey = '5b3ce3597851110001cf6248c5931504824945bd98834cae8e8f549f';
  for map*/

  @override
  void initState() {
    super.initState();
    fetchPlaceData();
    _checkIfFavorite();


    //for map : Malak
    //mapController = MapController(); // Initialisation du contrôleur
  }



  Future<void> fetchPlaceData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where(FieldPath.documentId, isEqualTo: widget.placeId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        placeData = querySnapshot.docs.first.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
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
        'nom':placeData?['nom'],
        'wilaya': placeData?['wilaya'],
        'images': placeData?['images'],
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

  /*for Map: MALAK
  Future<void> _getRoute() async {
    final geoPoint = placeData?['localisation'] as GeoPoint?;

    final lat = geoPoint?.latitude ?? 0.0;
    final lng = geoPoint?.longitude ?? 0.0;
    try {
      final startCoords = await _getCurrentLocation(context);
      if (startCoords == null) return;

      final endCoords = LatLng(lat, lng);

      final url = Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car/geojson');

      final response = await http.post(
        url,
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'coordinates': [
            [startCoords.longitude, startCoords.latitude],
            [endCoords.longitude, endCoords.latitude],
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          final coords = data['features'][0]['geometry']['coordinates'];
          final summary = data['features'][0]['properties']['summary'];

          setState(() {
            routeCoordinates = coords.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
            distance = (summary['distance'] / 1000).toStringAsFixed(1); // En km
            duration = (summary['duration'] / 60).toStringAsFixed(1); // En minutes
          });

          // Attendre que la carte soit rendue avant de déplacer la caméra
          WidgetsBinding.instance.addPostFrameCallback((_) {
            mapController.move(
              LatLng(
                (startCoords.latitude + endCoords.latitude) / 2,
                (startCoords.longitude + endCoords.longitude) / 2,
              ),
              13.0,
            );
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur API : ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau : $e")),
      );
    }
  }

  Future<Position?> _getCurrentLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez activer la localisation")),
        );
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Autorisation de localisation refusée")),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Autorisation de localisation bloquée. Veuillez activer la permission dans les paramètres.")),
        );
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => currentPosition = position);
      return position;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération de la position: $e")),
      );
      return null;
    }
  }

  for map*/

  /*sarahFuture<void> _openMaps() async {

    final geoPoint = placeData?['localisation'] as GeoPoint?;

    final lat = geoPoint?.latitude ?? 0.0;
    final lng = geoPoint?.longitude ?? 0.0;

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
  }*/

  /*sarah's new maps:*/
  Future<void> _openMaps() async {
    if (placeData != null)

    {
      try {
        // Obtenir les coordonnées du lieu de destination
        GeoPoint destinationGeoPoint = placeData?['localisation'];
        Uri url;

        try {
          // Essayer d'obtenir la position actuelle
          LocationPermission permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            // Si la permission est accordée, obtenir la position et créer l'itinéraire
            Position currentPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high
            );

            url = Uri.parse(
                'https://www.google.com/maps/dir/?api=1'
                    '&origin=${currentPosition.latitude},${currentPosition.longitude}'
                    '&destination=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
                    '&travelmode=driving'
            );
          } else {
            // Si la permission est refusée, afficher seulement la destination
            url = Uri.parse(
                'https://www.google.com/maps/search/?api=1'
                    '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
            );

            // Informer l'utilisateur
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Localisation refusée: affichage de la destination uniquement'),
                  backgroundColor: Colors.amber,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (locError) {
          // En cas d'erreur de localisation, afficher seulement la destination
          url = Uri.parse(
              'https://www.google.com/maps/search/?api=1'
                  '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
          );

          // Informer l'utilisateur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur de localisation: affichage de la destination uniquement'),
                backgroundColor: Colors.amber,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        // Lancer Google Maps
        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir Google Maps'),
              backgroundColor: Colors.red,
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune donnée de localisation disponible'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  /*sarah's new maps:*/

  @override
  Widget build(BuildContext context) {
    final geoPoint = placeData?['localisation'] as GeoPoint?;

    final lat = geoPoint?.latitude ?? 0.0;
    final lng = geoPoint?.longitude ?? 0.0;
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
                    final List<dynamic> images = placeData?['images'] ?? [];

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
                        items: images.map<Widget>((image) {
                          final imagePath = image.toString().trim();

                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $imagePath');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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

            /*flexibleSpace: FlexibleSpaceBar(
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
            ),*/
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      placeData?['nom'] ?? 'Sans nom',
                      style: const TextStyle(
                        fontSize: 28,
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
                            placeData?['wilaya'] ?? 'Emplacement inconnu',
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
                      placeData?['description'] ??
                          'Aucune description disponible.',
                      style: TextStyle(color: Colors.grey[800], height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    /*Still on on sarah 's new map:
                  if (widget.placeData['hours'] != null) ...[
                    const Text(
                      'Horaires',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //Text( widget.placeData['hours'],style: TextStyle(color: Colors.grey[800]),),
                    const SizedBox(height: 24),
                  ],

                   */
                    /* sarah's new map*/

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


                    /*for map:MALAK

                   Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.teal, size: 30),
                          onPressed: () {
                            _getRoute();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => Container(
                                height: 400,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Affichage de la carte
                                    Expanded(
                                      child: FlutterMap(
                                        mapController: mapController,
                                        options: MapOptions(
                                            initialCenter: LatLng(lat,lng),
                                            initialZoom: 13.0,
                                        ),
                                        children: [
                                          TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                width: 40,
                                                height: 40,
                                                point: LatLng(lat,lng),
                                                child: const Icon(Icons.location_on, color: Colors.red, size: 40,),
                                              ),
                                             if (currentPosition != null)
                                                Marker(
                                                  width: 40,
                                                  height: 40,
                                                  point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                                                  child: const Icon(Icons.location_on, color: Colors.blue , size:40,),
                                                ),

                                            ],
                                          ),
                                          if (routeCoordinates.isNotEmpty)
                                            PolylineLayer(
                                              polylines: [
                                                Polyline(
                                                  points: routeCoordinates,
                                                  color: Colors.blue.withOpacity(0.7),
                                                  strokeWidth: 5,
                                                ),
                                              ],
                                            ),
                                          if (routeCoordinates.isEmpty)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 12),
                                              child: Text("Itinéraire non disponible."),
                                            ),

                                        ],
                                      ),
                                    ),

                                    if (currentPosition == null)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: Text("Position actuelle non disponible"),
                                      ),
                                    // Affichage de la distance et du temps
                                    if (distance != null && duration != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          'Distance : ${distance ?? "--"} km | Durée : ${duration ?? "--"} min',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Bouton pour calculer l'itinéraire
                         ElevatedButton.icon(
                            onPressed:_getRoute,
                            icon: const Icon(Icons.route),
                            label: const Text("Calculer l'itinéraire"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),


                      ],
                  ),
                  for map*/
                  ]
              ),
            ),
          ),
          /*sarah's new map*/
          // Dans la liste des Slivers de votre CustomScrollView
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RatingSystem(
                placeId: widget.placeId,
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: CommentSectionWithButton(placeId: widget.placeId),
          ),

          // Espace supplémentaire en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),

          /*sarah's new map*/
        ],
      ),
    );
  }
}*/



/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;



  const PlaceDetailsScreen({Key? key, required this.placeId }) : super(key: key);


  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Map<String, dynamic>? placeData;
  bool isLoading = true;
  bool isLoading2 = true;
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;



  @override
  void initState() {
    super.initState();
    fetchPlaceData();
    _checkIfFavorite();



  }



  Future<void> fetchPlaceData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where(FieldPath.documentId, isEqualTo: widget.placeId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        placeData = querySnapshot.docs.first.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
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

    final favCollection = FirebaseFirestore.instance.collection('favorites');

    if (_isFavorite) {
      // 1. Add to favorites
      await favCollection.add({
        'userId': user!.uid,
        'placeId': widget.placeId,
        'nom': placeData?['nom'],
        'wilaya': placeData?['wilaya'],
        'images': placeData?['images'],
        'addedAt': FieldValue.serverTimestamp(),
      });

      // 2. Fetch all favorites for this user
      final favSnapshot = await favCollection
          .where('userId', isEqualTo: user!.uid)
          .get();

      // 3. Initialize scoring maps
      Map<String, int> recCateg = {};
      Map<String, int> recWilaya = {};

      for (var favDoc in favSnapshot.docs) {
        final placeId = favDoc['placeId'];

        // 4. Fetch place document
        final placeDoc = await FirebaseFirestore.instance
            .collection('places')
            .doc(placeId)
            .get();

        if (placeDoc.exists) {
          // Score categories
          final categories = placeDoc['categorie'] as List<dynamic>? ?? [];
          for (var cat in categories) {
            if (cat is String) {
              recCateg[cat] = (recCateg[cat] ?? 0) + 1;
            }
          }

          // Score wilaya
          final wilaya = placeDoc['wilaya'];
          if (wilaya is String) {
            recWilaya[wilaya] = (recWilaya[wilaya] ?? 0) + 1;
          }
        }
      }

      // 5. Sort and get top 2 categories and wilayas
      final topCategories = recCateg.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topWilayas = recWilaya.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topTwoCategories = topCategories.take(2).map((e) => e.key).toList();
      final topTwoWilayas = topWilayas.take(2).map((e) => e.key).toList();

      // 6. Update or create recommendation document
      final recommendationCollection =
      FirebaseFirestore.instance.collection('recommendation');

      final querySnapshot = await recommendationCollection
          .where('userId', isEqualTo: user!.uid)
          .get();

      final dataToSave = {
        'userId': user!.uid,
        'categ': topTwoCategories,
        'wilaya': topTwoWilayas,
      };

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update(dataToSave);
      } else {
        await recommendationCollection.add(dataToSave);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajouté aux favoris'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    else {
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



  /*sarah's new maps:*/
  Future<void> _openMaps() async {
    if (placeData != null)

    {
      try {
        // Obtenir les coordonnées du lieu de destination
        GeoPoint destinationGeoPoint = placeData?['localisation'];
        Uri url;

        try {
          // Essayer d'obtenir la position actuelle
          LocationPermission permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            // Si la permission est accordée, obtenir la position et créer l'itinéraire
            Position currentPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high
            );

            url = Uri.parse(
                'https://www.google.com/maps/dir/?api=1'
                    '&origin=${currentPosition.latitude},${currentPosition.longitude}'
                    '&destination=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
                    '&travelmode=driving'
            );
          } else {
            // Si la permission est refusée, afficher seulement la destination
            url = Uri.parse(
                'https://www.google.com/maps/search/?api=1'
                    '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
            );

            // Informer l'utilisateur
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Localisation refusée: affichage de la destination uniquement'),
                  backgroundColor: Colors.amber,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (locError) {
          // En cas d'erreur de localisation, afficher seulement la destination
          url = Uri.parse(
              'https://www.google.com/maps/search/?api=1'
                  '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
          );

          // Informer l'utilisateur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur de localisation: affichage de la destination uniquement'),
                backgroundColor: Colors.amber,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        // Lancer Google Maps
        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir Google Maps'),
              backgroundColor: Colors.red,
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune donnée de localisation disponible'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  /*sarah's new maps:*/

  @override
  Widget build(BuildContext context) {
    final geoPoint = placeData?['localisation'] as GeoPoint?;

    final lat = geoPoint?.latitude ?? 0.0;
    final lng = geoPoint?.longitude ?? 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
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
                    final List<dynamic> images = placeData?['images'] ?? [];

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
                        items: images.map<Widget>((image) {
                          final imagePath = image.toString().trim();

                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $imagePath');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      placeData?['nom'] ?? 'Sans nom',
                      style: const TextStyle(
                        fontSize: 28,
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
                            placeData?['wilaya'] ?? 'Emplacement inconnu',
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
                      placeData?['description'] ??
                          'Aucune description disponible.',
                      style: TextStyle(color: Colors.grey[800], height: 1.5),
                    ),
                    const SizedBox(height: 24),



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



                  ]
              ),
            ),
          ),
          /*sarah's new map*/
          // Dans la liste des Slivers de votre CustomScrollView
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RatingSystem(
                placeId: widget.placeId,
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: CommentSectionWithButton(placeId: widget.placeId),
          ),

          // Espace supplémentaire en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),

          /*sarah's new map*/
        ],
      ),
    );
  }
}
*/





/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../services/places.dart';
import '../services/place_details_service.dart';
import '../services/comment_section.dart';
import 'rating_system.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailsScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Map<String, dynamic>? placeData;
  late Place placedata=Place(id: '', nom: '', nomin: '', wilaya: '', description: '', categorie: [], tags: [], images: [], localisation: GeoPoint(0.0, 0.0), rating: 0.0);
  bool isLoading = true;
  bool isLoading2 = true;
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;
  late final _PlaceDetailsService=PlaceDetailsService();


  @override
  void initState() {
    super.initState();
    fetchPlaceData();
    _checkIfFavorite();
  }



  Future<void> fetchPlaceData() async {
    final place = await _PlaceDetailsService.fetchPlaceData(widget.placeId);

    if (place!=null) {
      setState(() {
        placedata = place;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    if (user == null || user!.isAnonymous) return;

    final doc =
    await _PlaceDetailsService.checkIfFavorite(user!.uid, widget.placeId);

    if (mounted) {
      setState(() {
        _isFavorite = doc!=null;
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

    final placeinfo=[placedata.nom,placedata.wilaya,placedata.images];
    await _PlaceDetailsService.toggleFavorite(user!.uid, widget.placeId,_isFavorite,placeinfo);

    if (_isFavorite) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajouté aux favoris'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    else {
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

  /*sarah's new maps:*/
  Future<void> _openMaps() async {
    if (placedata != null)
    {
      try {
        // Obtenir les coordonnées du lieu de destination
        GeoPoint destinationGeoPoint = placedata.localisation;
        Uri url;

        try {
          // Essayer d'obtenir la position actuelle
          LocationPermission permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            // Si la permission est accordée, obtenir la position et créer l'itinéraire
            Position currentPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high
            );

            url = Uri.parse(
                'https://www.google.com/maps/dir/?api=1'
                    '&origin=${currentPosition.latitude},${currentPosition.longitude}'
                    '&destination=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
                    '&travelmode=driving'
            );
          } else {
            // Si la permission est refusée, afficher seulement la destination
            url = Uri.parse(
                'https://www.google.com/maps/search/?api=1'
                    '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
            );

            // Informer l'utilisateur
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Localisation refusée: affichage de la destination uniquement'),
                  backgroundColor: Colors.amber,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (locError) {
          // En cas d'erreur de localisation, afficher seulement la destination
          url = Uri.parse(
              'https://www.google.com/maps/search/?api=1'
                  '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
          );

          // Informer l'utilisateur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur de localisation: affichage de la destination uniquement'),
                backgroundColor: Colors.amber,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        // Lancer Google Maps
        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir Google Maps'),
              backgroundColor: Colors.red,
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune donnée de localisation disponible'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  /*sarah's new maps:*/

  @override
  Widget build(BuildContext context) {
    final geoPoint = placedata.localisation as GeoPoint?;

    final lat = geoPoint?.latitude ?? 0.0;
    final lng = geoPoint?.longitude ?? 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
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
                    final List<dynamic> images = placedata.images ?? [];

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
                        items: images.map<Widget>((image) {
                          final imagePath = image.toString().trim();

                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $imagePath');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      placedata.nom ?? 'Sans nom',
                      style: const TextStyle(
                        fontSize: 28,
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
                            placedata.wilaya ?? 'Emplacement inconnu',
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
                      placedata.description??
                          'Aucune description disponible.',
                      style: TextStyle(color: Colors.grey[800], height: 1.5),
                    ),
                    const SizedBox(height: 24),



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
                  ]
              ),
            ),
          ),
          /*sarah's new map*/
          // Dans la liste des Slivers de votre CustomScrollView
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RatingSystem(
                placeId: widget.placeId,
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: CommentSectionWithButton(placeId: widget.placeId),
          ),

          // Espace supplémentaire en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),

          /*sarah's new map*/
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
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../services/places.dart';
import '../services/place_details_service.dart';
import '../services/comment_section.dart';
import 'rating_system.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'comment_section_with_button.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailsScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Map<String, dynamic>? placeData;
  late Place placedata=Place(id: '', nom: '', nomin: '', wilaya: '', description: '', categorie: [], tags: [], images: [], localisation: GeoPoint(0.0, 0.0), rating: 0.0);
  bool isLoading = true;
  bool isLoading2 = true;
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;
  late final _PlaceDetailsService=PlaceDetailsService();


  @override
  void initState() {
    super.initState();
    fetchPlaceData();
    _checkIfFavorite();
  }



  Future<void> fetchPlaceData() async {
    final place = await _PlaceDetailsService.fetchPlaceData(widget.placeId);

    if (place!=null) {
      setState(() {
        placedata = place;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    if (user == null || user!.isAnonymous) return;

    final doc =
    await _PlaceDetailsService.checkIfFavorite(user!.uid, widget.placeId);

    if (mounted) {
      setState(() {
        _isFavorite = doc!=null;
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

    final placeinfo=[placedata.nom,placedata.wilaya,placedata.images];
    await _PlaceDetailsService.toggleFavorite(user!.uid, widget.placeId,_isFavorite,placeinfo);

    if (_isFavorite) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajouté aux favoris'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    else {
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

  /*sarah's new maps:*/
  Future<void> _openMaps() async {
    if (placedata != null)
    {
      try {
        // Obtenir les coordonnées du lieu de destination
        GeoPoint destinationGeoPoint = placedata.localisation;
        Uri url;

        try {
          // Essayer d'obtenir la position actuelle
          LocationPermission permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            // Si la permission est accordée, obtenir la position et créer l'itinéraire
            Position currentPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high
            );

            url = Uri.parse(
                'https://www.google.com/maps/dir/?api=1'
                    '&origin=${currentPosition.latitude},${currentPosition.longitude}'
                    '&destination=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
                    '&travelmode=driving'
            );
          } else {
            // Si la permission est refusée, afficher seulement la destination
            url = Uri.parse(
                'https://www.google.com/maps/search/?api=1'
                    '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
            );

            // Informer l'utilisateur
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Localisation refusée: affichage de la destination uniquement'),
                  backgroundColor: Colors.amber,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (locError) {
          // En cas d'erreur de localisation, afficher seulement la destination
          url = Uri.parse(
              'https://www.google.com/maps/search/?api=1'
                  '&query=${destinationGeoPoint.latitude},${destinationGeoPoint.longitude}'
          );

          // Informer l'utilisateur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur de localisation: affichage de la destination uniquement'),
                backgroundColor: Colors.amber,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        // Lancer Google Maps
        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir Google Maps'),
              backgroundColor: Colors.red,
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune donnée de localisation disponible'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  /*sarah's new maps:*/

  @override
  Widget build(BuildContext context) {
    final geoPoint = placedata.localisation as GeoPoint?;

    final lat = geoPoint?.latitude ?? 0.0;
    final lng = geoPoint?.longitude ?? 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
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
                    final List<dynamic> images = placedata.images ?? [];

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
                        items: images.map<Widget>((image) {
                          final imagePath = image.toString().trim();

                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $imagePath');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      placedata.nom ?? 'Sans nom',
                      style: const TextStyle(
                        fontSize: 28,
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
                            placedata.wilaya ?? 'Emplacement inconnu',
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
                      placedata.description??
                          'Aucune description disponible.',
                      style: TextStyle(color: Colors.grey[800], height: 1.5),
                    ),
                    const SizedBox(height: 24),



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
                  ]
              ),
            ),
          ),
          /*sarah's new map*/
          // Dans la liste des Slivers de votre CustomScrollView
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RatingSystem(
                placeId: widget.placeId,
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: CommentSectionWithButton(placeId: widget.placeId),
          ),

          // Espace supplémentaire en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),

          /*sarah's new map*/
        ],
      ),
    );
  }
}

