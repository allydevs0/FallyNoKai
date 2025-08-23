import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_selection_service.dart';
import '../services/source_selection_service.dart'; // Import SourceSelectionService
import '../services/anime_source.dart'; // Added import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildPlayerSelectionTile(context),
          _buildSourceSelectionTile(context), // Add source selection tile
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
    final sourceService = SourceSelectionService();
    return FutureBuilder<List<AnimeSource>>(
      future: Future.value(sourceService.getAllSources()), // Use Future.value for immediate list
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Anime Source'),
            subtitle: Text('Loading sources...'),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: const Text('Anime Source'),
            subtitle: Text('Error loading sources: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const ListTile(
            title: Text('Anime Source'),
            subtitle: Text('No sources available.'),
          );
        } else {
          return FutureBuilder<AnimeSource>(
            future: sourceService.getSelectedSource(),
            builder: (context, selectedSourceSnapshot) {
              String? currentSourceName = selectedSourceSnapshot.data?.name;
              return ListTile(
                title: const Text('Anime Source'),
                subtitle: Text('Selected: ${currentSourceName ?? 'Loading...'}'),
                trailing: DropdownButton<String>(
                  value: currentSourceName,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      sourceService.setSelectedSource(newValue);
                      // Optionally, you might want to notify listeners or rebuild parts of the UI
                      // that depend on the selected source. This might require making
                      // SourceSelectionService a ChangeNotifier or using a different state management.
                    }
                  },
                  items: snapshot.data!
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
      },
    );
  }
}