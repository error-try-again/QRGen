import { styles } from '../../assets/styles';
import { useTheme } from '../../hooks/use-theme';

export const ThemeToggle = () => {
  const { theme, toggleTheme } = useTheme();
  const { tabButton } = styles;
  return (
    <button
      style={{ ...tabButton }}
      onClick={toggleTheme}
    >
      {theme === 'light' ? (
        <span
          role="img"
          aria-label="dark mode"
        >
          Dark 🌙
        </span>
      ) : (
        <span
          role="img"
          aria-label="light mode"
        >
          Light ☀️
        </span>
      )}
    </button>
  );
};
