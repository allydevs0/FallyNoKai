// F:\Anime\anime-react-native\app\index.tsx

import React, { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { ThemeProvider } from '../src/services/ThemeService.tsx';
import { favoriteService } from '../src/services/FavoriteService';
import { historyService } from '../src/services/HistoryService';
import { playerSelectionService } from '../src/services/PlayerSelectionService';
import { sourceSelectionService } from '../src/services/SourceSelectionService';
import { animeScraper } from '../src/services/AnimeScraper';

export default function App() {
  useEffect(() => {
    const initializeServices = async () => {
      await favoriteService.init();
      await historyService.init();
      await playerSelectionService.init();
      await sourceSelectionService.init();
      // animeScraper does not have an init method, it's stateless
    };
    initializeServices();
  }, []);

  return (
    <ThemeProvider>
      <View style={styles.container}>
        <Text style={styles.title}>Welcome to Anime App (React Native)!</Text>
        <Text>This is the starting point of your new mobile application.</Text>
      </View>
    </ThemeProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
  },
});
