import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'place_details_screen.dart';
import 'search_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({Key? key}) : super(key: key);

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  bool _isSearchFocused = false;
  String _selectedFilter = 'Tous';
  final List<Map<String, dynamic>> _filters = [
    {'name': 'Tous', 'icon': Icons.apps},
    {'name': 'Populaire', 'icon': Icons.star},
    {'name': 'Historique', 'icon': Icons.history_edu},
    {'name': 'Nature', 'icon': Icons.landscape},
    {'name': 'Culture', 'icon': Icons.museum},
  ];

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
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
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
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                      size: 20,
                    ),
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
                                width: MediaQuery.of(context).size.width,
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
            // Supprimez le "bottom: PreferredSize" car nous n'en avons plus besoin
          ),

          // Liste des lieux
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('places').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Erreur: ${snapshot.error}')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              var places = snapshot.data!.docs;

              // Filtrage
              if (_selectedFilter != 'Tous') {
                places =
                    places.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      switch (_selectedFilter) {
                        case 'Populaire':
                          return (data['rating'] ?? 0) >= 4.0;
                        case 'Historique':
                          return data['category'] == 'Historique';
                        case 'Nature':
                          return data['category'] == 'Nature';
                        case 'Culture':
                          return data['category'] == 'Culture';
                        default:
                          return true;
                      }
                    }).toList();
              }

              if (places.isEmpty) {
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

              /*return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final doc = places[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                placeId: doc.id,
                                placeData: data,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Builder(
                                  builder: (context) {
                                    final images = data['images'] as List;
                                    final firstImage = images.first.toString();

                                    return Image.asset(
                                      'assets/images/$firstImage',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Image non disponible',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['name'] ?? 'Sans nom',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${data['rating'] ?? 0.0}',
                                              style: TextStyle(
                                                color: Theme.of(context).primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['location'] ?? 'Emplacement inconnu',
                                        style: TextStyle(
                                          color: Colors.grey[600],
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
                  childCount: places.length,
                ),
              ); */

              // sous forme de grille

              /*return SliverToBoxAdapter(

                child: SizedBox(
                  height: 320, // Hauteur de chaque carte
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // 👉 Scroll horizontal
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final doc = places[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return SizedBox(
                        width: 260, // 👉 Largeur de la carte
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                                    placeId: doc.id,
                                    placeData: data,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                SizedBox(
                                  height: 160,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Builder(
                                      builder: (context) {
                                        final images = data['images'] as List;
                                        final firstImage = images.first.toString();

                                        return Image.asset(
                                          'assets/images/$firstImage',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(Icons.image_not_supported, size: 40),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // Texte
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? 'Sans nom',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                              data['location'] ?? 'Emplacement inconnu',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 14, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${data['rating'] ?? 0.0}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
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
              );*/

              /*return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Titre
                    /*Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Text(
                        'Visitez le desert du Sahara',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),*/








                    // ✅ Liste horizontale
                   SizedBox(
                      height: 320,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final doc = places[index];
                          final data = doc.data() as Map<String, dynamic>;

                          // 🔒 Sécurité pour l’image
                          final List images = (data['images'] ?? []);
                          final String firstImage =
                          images.isNotEmpty ? images.first.toString() : '';

                          return SizedBox(
                            width: 260,
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                                        placeId: doc.id,
                                        placeData: data,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ✅ Image
                                    SizedBox(
                                      height: 160,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: firstImage.isNotEmpty
                                            ? Image.asset(
                                          'assets/images/$firstImage',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(Icons.broken_image, size: 40),
                                              ),
                                            );
                                          },
                                        )
                                            : Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.image, size: 40),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ✅ Texte descriptif
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ?? 'Sans nom',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                                  data['location'] ?? 'Emplacement inconnu',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.star, size: 14, color: Colors.orange),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${data['rating'] ?? 0.0}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
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
              );*/

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Liste horizontale
                    for (
                      var i = 0;
                      i < (places.length / 6).ceil();
                      i++
                    ) // Divise en groupes de 6
                      SizedBox(
                        height: 320,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            // Si l'index ne fait pas partie de ce groupe de 6, retourne un container vide
                            if (index < i * 6 || index >= (i + 1) * 6) {
                              return const SizedBox.shrink();
                            }

                            final doc = places[index];
                            final data = doc.data() as Map<String, dynamic>;

                            // 🔒 Sécurité pour l'image
                            final List images = (data['images'] ?? []);
                            final String firstImage =
                                images.isNotEmpty
                                    ? images.first.toString()
                                    : '';

                            return SizedBox(
                              width: 260,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 16,
                                ),
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PlaceDetailsScreen(
                                              placeId: doc.id,
                                              placeData: data,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ✅ Image
                                      SizedBox(
                                        height: 160,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              firstImage.isNotEmpty
                                                  ? Image.asset(
                                                    'assets/images/$firstImage',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: Colors.grey[200],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            size: 40,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                  : Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 40,
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                      ),

                                      // ✅ Texte descriptif
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['name'] ?? 'Sans nom',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    data['location'] ??
                                                        'Emplacement inconnu',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${data['rating'] ?? 0.0}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
