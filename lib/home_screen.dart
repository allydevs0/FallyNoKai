import 'package:flutter/material.dart';
import 'package:anime/services/anime_scraper.dart';
import 'package:anime/services/api_service.dart';
import 'package:anime/models/anime_model.dart';
import 'package:anime/main.dart'; // Import themeService, favoriteService, historyService

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AnimeScraper animeScraper = AnimeScraper();
  final ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  List<Anime> aniListResults = [];
  List<Map<String, String>> scrapedEpisodes = [];
  bool isLoadingAniList = false;
  bool isLoadingScrapedEpisodes = false;

  Anime? selectedAnime; // To store the selected AniList anime

  Future<void> searchAniList() async {
    setState(() => isLoadingAniList = true);
    final query = searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        aniListResults = [];
        isLoadingAniList = false;
      });
      return;
    }

    try {
      final results = await apiService.searchAniListAnime(query);
      setState(() {
        aniListResults = results;
        selectedAnime = null; // Clear selected anime when new search
        scrapedEpisodes = []; // Clear scraped episodes
      });
    } catch (e) {
      print("Erro ao buscar no AniList: $e");
      setState(() => aniListResults = []);
    } finally {
      setState(() => isLoadingAniList = false);
    }
  }

  Future<void> fetchScrapedEpisodes(String animeTitle) async {
    setState(() => isLoadingScrapedEpisodes = true);
    try {
      // For now, we'll use the anime title from AniList to search on AnimeFire.plus
      // This might need refinement if AnimeFire.plus has different titles or URLs
      final searchResults = await animeScraper.searchAnime(animeTitle);
      if (searchResults.isNotEmpty) {
        // Assuming the first result is the correct one for now
        final animeUrl = searchResults.first['url']!;
        final episodes = await animeScraper.getEpisodes(animeUrl);
        setState(() => scrapedEpisodes = episodes);
      } else {
        setState(() => scrapedEpisodes = []);
        print("Nenhum resultado encontrado no AnimeFire.plus para: $animeTitle");
      }
    } catch (e) {
      print("Erro ao raspar episódios: $e");
      setState(() => scrapedEpisodes = []);
    } finally {
      setState(() => isLoadingScrapedEpisodes = false);
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
                onChanged: (value) {
                  themeService.toggleTheme();
                },
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
                labelText: "Buscar anime no AniList",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchAniList,
                ),
              ),
              onSubmitted: (_) => searchAniList(),
            ),
            const SizedBox(height: 20),
            if (isLoadingAniList)
              const CircularProgressIndicator()
            else if (aniListResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: aniListResults.length,
                  itemBuilder: (context, index) {
                    final anime = aniListResults[index];
                    return ListTile(
                      leading: anime.imageUrl.isNotEmpty
                          ? Image.network(anime.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : null,
                      title: Text(anime.title),
                      subtitle: Text(anime.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')), // Remove HTML tags
                      trailing: ValueListenableBuilder<List<Anime>>(
                        valueListenable: favoriteService.favorites,
                        builder: (context, favorites, child) {
                          final isFav = favoriteService.isFavorite(anime);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : null,
                            ),
                            onPressed: () {
                              favoriteService.toggleFavorite(anime);
                            },
                          );
                        },
                      ),
                      onTap: () {
                        setState(() {
                          selectedAnime = anime;
                          aniListResults = []; // Clear search results
                        });
                        historyService.addAnimeToHistory(anime); // Add to history
                        fetchScrapedEpisodes(anime.title);
                      },
                    );
                  },
                ),
              )
            else if (selectedAnime != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAnime!.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  if (isLoadingScrapedEpisodes)
                    const CircularProgressIndicator()
                  else if (scrapedEpisodes.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6, // Limit height for episodes list
                      child: ListView.builder(
                        itemCount: scrapedEpisodes.length,
                        itemBuilder: (context, index) {
                          final episode = scrapedEpisodes[index];
                          return ListTile(
                            title: Text(episode["title"] ?? "Episódio sem título"),
                            subtitle: Text(episode["url"] ?? "URL não disponível"),
                            onTap: () {
                              // TODO: Implement episode playback or download
                              print("Tapped on episode: ${episode["url"]}");
                            },
                          );
                        },
                      ),
                    )
                  else
                    const Text("Nenhum episódio encontrado para este anime no AnimeFire.plus."),
                ],
              )
            else
              const Text("Pesquise por um anime no AniList."),
          ],
        ),
      ),
    );
  }
}
