/*import 'package:app_pfe/Screens/place_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/places_search_service.dart';
import 'explorer_screen.dart';


class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchTerm = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    Query? query = PlaceSearchService.getFilteredQuery(searchTerm, selectedCategory);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),

            //hya nrmlmn navigator.pop (lpush fl explore screen) mais n7itha psq ki ndkhol ml search screen mkch navigator.push
          ),

          title: Text(
            'Trouver un lieu !',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )

      ),


      body: Column(
        children: [
          Container(
            height:60,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 8,
            ),
            child: TextField(

              decoration:
              InputDecoration(
                filled: true, // Fills the TextField background
                fillColor: Colors.white, // Sets the background color to white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50), // Sets the border radius
                  borderSide: BorderSide.none,), // Removes the default border side
                hintText: 'Rechercher un lieu...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),

              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim();
                });
              },
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Historique',
                    selected: selectedCategory == 'historique',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'historique' ? null : 'historique';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Culturel',
                    selected: selectedCategory == 'culturel',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'culturel' ? null : 'culturel';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Naturel',
                    selected: selectedCategory == 'naturel',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'naturel' ? null : 'naturel';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Amusement',
                    selected: selectedCategory == 'amusement',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'amusement' ? null : 'amusement';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Show results or prompt depending on searchTerm
          if (searchTerm.isEmpty)
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            )
          else if (query != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aucun lieu trouve.'));
                  }
                  final places = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index].data() as Map<String, dynamic>;
                      final imageUrl = (place['images'] as List?)?.first ?? '';
                      final nom = place['nom'] ?? 'Sans nom';
                      final description = place['description'] ?? 'Sans description';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailsScreen(
                                placeId: places[index].id,
                                placeData: place,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white, // Make the card white
                          elevation: 0, // Remove shadow
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              // Image en haut
                              Container(
                                height: 170,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: (imageUrl.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                )
                                    : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                              ),

                              // Texte en dessous
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Name with flexible expansion
                                        Expanded(
                                          child: Text(
                                            nom,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Spacer between name and rating, pushing rating to the right
                                        const SizedBox(width: 12),

                                        // Rating with star icon
                                        Icon(Icons.star, color: Colors.amber[700], size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${place['rating'] ?? 0.0}',
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
                      );
                    },
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            ),
        ],
      ),
    );
  }
}  */







/*import 'package:app_pfe/Screens/place_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/places_search_service.dart';
import 'explorer_screen.dart';


class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchTerm = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    Query? query = PlaceSearchService.getFilteredQuery(searchTerm, selectedCategory);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),

            //hya nrmlmn navigator.pop (lpush fl explore screen) mais n7itha psq ki ndkhol ml search screen mkch navigator.push
          ),

          title: Text(
            'Trouver un lieu !',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )

      ),


      body: Column(
        children: [
          Container(
            height:60,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 8,
            ),
            child: TextField(

              decoration:
              InputDecoration(
                filled: true, // Fills the TextField background
                fillColor: Colors.white, // Sets the background color to white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50), // Sets the border radius
                  borderSide: BorderSide.none,), // Removes the default border side
                hintText: 'Rechercher un lieu...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),

              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim();
                });
              },
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Historique',
                    selected: selectedCategory == 'historique',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'historique' ? null : 'historique';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Culturel',
                    selected: selectedCategory == 'culturel',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'culturel' ? null : 'culturel';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Naturel',
                    selected: selectedCategory == 'naturel',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'naturel' ? null : 'naturel';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Amusement',
                    selected: selectedCategory == 'amusement',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'amusement' ? null : 'amusement';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Show results or prompt depending on searchTerm
          if (searchTerm.isEmpty)
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            )
          else if (query != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aucun lieu trouve.'));
                  }
                  final places = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index].data() as Map<String, dynamic>;
                      final imageUrl = (place['images'] as List?)?.first ?? '';
                      final nom = place['nom'] ?? 'Sans nom';
                      final description = place['description'] ?? 'Sans description';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailsScreen(
                                placeId: places[index].id,
                                placeData: place,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white, // Make the card white
                          elevation: 0, // Remove shadow
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              // Image en haut
                              Container(
                                height: 170,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: (imageUrl.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                )
                                    : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                              ),

                              // Texte en dessous
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Name with flexible expansion
                                        Expanded(
                                          child: Text(
                                            nom,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Spacer between name and rating, pushing rating to the right
                                        const SizedBox(width: 12),

                                        // Rating with star icon
                                        Icon(Icons.star, color: Colors.amber[700], size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${place['rating'] ?? 0.0}',
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
                      );
                    },
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.green.shade50,
      selectedColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
*/




