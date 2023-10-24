import { useContext } from 'react';

import { ThemeContext } from '../contexts/theme-context';
import { ThemeContextType } from '../ts/interfaces/context-interfaces';

export const useTheme = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('use-theme must be used within a ThemeProvider');
  }
  return context;
};
