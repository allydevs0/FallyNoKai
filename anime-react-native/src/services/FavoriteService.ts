// F:\Anime\anime-react-native\src\services\FavoriteService.ts

import AsyncStorage from '@react-native-async-storage/async-storage';

interface AnimeItem {
  id: string;
  title: string;
  // Add other properties as needed
}

const FAVORITES_KEY = 'favorite_anime_items';

class FavoriteService {
  private favorites: AnimeItem[] = [];

  constructor() {
    this.init();
  }

  async init() {
    try {
      const storedFavorites = await AsyncStorage.getItem(FAVORITES_KEY);
      if (storedFavorites) {
        this.favorites = JSON.parse(storedFavorites);
      }
    } catch (error) {
      console.error('Failed to load favorites from AsyncStorage', error);
    }
  }

  async addFavorite(item: AnimeItem) {
    if (!this.favorites.some(fav => fav.id === item.id)) {
      this.favorites.push(item);
      await this.saveFavorites();
    }
  }

  async removeFavorite(itemId: string) {
    this.favorites = this.favorites.filter(fav => fav.id !== itemId);
    await this.saveFavorites();
  }

  isFavorite(itemId: string): boolean {
    return this.favorites.some(fav => fav.id === itemId);
  }

  getFavorites(): AnimeItem[] {
    return [...this.favorites]; // Return a copy to prevent direct modification
  }

  private async saveFavorites() {
    try {
      await AsyncStorage.setItem(FAVORITES_KEY, JSON.stringify(this.favorites));
    } catch (error) {
      console.error('Failed to save favorites to AsyncStorage', error);
    }
  }
}

export const favoriteService = new FavoriteService();
