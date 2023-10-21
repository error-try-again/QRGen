import {styles} from "../../assets/styles";
import {ThemeContextType} from "../../contexts/theme-context";

export const ThemeToggle = ({toggleTheme, theme}: ThemeContextType) => {
    const {tabButton} = styles;
    return <button
        style={{...tabButton}}
        onClick={toggleTheme}>
        {theme === 'light' ? <span role="img" aria-label="dark mode">Dark 🌙</span> :
            <span role="img" aria-label="light mode">Light ☀️</span>}
    </button>;
};
