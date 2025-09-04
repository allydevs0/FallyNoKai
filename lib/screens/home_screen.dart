import 'package:flutter/cupertino.dart';
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
      // Show a Cupertino dialog for the error
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load popular anime: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load latest updates: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load trending anime: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
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
              ? const Center(child: CupertinoActivityIndicator())
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
                              CupertinoPageRoute(
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('AnimesKai'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
                context, CupertinoPageRoute(builder: (_) => const SearchScreen()));
          },
          child: const Icon(CupertinoIcons.search),
        ),
      ),
      child: ListView(
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