
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_selection_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerSelectionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Player de Vídeo Padrão'),
            subtitle: Text(playerService.selectedPlayer == 'native' ? 'Nativo' : 'MPV'),
            onTap: () {
              _showPlayerSelectionDialog(context, playerService);
            },
          ),
        ],
      ),
    );
  }

  void _showPlayerSelectionDialog(BuildContext context, PlayerSelectionService playerService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Player'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Nativo'),
                value: 'native',
                groupValue: playerService.selectedPlayer,
                onChanged: (value) {
                  if (value != null) {
                    playerService.setPlayer(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('MPV'),
                value: 'mpv',
                groupValue: playerService.selectedPlayer,
                onChanged: (value) {
                  if (value != null) {
                    playerService.setPlayer(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
