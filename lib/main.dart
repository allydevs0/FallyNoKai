import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/home_screen.dart';
import 'package:anime/services/theme_service.dart';
import 'package:anime/services/favorite_service.dart';
import 'package:anime/services/history_service.dart';
import 'package:anime/screens/favorites_screen.dart';
import 'package:anime/screens/history_screen.dart';
import 'package:anime/services/anime_scraper.dart';
import 'package:anime/services/source_selection_service.dart';
import 'package:anime/services/player_selection_service.dart';
import 'package:anime/services/anime_source.dart';
import 'package:anime/services/default_anime_scraper.dart';
import 'package:anime/services/animefire_source.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:media_kit/media_kit.dart';

final ThemeService themeService = ThemeService();
final FavoriteService favoriteService = FavoriteService();
final HistoryService historyService = HistoryService();
final AnimeScraper animeScraper = AnimeScraper(); // Global instance of the manager
final SourceSelectionService sourceSelectionService = SourceSelectionService();
final PlayerSelectionService playerSelectionService = PlayerSelectionService();

// GlobalKey for ScaffoldMessengerState
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // TEMPORARY: Clear old SharedPreferences data for debugging
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // This will clear ALL stored preferences for the app

  await themeService.init();
  await favoriteService.init();
  await historyService.init(); // This calls _loadHistory()

  // Initialize the animeScraper with the saved source
  final initialSource = await sourceSelectionService.getSelectedSource();
  animeScraper.setSource(initialSource);

  runApp(
    ChangeNotifierProvider(
      create: (_) => playerSelectionService,
      child: const MyApp(),
    ),
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
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
          ),
          home: const MainScreen(),
          scaffoldMessengerKey: scaffoldMessengerKey, // Add this line
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
      const HomePage(),
      const FavoritesScreen(),
      const HistoryScreen(),
      const SourceSelectionScreen(), // New screen for source selection
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Fonte', // Label for source selection
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // To show all items
        onTap: _onItemTapped,
      ),
    );
  }
}

class SourceSelectionScreen extends StatefulWidget {
  const SourceSelectionScreen({super.key});

  @override
  State<SourceSelectionScreen> createState() => _SourceSelectionScreenState();
}

class _SourceSelectionScreenState extends State<SourceSelectionScreen> {
  late ValueNotifier<AnimeSource> _currentSelectedSourceNotifier;

  @override
  void initState() {
    super.initState();
    _currentSelectedSourceNotifier = ValueNotifier<AnimeSource>(animeScraper.name == "Default Anime Scraper" ? DefaultAnimeScraper() : AnimeFireSource());
    _loadSelectedSource();
  }

  Future<void> _loadSelectedSource() async {
    final source = await sourceSelectionService.getSelectedSource();
    _currentSelectedSourceNotifier.value = source;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Fonte de Anime'),
      ),
      body: ValueListenableBuilder<AnimeSource>(
        valueListenable: _currentSelectedSourceNotifier,
        builder: (context, currentSource, child) {
          return ListView.builder(
            itemCount: sourceSelectionService.getAllSources().length,
            itemBuilder: (context, index) {
              final source = sourceSelectionService.getAllSources()[index];
              return ListTile(
                title: Text(source.name),
                trailing: currentSource.name == source.name
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await sourceSelectionService.setSelectedSource(source.name);
                  animeScraper.setSource(source); // Update the global scraper instance
                  _currentSelectedSourceNotifier.value = source; // Update UI
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _currentSelectedSourceNotifier.dispose();
    super.dispose();
  }
}