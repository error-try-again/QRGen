import React, { createContext, useEffect, useState } from 'react';
import {
  ThemeContextType,
  ThemeProviderProperties
} from '../ts/interfaces/context-interfaces';

export const ThemeProvider: React.FC<ThemeProviderProperties> = ({
  children
}) => {
  const [theme, setTheme] = useState('light'); // default theme is light

  useEffect(() => {
    // Set the theme for the body element to the current theme
    document.body.style.backgroundColor =
      theme === 'light' ? 'rgb(46, 48, 49)' : 'white';
    document.body.style.color = theme === 'light' ? '#dbd6d0' : 'black';

    // Patch for an issue where the body is not set to display block by default
    document.body.style.display = 'block';
  }, [theme]);

  const toggleTheme: () => void = () => {
    if (theme === 'light') {
      setTheme('dark');
    } else {
      setTheme('light');
    }
  };

  const value: ThemeContextType = {
    theme,
    toggleTheme
  };

  return (
    <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
  );
};

export const ThemeContext = createContext<ThemeContextType | undefined>(
  undefined
);
