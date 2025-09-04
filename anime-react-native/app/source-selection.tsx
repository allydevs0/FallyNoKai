// F:\Anime\anime-react-native\app/source-selection.tsx

import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Button, FlatList, TouchableOpacity } from 'react-native';
import { sourceSelectionService } from '../src/services/SourceSelectionService';

const availableSources = ['sourceA', 'sourceB', 'sourceC']; // Example sources

export default function SourceSelectionScreen() {
  const [selectedSource, setSelectedSource] = useState<string>('');

  useEffect(() => {
    const loadSelectedSource = async () => {
      const currentSource = sourceSelectionService.getSelectedSource();
      setSelectedSource(currentSource);
    };
    loadSelectedSource();
  }, []);

  const handleSourceSelect = async (source: string) => {
    await sourceSelectionService.setSource(source as any); // Cast to any for now
    setSelectedSource(source);
    // Optionally navigate back or show a confirmation
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Select Anime Source</Text>
      <FlatList
        data={availableSources}
        keyExtractor={(item) => item}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={[
              styles.sourceItem,
              selectedSource === item && styles.selectedSourceItem,
            ]}
            onPress={() => handleSourceSelect(item)}
          >
            <Text style={styles.sourceText}>{item}</Text>
          </TouchableOpacity>
        )}
      />
      <Text style={styles.currentSelection}>
        Current Selection: {selectedSource || 'None'}
      </Text>
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
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  sourceItem: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    backgroundColor: '#f9f9f9',
    marginBottom: 5,
    borderRadius: 5,
  },
  selectedSourceItem: {
    backgroundColor: '#e0e0ff',
    borderColor: '#0000ff',
    borderWidth: 1,
  },
  sourceText: {
    fontSize: 18,
  },
  currentSelection: {
    marginTop: 20,
    fontSize: 16,
    textAlign: 'center',
  },
});
