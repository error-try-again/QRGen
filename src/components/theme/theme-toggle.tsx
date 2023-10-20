import {styles} from "../../assets/styles";

interface ThemeToggleProperties {
    toggleTheme: () => void;
    theme: string;
}
export const ThemeToggle = ({toggleTheme, theme}: ThemeToggleProperties) => {
    const {tabButton} = styles;
    return <button
        style={{...tabButton}}
        onClick={toggleTheme}>
        {theme === 'light' ? <span role="img" aria-label="dark mode">Dark 🌙</span> :
            <span role="img" aria-label="light mode">Light ☀️</span>}
    </button>;
};
