// F:\Anime\anime-react-native\src\services\SourceSelectionService.ts

import AsyncStorage from '@react-native-async-storage/async-storage';

type AnimeSource = 'sourceA' | 'sourceB' | 'sourceC'; // Example sources

const SOURCE_SELECTION_KEY = 'anime_source_selection';

class SourceSelectionService {
  private selectedSource: AnimeSource = 'sourceA';

  constructor() {
    this.init();
  }

  async init() {
    try {
      const storedSource = await AsyncStorage.getItem(SOURCE_SELECTION_KEY);
      if (storedSource) {
        this.selectedSource = storedSource as AnimeSource;
      }
    } catch (error) {
      console.error('Failed to load source selection from AsyncStorage', error);
    }
  }

  async setSource(source: AnimeSource) {
    this.selectedSource = source;
    try {
      await AsyncStorage.setItem(SOURCE_SELECTION_KEY, source);
    } catch (error) {
      console.error('Failed to save source selection to AsyncStorage', error);
    }
  }

  getSelectedSource(): AnimeSource {
    return this.selectedSource;
  }
}

export const sourceSelectionService = new SourceSelectionService();
