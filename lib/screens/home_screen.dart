import 'package:flutter/material.dart';
import 'package:anime/search_screen.dart';
import 'package:anime/services/anilist_service.dart';
import 'package:anime/models/anime_model.dart';
import 'package:anime/screens/anime_detail_screen.dart';
import 'package:anime/widgets/anime_card.dart';
import 'package:anime/screens/settings_screen.dart'; // Added import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Tudo';
  List<Anime> _trendingAnime = [];
  bool _isLoadingTrending = true;
  bool _isCarousel = false; // alterna entre lista e carrossel

  final AniListService _anilistService = AniListService();
  final PageController _carouselController = PageController(viewportFraction: 0.7);
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchTrendingAnime();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _listController.dispose();
    super.dispose();
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
        SnackBar(content: Text('Erro ao carregar animes em alta: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildCategoryButton(String title) {
    final isSelected = _selectedCategory == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: () => setState(() => _selectedCategory = title),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(title),
      ),
    );
  }

  // navega no carrossel
  void _pageShift(int direction) {
    if (_trendingAnime.length < 2 || !_carouselController.hasClients) return;
    final current = _carouselController.page ?? 0.0;
    int target = (current + direction).round();
    if (target < 0) target = 0;
    if (target > _trendingAnime.length - 1) target = _trendingAnime.length - 1;
    _carouselController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // rola a lista horizontal
  void _scrollList(int direction) {
    if (!_listController.hasClients) return;
    final viewport = MediaQuery.of(context).size.width;
    final delta = viewport * 0.7 * direction; // “pula” ~70% da tela
    final max = _listController.position.maxScrollExtent;
    final target = (_listController.offset + delta).clamp(0.0, max);
    _listController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildArrow({
    required Alignment alignment,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.black.withOpacity(0.25),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Center(child: Icon(Icons.chevron_right, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFades(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return IgnorePointer(
      ignoring: true,
      child: Row(
        children: [
          Container(
            width: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [bg, bg.withOpacity(0.0)],
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [bg, bg.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeStrip() {
    if (_isLoadingTrending) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_trendingAnime.isEmpty) {
      return const Center(child: Text('Nada encontrado'));
    }

    final content = _isCarousel
        ? PageView.builder(
            controller: _carouselController,
            itemCount: _trendingAnime.length,
            itemBuilder: (context, index) {
              final anime = _trendingAnime[index];
              return AnimatedBuilder(
                animation: _carouselController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_carouselController.position.haveDimensions) {
                    value = (_carouselController.page ?? 0) - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                  }
                  final scale = Curves.easeOut.transform(value);
                  return Center(
                    child: SizedBox(
                      height: 220 * scale,
                      width: 140 * scale,
                      child: child,
                    ),
                  );
                },
                child: AnimeCard(
                  anime: anime,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnimeDetailScreen(anime: anime)),
                    );
                  },
                ),
              );
            },
          )
        : ListView.builder(
            controller: _listController,
            scrollDirection: Axis.horizontal,
            itemCount: _trendingAnime.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final anime = _trendingAnime[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimeCard(
                  anime: anime,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnimeDetailScreen(anime: anime)),
                    );
                  },
                ),
              );
            },
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        content,
        _buildFades(context),
        // setas esquerda/direita
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: _ArrowButton(
              icon: Icons.chevron_left,
              onTap: () => _isCarousel ? _pageShift(-1) : _scrollList(-1),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: _ArrowButton(
              icon: Icons.chevron_right,
              onTap: () => _isCarousel ? _pageShift(1) : _scrollList(1),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimesKai', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: perfil
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // categorias
/*           Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  _buildCategoryButton('Tudo'),
                  _buildCategoryButton('Streaming'),
                  _buildCategoryButton('Lançamentos'),
                  _buildCategoryButton('Calendário'),
                  _buildCategoryButton('Gêneros'),
                  _buildCategoryButton('Temporadas'),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
 */
          // título + toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Top Animes em Alta', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: Icon(_isCarousel ? Icons.view_list : Icons.view_carousel),
                  tooltip: _isCarousel ? 'Ver como lista' : 'Ver como carrossel',
                  onPressed: () => setState(() => _isCarousel = !_isCarousel),
                ),
              ],
            ),
          ),

          // faixa de animes com setas
          SizedBox(height: 260, child: _buildAnimeStrip()),
        ],
      ),
    );
  }
}

/// Botão redondo reutilizável para as setas
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
