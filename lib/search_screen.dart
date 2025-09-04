import 'package:flutter/cupertino.dart';
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
        _errorMessage = 'Failed to load search results: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search Anime'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      onSubmitted: _performSearch,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => _performSearch(_searchController.text),
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Expanded(child: Center(child: CupertinoActivityIndicator()))
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
                                        CupertinoPageRoute(
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
      ),
    );
  }
}