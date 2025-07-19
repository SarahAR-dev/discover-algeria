/*import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showMieuxNotes = false;
  bool _showProximite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true, // Le clavier apparaît automatiquement
          decoration: InputDecoration(
            hintText: 'Rechercher un lieu...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilterChip(
                  label: const Text('Mieux notés'),
                  selected: _showMieuxNotes,
                  onSelected: (bool value) {
                    setState(() {
                      _showMieuxNotes = value;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('À proximité'),
                  selected: _showProximite,
                  onSelected: (bool value) {
                    setState(() {
                      _showProximite = value;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),

          // Résultats de recherche
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Ici, vous ajouterez la logique pour afficher les résultats de recherche
                // Vous pouvez utiliser un StreamBuilder comme dans ExplorerScreen
                // mais avec les filtres appliqués
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/