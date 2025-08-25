import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/services/player_selection_service.dart';
import 'package:anime/services/source_selection_service.dart';
import 'package:anime/services/anime_source.dart';
import 'package:anime/services/theme_service.dart';
import 'package:anime/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _versionTapCount = 0;
  bool _showNsfwOption = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildGeneralSection(context),
          _buildAppearanceSection(context),
          _buildAdvancedSection(context),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('General', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          _buildPlayerSelectionTile(context),
          _buildSourceSelectionTile(context),
          if (_showNsfwOption) _buildNsfwToggleTile(context),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          _buildThemeSelectionTile(context),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('Advanced', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Clear all cached data'),
            onTap: () {
              // Implement cache clearing logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {
              setState(() {
                _versionTapCount++;
                if (_versionTapCount >= 13) {
                  _showNsfwOption = true;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelectionTile(BuildContext context) {
    return Consumer<PlayerSelectionService>(
      builder: (context, playerService, child) {
        return ListTile(
          title: const Text('Video Player'),
          subtitle: Text('Selected: ${playerService.selectedPlayer == 'native' ? 'Native' : 'MPV'}'),
          trailing: DropdownButton<String>(
            value: playerService.selectedPlayer,
            onChanged: (String? newValue) {
              if (newValue != null) {
                playerService.setPlayer(newValue);
              }
            },
            items: <String>['native', 'mpv']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'native' ? 'Native Player' : 'MPV Player'),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSourceSelectionTile(BuildContext context) {
    return Consumer<SourceSelectionService>(
      builder: (context, sourceService, child) {
        return ListTile(
          title: const Text('Anime Source'),
          subtitle: Text('Selected: ${sourceService.selectedSource.name}'),
          trailing: DropdownButton<String>(
            value: sourceService.selectedSource.name,
            onChanged: (String? newValue) {
              if (newValue != null) {
                sourceService.setSelectedSource(newValue);
              }
            },
            items: sourceService.getAllSources()
                .map<DropdownMenuItem<String>>((AnimeSource source) {
              return DropdownMenuItem<String>(
                value: source.name,
                child: Text(source.name),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildNsfwToggleTile(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return SwitchListTile(
          title: const Text('Enable NSFW (18+)'),
          value: settingsService.isNsfwEnabled,
          onChanged: (bool value) {
            settingsService.isNsfwEnabled = value;
          },
        );
      },
    );
  }

  Widget _buildThemeSelectionTile(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return ListTile(
          title: const Text('Theme'),
          subtitle: Text('Selected: ${themeService.currentThemeName.value}'),
          trailing: DropdownButton<String>(
            value: themeService.currentThemeName.value,
            onChanged: (String? newValue) {
              if (newValue != null) {
                themeService.setTheme(newValue);
              }
            },
            items: themeService.availableThemes
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}