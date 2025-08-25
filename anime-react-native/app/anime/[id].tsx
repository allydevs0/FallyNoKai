// F:\Anime\anime-react-native\app\anime\[id].tsx

import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { animeScraper } from '../../src/services/AnimeScraper';

interface AnimeDetails {
  id: string;
  title: string;
  description: string;
  imageUrl: string;
  // Add other details as needed
}

export default function AnimeDetailScreen() {
  const { id } = useLocalSearchParams();
  const [animeDetails, setAnimeDetails] = useState<AnimeDetails | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDetails = async () => {
      if (typeof id === 'string') {
        const details = await animeScraper.fetchAnimeDetails(id);
        setAnimeDetails(details);
      }
      setLoading(false);
    };
    fetchDetails();
  }, [id]);

  if (loading) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#0000ff" />
        <Text>Loading Anime Details...</Text>
      </View>
    );
  }

  if (!animeDetails) {
    return (
      <View style={styles.container}>
        <Text>Anime not found.</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{animeDetails.title}</Text>
      <Text style={styles.description}>{animeDetails.description}</Text>
      {/* Add image and other details here */}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#ffffff',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  description: {
    fontSize: 16,
    lineHeight: 24,
  },
});
