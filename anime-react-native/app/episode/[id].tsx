// F:\Anime\anime-react-native\app\episode\[id].tsx

import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { Video } from 'expo-av'; // Using expo-av for video playback
import { animeScraper } from '../../src/services/AnimeScraper';

interface EpisodeDetails {
  id: string;
  title: string;
  videoUrl: string;
}

export default function EpisodeScreen() {
  const { id } = useLocalSearchParams();
  const [episodeDetails, setEpisodeDetails] = useState<EpisodeDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const video = React.useRef(null);

  useEffect(() => {
    const fetchDetails = async () => {
      if (typeof id === 'string') {
        // In a real app, you'd fetch episode details including video URL
        // For now, we'll use the simulated data from animeScraper
        const episodes = await animeScraper.fetchEpisodes('someAnimeId'); // Pass a dummy animeId for now
        const foundEpisode = episodes.find(ep => ep.id === id);
        setEpisodeDetails(foundEpisode || null);
      }
      setLoading(false);
    };
    fetchDetails();
  }, [id]);

  if (loading) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#0000ff" />
        <Text>Loading Episode...</Text>
      </View>
    );
  }

  if (!episodeDetails || !episodeDetails.videoUrl) {
    return (
      <View style={styles.container}>
        <Text>Episode not found or video URL is missing.</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{episodeDetails.title}</Text>
      <Video
        ref={video}
        style={styles.video}
        source={{ uri: episodeDetails.videoUrl }}
        useNativeControls
        resizeMode="contain"
        isLooping
        onPlaybackStatusUpdate={status => console.log(status)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000', // Black background for video
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 10,
  },
  video: {
    width: '100%',
    height: 300, // Adjust height as needed
  },
});
