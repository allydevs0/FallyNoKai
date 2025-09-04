// F:\Anime\anime-react-native\app/(tabs)/settings.tsx

import React from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import { useTheme } from '../../src/services/ThemeService'; // Adjust path as needed

export default function SettingsScreen() {
  const { currentThemeName, toggleTheme } = useTheme();

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Settings Screen</Text>
      <Text>Current Theme: {currentThemeName}</Text>
      <Button title="Toggle Theme" onPress={toggleTheme} />
      <Text>More settings options will go here.</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f0f0f0',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
  },
});
