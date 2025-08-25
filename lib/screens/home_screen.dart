import 'package:flutter/material.dart';
import 'package:anime/search_screen.dart';
import 'package:anime/services/anilist_service.dart';
import 'package:anime/models/anime_model.dart';
import 'package:anime/screens/anime_detail_screen.dart';
import 'package:anime/widgets/anime_card.dart';
import 'package:anime/screens/settings_screen.dart'; // Added import
import 'package:provider/provider.dart';
import 'package:anime/services/anime_scraper.dart';
import 'package:anime/services/settings_service.dart';
import 'package:anime/screens/category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Anime> _trendingAnime = [];
  bool _isLoadingTrending = true;
  List<Anime> _popularAnime = [];
  bool _isLoadingPopular = true;
  List<Anime> _latestUpdates = [];
  bool _isLoadingLatest = true;

  late final AniListService _anilistService;

  @override
  void initState() {
    super.initState();
    _anilistService =
        AniListService(Provider.of<SettingsService>(context, listen: false));
    _fetchTrendingAnime();
    _fetchPopularAnime();
    _fetchLatestUpdates();
  }

  Future<void> _fetchPopularAnime() async {
    try {
      final animeList = await _anilistService.getPopularAnime();
      if (mounted) {
        setState(() {
          _popularAnime = animeList;
          _isLoadingPopular = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPopular = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar animes populares: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _fetchLatestUpdates() async {
    try {
      final animeList = await _anilistService.getLatestUpdates();
      if (mounted) {
        setState(() {
          _latestUpdates = animeList;
          _isLoadingLatest = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLatest = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar atualizações recentes: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _fetchTrendingAnime() async {
    try {
      final animeList = await _anilistService.getTrendingAnime();
      setState(() {
        _trendingAnime = animeList;
        _isLoadingTrending = false;
      });
    } catch (e) {
      setState(() => _isLoadingTrending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar animes em alta: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildAnimeSection(
      String title, List<Anime> animeList, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            CategoryScreen(title: title, animeList: animeList)),
                  );
                },
                child: const Text('See More'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: animeList.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final anime = animeList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: 160,
                        child: AnimeCard(
                          anime: anime,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AnimeDetailScreen(anime: anime)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimesKai',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SearchScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildAnimeSection(
              'Top Animes em Alta', _trendingAnime, _isLoadingTrending),
          _buildAnimeSection('Populares', _popularAnime, _isLoadingPopular),
          _buildAnimeSection(
              'Últimas Atualizações', _latestUpdates, _isLoadingLatest),
        ],
      ),
    );
  }
}
