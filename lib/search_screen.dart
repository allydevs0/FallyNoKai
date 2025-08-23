import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/models/anime_model.dart';
import 'package:anime/screens/anime_detail_screen.dart';
import 'package:anime/services/anime_scraper.dart';
import 'package:anime/widgets/anime_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Anime> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  late AnimeScraper _animeScraper;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animeScraper = Provider.of<AnimeScraper>(context);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _animeScraper.searchAnime(1, query, []);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load search results: \$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Anime'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter anime title...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _errorMessage != null
                  ? Expanded(
                      child: Center(
                        child: Text(_errorMessage!),
                      ),
                    )
                  : Expanded(
                      child: _searchResults.isEmpty
                          ? const Center(child: Text('No results found.'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final anime = _searchResults[index];
                                return AnimeCard(
                                  anime: anime,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AnimeDetailScreen(anime: anime),
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
