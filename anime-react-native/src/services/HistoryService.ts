// F:\Anime\anime-react-native\src\services\HistoryService.ts

import AsyncStorage from '@react-native-async-storage/async-storage';

interface HistoryEntry {
  id: string;
  title: string;
  timestamp: number; // Unix timestamp
  // Add other properties as needed
}

const HISTORY_KEY = 'viewing_history_items';

class HistoryService {
  private history: HistoryEntry[] = [];

  constructor() {
    this.init();
  }

  async init() {
    try {
      const storedHistory = await AsyncStorage.getItem(HISTORY_KEY);
      if (storedHistory) {
        this.history = JSON.parse(storedHistory);
      }
    } catch (error) {
      console.error('Failed to load history from AsyncStorage', error);
    }
  }

  async addHistoryEntry(item: Omit<HistoryEntry, 'timestamp'>) {
    const newEntry: HistoryEntry = { ...item, timestamp: Date.now() };
    // Remove existing entry if it's already in history to update timestamp and move to top
    this.history = this.history.filter(entry => entry.id !== newEntry.id);
    this.history.unshift(newEntry); // Add to the beginning
    await this.saveHistory();
  }

  getHistory(): HistoryEntry[] {
    return [...this.history]; // Return a copy
  }

  async clearHistory() {
    this.history = [];
    await this.saveHistory();
  }

  private async saveHistory() {
    try {
      await AsyncStorage.setItem(HISTORY_KEY, JSON.stringify(this.history));
    } catch (error) {
      console.error('Failed to save history to AsyncStorage', error);
    }
  }
}

export const historyService = new HistoryService();
