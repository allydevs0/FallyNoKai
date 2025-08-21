import 'package:flutter/material.dart';
import 'package:anime/services/anime_scraper.dart';
import 'package:anime/models/anime_model.dart';
import 'package:anime/models/episode_model.dart';
import 'package:anime/main.dart'; // animeScraper, themeService, favoriteService, historyService
import 'package:anime/video_player_screen.dart'; // VideoPlayerScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  List<Anime> searchResults = [];
  List<Episode> scrapedEpisodes = [];
  bool isLoadingSearch = false;
  bool isLoadingEpisodes = false;

  Anime? selectedAnime;

  Future<void> searchAnime() async {
    setState(() => isLoadingSearch = true);
    final query = searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isLoadingSearch = false;
      });
      return;
    }

    try {
      final results = await animeScraper.searchAnime(1, query, []);
      setState(() {
        searchResults = results;
        selectedAnime = null;
        scrapedEpisodes = [];
      });
    } catch (e) {
      print("Erro ao buscar animes: $e");
      setState(() => searchResults = []);
    } finally {
      if (mounted) setState(() => isLoadingSearch = false);
    }
  }

  Future<void> fetchScrapedEpisodes(String animeUrl) async {
    setState(() => isLoadingEpisodes = true);
    try {
      final episodes = await animeScraper.fetchEpisodeList(animeUrl);
      setState(() => scrapedEpisodes = episodes);
    } catch (e) {
      print("Erro ao raspar episódios: $e");
      setState(() => scrapedEpisodes = []);
    } finally {
      if (mounted) setState(() => isLoadingEpisodes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime App'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeService.themeMode,
            builder: (context, themeMode, child) {
              return Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) => themeService.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Buscar anime",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchAnime,
                ),
              ),
              onSubmitted: (_) => searchAnime(),
            ),
            const SizedBox(height: 20),
            if (isLoadingSearch)
              const CircularProgressIndicator()
            else if (searchResults.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final anime = searchResults[index];
                    return ListTile(
                      title: Text(anime.title),
                      onTap: () async {
                        setState(() {
                          isLoadingSearch = true;
                          selectedAnime = null;
                          searchResults = [];
                        });

                        try {
                          final animeDetails =
                              await animeScraper.fetchAnimeDetails(anime.url);
                          if (mounted) setState(() => selectedAnime = animeDetails);
                          historyService.addAnimeToHistory(animeDetails);
                          fetchScrapedEpisodes(animeDetails.url);
                        } catch (e) {
                          print("Erro ao obter detalhes do anime: $e");
                        } finally {
                          if (mounted) setState(() => isLoadingSearch = false);
                        }
                      },
                    );
                  },
                ),
              )
            ] else if (selectedAnime != null) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedAnime!.title,
                                style: Theme.of(context).textTheme.headlineSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              ValueListenableBuilder<List<Anime>>(
                                valueListenable: favoriteService.favorites,
                                builder: (context, favorites, child) {
                                  final isFav = favoriteService.isFavorite(selectedAnime!);
                                  return IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : null,
                                    ),
                                    onPressed: () =>
                                        favoriteService.toggleFavorite(selectedAnime!),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          selectedAnime!.description ?? "Nenhuma descrição disponível.",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isLoadingEpisodes)
                      const CircularProgressIndicator()
                    else if (scrapedEpisodes.isNotEmpty) ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: scrapedEpisodes.length,
                          itemBuilder: (context, index) {
                            final episode = scrapedEpisodes[index];
                            return ListTile(
                              title: Text(episode.title),
                              subtitle: Text("Episódio ${episode.episodeNumber}"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerScreen(
                                      animeUrl: selectedAnime!.url,
                                      currentEpisodeUrl: episode.url,
                                      title: episode.title,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    ] else ...[
                      const Text("Nenhum episódio encontrado para este anime."),
                    ],
                  ],
                ),
              )
            ] else ...[
              const Text("Pesquise por um anime."),
            ],
          ],
        ),
      ),
    );
  }
}
