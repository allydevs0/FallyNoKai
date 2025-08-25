// F:\Anime\anime-react-native\app/(tabs)/_layout.tsx

import { Tabs } from 'expo-router';
import React from 'react';
import { MaterialIcons } from '@expo/vector-icons'; // Assuming @expo/vector-icons is installed

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="index" // Corresponds to app/(tabs)/index.tsx
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => <MaterialIcons name="home" color={color} size={28} />,
        }}
      />
      <Tabs.Screen
        name="favorites" // Corresponds to app/(tabs)/favorites.tsx
        options={{
          title: 'Favorites',
          tabBarIcon: ({ color }) => <MaterialIcons name="favorite" color={color} size={28} />,
        }}
      />
      <Tabs.Screen
        name="history" // Corresponds to app/(tabs)/history.tsx
        options={{
          title: 'History',
          tabBarIcon: ({ color }) => <MaterialIcons name="history" color={color} size={28} />,
        }}
      />
      <Tabs.Screen
        name="settings" // Corresponds to app/(tabs)/settings.tsx
        options={{
          title: 'Settings',
          tabBarIcon: ({ color }) => <MaterialIcons name="settings" color={color} size={28} />,
        }}
      />
    </Tabs>
  );
}