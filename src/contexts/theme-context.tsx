import React, {createContext, ReactNode, useEffect, useState} from "react";

export interface ThemeContextType {
    theme: string;
    toggleTheme: () => void;
}

interface ThemeProviderProperties {
    children: ReactNode;
}


export const ThemeProvider: React.FC<ThemeProviderProperties> = ({children}) => {
    const [theme, setTheme] = useState('light'); // default theme is light

    useEffect(() => {
        // Update the document body styles based on the theme
        document.body.style.backgroundColor = theme === 'light' ? 'white' : 'black';
        document.body.style.color = theme === 'light' ? 'black' : 'white';

        // Override default display behavior
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