/*import 'package:app_pfe/Screens/place_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/places_search_service.dart';
import 'explorer_screen.dart';


class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchTerm = '';
  String? selectedCategory;
  String? selectedtag;
  @override
  Widget build(BuildContext context) {
    Query? query = PlaceSearchService.getFilteredQuery(searchTerm, selectedCategory);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),

            //hya nrmlmn navigator.pop (lpush fl explore screen) mais n7itha psq ki ndkhol ml search screen mkch navigator.push
          ),

          title: Text(
            'Trouver un lieu !',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )
      ),


      body: Column(
        children: [
          Container(
            height:60,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 8,
            ),
            child: TextField(

              decoration:
              InputDecoration(
                filled: true, // Fills the TextField background
                fillColor: Colors.white, // Sets the background color to white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50), // Sets the border radius
                  borderSide: BorderSide.none,), // Removes the default border side
                hintText: 'Rechercher un lieu...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),

              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim();
                });
              },
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne des catégories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Historique',
                        selected: selectedCategory == 'historique',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'historique' ? null : 'historique';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Culturel',
                        selected: selectedCategory == 'culturel',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'culturel' ? null : 'culturel';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Naturel',
                        selected: selectedCategory == 'naturel',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'naturel' ? null : 'naturel';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Amusement',
                        selected: selectedCategory == 'amusement',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'amusement' ? null : 'amusement';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 12), // Espacement entre les deux lignes

                /* // Ligne des directions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'NORD',
                      selected: selectedtag == 'nord',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'nord' ? null : 'nord';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'EST',
                      selected: selectedtag == 'est',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'est' ? null : 'est';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'SUD',
                      selected: selectedtag == 'sud',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'sud' ? null : 'sud';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'OUEST',
                      selected: selectedtag == 'ouest',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'ouest' ? null : 'ouest';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),*/
              ],
            ),),

          // Show results or prompt depending on searchTerm
          if (searchTerm.isEmpty)
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            )
          else if (query != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aucun lieu trouve.'));
                  }
                  final places = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index].data() as Map<String, dynamic>;
                      final imageUrl = (place['images'] as List?)?.first ?? '';
                      final nom = place['nom'] ?? 'Sans nom';
                      final description = place['description'] ?? 'Sans description';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailsScreen(
                                placeId: places[index].id,

                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white, // Make the card white
                          elevation: 0, // Remove shadow
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              // Image en haut
                              Container(
                                height: 170,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: (imageUrl.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                )
                                    : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                              ),

                              // Texte en dessous
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Name with flexible expansion
                                        Expanded(
                                          child: Text(
                                            nom,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Spacer between name and rating, pushing rating to the right
                                        const SizedBox(width: 12),

                                        // Rating with star icon
                                        Icon(Icons.star, color: Colors.amber[700], size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${place['rating'] ?? 0.0}',
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
                      );
                    },
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            ),
        ],
      ),
    );
  }


}

class FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.green.shade50,
      selectedColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}

/*class FiltertagButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FiltertagButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.blueGrey.shade50,
      selectedColor: Colors.blueGrey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }}*/

*/










