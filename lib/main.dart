import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/screens/continue_watching_screen.dart';
import 'package:anime/screens/history_screen.dart';
import 'package:anime/screens/home_screen.dart';
import 'package:anime/screens/favorites_screen.dart';
import 'package:anime/screens/settings_screen.dart';
import 'package:anime/screens/splash_screen.dart';
import 'package:anime/services/favorite_service.dart';
import 'package:anime/services/history_service.dart';
import 'package:anime/services/player_selection_service.dart';
import 'package:anime/services/source_selection_service.dart';
import 'package:anime/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import 'package:anime/services/anime_scraper.dart';

// Serviços globais
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
    return const CupertinoApp(
      title: 'Anime Scraper',
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemBlue,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.white,
          textStyle: TextStyle(color: CupertinoColors.white),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.play_circle_fill),
            label: 'Continuar',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_fill),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.time_solid),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings_solid),
            label: 'Mais',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: ContinueWatchingScreen(),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: HomeScreen(),
              );
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: FavoritesScreen(),
              );
            });
          case 3:
            return CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: HistoryScreen(),
              );
            });
          case 4:
            return CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: SettingsScreen(),
              );
            });
          default:
            return CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: HomeScreen(),
              );
            });
        }
      },
    );
  }
}