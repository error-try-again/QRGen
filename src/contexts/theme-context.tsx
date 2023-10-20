import React, {createContext, ReactNode, useMemo, useState} from "react";

export interface ThemeContextType {
    theme: string;
    toggleTheme: () => void;
}

interface ThemeProviderProperties {
    children: ReactNode;
}


export const ThemeProvider: React.FC<ThemeProviderProperties> = ({children}) => {
    const [theme, setTheme] = useState('light'); // default theme is light

    useMemo(() => {
        // Set the theme for the body element to the current theme
        document.body.style.backgroundColor = theme === 'light' ? 'rgb(46, 48, 49)' : 'white';
        document.body.style.color = theme === 'light' ? '#dbd6d0' : 'black';

        // Patch for an issue where the body is not set to display block by default
        document.body.style.display = 'block'
    }, [theme]);

    const toggleTheme = () => {
        if (theme === 'light') {
            setTheme('dark');
        } else {
            setTheme('light');
        }
    };

    return (
        <ThemeContext.Provider value={{theme, toggleTheme}}>
            {children}
        </ThemeContext.Provider>
    );
};


export const ThemeContext = createContext<ThemeContextType | undefined>(undefined);
