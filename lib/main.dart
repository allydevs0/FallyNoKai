import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/screens/history_screen.dart';
import 'package:anime/screens/home_screen.dart';
import 'package:anime/screens/favorites_screen.dart';
import 'package:anime/services/theme_service.dart';
import 'package:anime/services/favorite_service.dart';
import 'package:anime/services/history_service.dart';
import 'package:anime/services/player_selection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import 'package:anime/services/anime_scraper.dart';

// Serviços globais
final ThemeService themeService = ThemeService();
final FavoriteService favoriteService = FavoriteService();
final HistoryService historyService = HistoryService();
final PlayerSelectionService playerSelectionService = PlayerSelectionService();

// GlobalKey para Snackbar
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final AnimeScraper animeScraper = AnimeScraper();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await themeService.init();
  await favoriteService.init();
  await historyService.init();

  runApp(
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => playerSelectionService),
    Provider<FavoriteService>.value(value: favoriteService),
    Provider<HistoryService>.value(value: historyService),
    Provider<AnimeScraper>.value(value: animeScraper), // <- agora funciona
  ],
  child: const MyApp(),
)



,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeService.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Anime Scraper',
          themeMode: themeMode,
          theme: ThemeData.light().copyWith(primaryColor: Colors.blue),
          darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.blue),
          home: const MainScreen(),
          scaffoldMessengerKey: scaffoldMessengerKey,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(),
      const FavoritesScreen(),
      const HistoryScreen(historyEpisodes: []),
      // Placeholder enquanto a tela de Histórico não é implementada
      Center(child: Text('Histórico ainda não implementado')),
      // Placeholder para a tela de Mais..
      Center(child: Text('Mais.. ainda não implementado')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Mais..'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