/*
import 'package:app_pfe/Screens/place_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/places_search_service.dart';
import 'explorer_screen.dart';


class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchTerm = '';
  String? selectedCategory;
  String? selectedtag;
  @override
  Widget build(BuildContext context) {
    Query? query = PlaceSearchService.getFilteredQuery(searchTerm, selectedCategory);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),

            //hya nrmlmn navigator.pop (lpush fl explore screen) mais n7itha psq ki ndkhol ml search screen mkch navigator.push
          ),

          title: Text(
            'Trouver un lieu !',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )
      ),


      body: Column(
        children: [
          Container(
            height:60,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 8,
            ),
            child: TextField(

              decoration:
              InputDecoration(
                filled: true, // Fills the TextField background
                fillColor: Colors.white, // Sets the background color to white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50), // Sets the border radius
                  borderSide: BorderSide.none,), // Removes the default border side
                hintText: 'Rechercher un lieu...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),

              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim();
                });
              },
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne des catégories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Historique',
                        selected: selectedCategory == 'historique',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'historique' ? null : 'historique';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Culturel',
                        selected: selectedCategory == 'culturel',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'culturel' ? null : 'culturel';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Naturel',
                        selected: selectedCategory == 'naturel',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'naturel' ? null : 'naturel';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterButton(
                        label: 'Amusement',
                        selected: selectedCategory == 'amusement',
                        onTap: () {
                          setState(() {
                            selectedCategory = selectedCategory == 'amusement' ? null : 'amusement';
                            selectedtag = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 12), // Espacement entre les deux lignes

                /* // Ligne des directions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'NORD',
                      selected: selectedtag == 'nord',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'nord' ? null : 'nord';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'EST',
                      selected: selectedtag == 'est',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'est' ? null : 'est';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'SUD',
                      selected: selectedtag == 'sud',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'sud' ? null : 'sud';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FiltertagButton(
                      label: 'OUEST',
                      selected: selectedtag == 'ouest',
                      onTap: () {
                        setState(() {
                          selectedtag = selectedtag == 'ouest' ? null : 'ouest';
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),*/
              ],
            ),),

          // Show results or prompt depending on searchTerm
          if (searchTerm.isEmpty)
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            )
          else if (query != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aucun lieu trouve.'));
                  }
                  final places = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index].data() as Map<String, dynamic>;
                      final imageUrl = (place['images'] as List?)?.first ?? '';
                      final nom = place['nom'] ?? 'Sans nom';
                      final description = place['description'] ?? 'Sans description';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailsScreen(
                                placeId: places[index].id,

                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white, // Make the card white
                          elevation: 0, // Remove shadow
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              // Image en haut
                              Container(
                                height: 170,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: (imageUrl.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                )
                                    : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                              ),

                              // Texte en dessous
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Name with flexible expansion
                                        Expanded(
                                          child: Text(
                                            nom,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Spacer between name and rating, pushing rating to the right
                                        const SizedBox(width: 12),

                                        // Rating with star icon
                                        Icon(Icons.star, color: Colors.amber[700], size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${place['rating'] ?? 0.0}',
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
                      );
                    },
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            ),
        ],
      ),
    );
  }


}

class FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.green.shade50,
      selectedColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}

/*class FiltertagButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FiltertagButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.blueGrey.shade50,
      selectedColor: Colors.blueGrey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }}*/

*/





import 'package:app_pfe/Screens/explorer_screen.dart';
import 'package:app_pfe/Screens/place_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../services/places.dart';
import 'package:cached_network_image/cached_network_image.dart';


class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key});

  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchTerm = '';
  String? selectedCategory;
  List<Place> searchResults = [];
  bool isLoading = false;
  String? errorMessage;


  Stream<List<Place>> get query =>
      SearchService.searchPlaces(searchTerm, selectedCategory);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => ExplorerScreen(),
        ),
        title: Text(
          'Trouver un lieu !',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Rechercher un lieu...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim();
                });
              },
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  for (final category in ['historique', 'culturel', 'naturel', 'amusement'])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = selectedCategory == category ? null : category;
                          });
                        },
                        backgroundColor: Colors.green.shade50,
                        selectedColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          if (searchTerm.isEmpty)
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            )
          else
            Expanded(
              child: StreamBuilder<List<Place>>(
                stream: query,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucun lieu trouve.'));
                  }
                  final searchResults=snapshot.data!;
                  return ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index){
                      final place = searchResults[index];
                      final imageUrl = place.images.isNotEmpty ? place.images.first : '';

                      return InkWell(
                        onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaceDetailsScreen(placeId: place.id),
                              ),
                            ),
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              Container(
                                height: 170,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: imageUrl.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:/* Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 40, color: Colors.grey),
                                ),*/
                                  CachedNetworkImage(
                                    imageUrl: place.images[0],
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(Icons.broken_image),
                                    fit: BoxFit.cover,
                                  ),

                                )
                                    : const Center(child: Icon(
                                    Icons.image, size: 40, color: Colors.grey)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child:
                                      Text(
                                        place.nom,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.star, color: Colors.amber[700], size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${place.rating}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
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
              ),
            ),
        ],
      ),
    );
  }
}