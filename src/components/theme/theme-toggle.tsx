import {styles} from "../../assets/styles.tsx";

interface ThemeToggleProperties {
    toggleTheme: () => void;
    theme: string;
}
export const ThemeToggle = ({toggleTheme, theme}: ThemeToggleProperties) => {
    const {tabButton} = styles;
    return <button
        style={{...tabButton}}
        onClick={toggleTheme}>
        {theme === 'light' ? <span role="img" aria-label="dark mode">Dark Mode 🌙</span> :
            <span role="img" aria-label="light mode">Light Mode ☀️</span>}
    </button>;
};
