import 'package:anime/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime/services/anime_scraper.dart';
import 'package:anime/models/anime_model.dart';
import 'package:anime/main.dart' as main_app;
import 'package:anime/screens/anime_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScaffoldMessengerState _scaffoldMessenger;

  final AnimeScraper animeScraper = AnimeScraper();
  final TextEditingController searchController = TextEditingController();

  List<Anime> searchResults = [];
  bool isLoadingSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializa a referência segura ao ScaffoldMessenger
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<void> searchAnime() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isLoadingSearch = false;
      });
      return;
    }

    setState(() => isLoadingSearch = true);

    try {
      final results = await animeScraper.searchAnime(1, query, []);
      if (!mounted) return;
      setState(() {
        searchResults = results;
        isLoadingSearch = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        searchResults = [];
        isLoadingSearch = false;
      });
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Erro ao buscar animes: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: main_app.themeService.themeMode,
            builder: (context, themeMode, child) => Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => main_app.themeService.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Buscar anime no AnimeFire.plus",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: searchAnime,
                  ),
                ),
                onSubmitted: (_) => searchAnime(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  searchController.text = "naruto";
                  searchAnime();
                },
                child: const Text("🧪 Testar pesquisa (Naruto)"),
              ),
              const SizedBox(height: 20),
              Text(
                  "Debug - isLoadingSearch: $isLoadingSearch, searchResults: ${searchResults.length}"),
              const SizedBox(height: 10),
              if (isLoadingSearch)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Buscando animes..."),
                  ],
                )
              else if (searchResults.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Resultados encontrados: ${searchResults.length}",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final anime = searchResults[index];
                          return ListTile(
                            title: Text(anime.title),
                            subtitle: Text("URL: ${anime.url}"),
                            leading: anime.thumbnailUrl?.isNotEmpty == true
                                ? Image.network(anime.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 50),
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
                )
              else
                const Text("Pesquise por um anime no AniList."),
            ],
          ),
        ),
      ),
    );
  }
}