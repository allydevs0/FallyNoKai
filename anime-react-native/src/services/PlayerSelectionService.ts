// F:\Anime\anime-react-native\src\services\PlayerSelectionService.ts

import AsyncStorage from '@react-native-async-storage/async-storage';

type PlayerOption = 'default' | 'external'; // Example options

const PLAYER_SELECTION_KEY = 'player_selection';

class PlayerSelectionService {
  private selectedPlayer: PlayerOption = 'default';

  constructor() {
    this.init();
  }

  async init() {
    try {
      const storedPlayer = await AsyncStorage.getItem(PLAYER_SELECTION_KEY);
      if (storedPlayer) {
        this.selectedPlayer = storedPlayer as PlayerOption;
      }
    } catch (error) {
      console.error('Failed to load player selection from AsyncStorage', error);
    }
  }

  async setPlayer(player: PlayerOption) {
    this.selectedPlayer = player;
    try {
      await AsyncStorage.setItem(PLAYER_SELECTION_KEY, player);
    } catch (error) {
      console.error('Failed to save player selection to AsyncStorage', error);
    }
  }

  getSelectedPlayer(): PlayerOption {
    return this.selectedPlayer;
  }
}

export const playerSelectionService = new PlayerSelectionService();
