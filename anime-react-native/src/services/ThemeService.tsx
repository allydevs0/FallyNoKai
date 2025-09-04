// F:\Anime\anime-react-native\src\services\ThemeService.ts

import React, { useState, useEffect, createContext, useContext } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Appearance } from 'react-native';

// Define your theme types (e.g., light, dark)
type ThemeName = 'light' | 'dark';

interface ThemeContextType {
  currentThemeName: ThemeName;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentThemeName, setCurrentThemeName] = useState<ThemeName>('light');

  useEffect(() => {
    const loadTheme = async () => {
      try {
        const storedTheme = await AsyncStorage.getItem('theme');
        if (storedTheme) {
          setCurrentThemeName(storedTheme as ThemeName);
        } else {
          // Use system theme as default if no theme is stored
          const systemTheme = Appearance.getColorScheme();
          setCurrentThemeName(systemTheme === 'dark' ? 'dark' : 'light');
        }
      } catch (error) {
        console.error('Failed to load theme from AsyncStorage', error);
        // Fallback to light theme on error
        setCurrentThemeName('light');
      }
    };

    loadTheme();
  }, []);

  useEffect(() => {
    const saveTheme = async () => {
      try {
        await AsyncStorage.setItem('theme', currentThemeName);
      } catch (error) {
        console.error('Failed to save theme to AsyncStorage', error);
      }
    };

    saveTheme();
  }, [currentThemeName]);

  const toggleTheme = () => {
    setCurrentThemeName((prevTheme) => (prevTheme === 'light' ? 'dark' : 'light'));
  };

  return (
    <ThemeContext.Provider value={{ currentThemeName, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};
