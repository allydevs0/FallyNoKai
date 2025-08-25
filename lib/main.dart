import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/screens/history_screen.dart';
import 'package:anime/screens/home_screen.dart';
import 'package:anime/screens/favorites_screen.dart';
import 'package:anime/screens/settings_screen.dart';
import 'package:anime/screens/splash_screen.dart';
import 'package:anime/services/theme_service.dart';
import 'package:anime/services/favorite_service.dart';
import 'package:anime/services/history_service.dart';
import 'package:anime/services/player_selection_service.dart';
import 'package:anime/services/source_selection_service.dart';
import 'package:anime/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import 'package:anime/services/anime_scraper.dart';

// Serviços globais
final ThemeService themeService = ThemeService();
final FavoriteService favoriteService = FavoriteService();
final HistoryService historyService = HistoryService();
final PlayerSelectionService playerSelectionService = PlayerSelectionService();
final SourceSelectionService sourceSelectionService = SourceSelectionService();
final SettingsService settingsService = SettingsService();

// GlobalKey para Snackbar
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final AnimeScraper animeScraper = AnimeScraper();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await themeService.init();
  await favoriteService.init();
  await historyService.init();
  await settingsService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => playerSelectionService),
        Provider<FavoriteService>.value(value: favoriteService),
        Provider<HistoryService>.value(value: historyService),
        Provider<AnimeScraper>.value(value: animeScraper),
        Provider<ThemeService>.value(value: themeService),
        ChangeNotifierProvider(create: (_) => sourceSelectionService),
        ChangeNotifierProvider(create: (_) => settingsService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: themeService.currentThemeName,
      builder: (context, themeName, child) {
        return MaterialApp(
          title: 'Anime Scraper',
          theme: themeService.currentThemeData,
          home: const SplashScreen(),
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
      const HistoryScreen(),
      const SettingsScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Explorar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Mais'),
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
