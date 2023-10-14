import {styles} from "../assets/styles.tsx";

export function ThemeToggle(toggleTheme: () => void, theme: string) {
    return <button
        style={
            {
                ...styles.tabButton,
            }
        }
        onClick={toggleTheme}>
        {
            theme === 'light' ? <span role="img" aria-label="dark mode">Dark Mode 🌙</span> :
                <span role="img" aria-label="light mode">Light Mode ☀️</span>
        }
    </button>;
}
