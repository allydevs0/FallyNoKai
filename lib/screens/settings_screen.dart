import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/services/player_selection_service.dart';
import 'package:anime/services/source_selection_service.dart';
import 'package:anime/services/anime_source.dart';
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: ListView(
        children: [
          CupertinoListSection(
            header: const Text('General'),
            children: [
              _buildPlayerSelectionTile(context),
              _buildSourceSelectionTile(context),
              if (_showNsfwOption) _buildNsfwToggleTile(context),
            ],
          ),
          CupertinoListSection(
            header: const Text('Advanced'),
            children: [
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.clear_circled_solid),
                title: const Text('Clear Cache'),
                onTap: () {
                  // Implement cache clearing logic here
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Cache Cleared'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          CupertinoListSection(
            header: const Text('About'),
            children: [
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.info_circle_fill),
                title: const Text('App Version'),
                additionalInfo: const Text('1.0.0'),
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
        ],
      ),
    );
  }

  Widget _buildPlayerSelectionTile(BuildContext context) {
    final playerService = Provider.of<PlayerSelectionService>(context);
    return CupertinoListTile(
      leading: const Icon(CupertinoIcons.play_rectangle_fill),
      title: const Text('Video Player'),
      additionalInfo: Text(playerService.selectedPlayer == 'native' ? 'Native' : 'MPV'),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                child: const Text('Native Player'),
                onPressed: () {
                  playerService.setPlayer('native');
                  Navigator.pop(context);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('MPV Player'),
                onPressed: () {
                  playerService.setPlayer('mpv');
                  Navigator.pop(context);
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceSelectionTile(BuildContext context) {
    final sourceService = Provider.of<SourceSelectionService>(context);
    return CupertinoListTile(
      leading: const Icon(CupertinoIcons.globe),
      title: const Text('Anime Source'),
      additionalInfo: Text(sourceService.selectedSource.name),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            actions: sourceService
                .getAllSources()
                .map((source) => CupertinoActionSheetAction(
                      child: Text(source.name),
                      onPressed: () {
                        sourceService.setSelectedSource(source.name);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNsfwToggleTile(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    return CupertinoListTile(
      leading: const Icon(CupertinoIcons.eye_slash_fill),
      title: const Text('Enable NSFW (18+)'),
      trailing: CupertinoSwitch(
        value: settingsService.isNsfwEnabled,
        onChanged: (bool value) {
          settingsService.isNsfwEnabled = value;
        },
      ),
    );
  }
}