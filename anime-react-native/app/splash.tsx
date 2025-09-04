// F:\Anime\anime-react-native\app\splash.tsx

import React, { useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';

export default function SplashScreen() {
  const router = useRouter();

  useEffect(() => {
    // Simulate some loading time or service initialization
    setTimeout(() => {
      router.replace('/(tabs)'); // Navigate to the main screen after splash
    }, 3000); // 3 seconds delay
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Anime App</Text>
      <ActivityIndicator size="large" color="#0000ff" />
      <Text style={styles.subtitle}>Loading...</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  subtitle: {
    fontSize: 18,
    marginTop: 10,
  },
});
