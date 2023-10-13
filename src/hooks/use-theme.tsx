import {useContext} from "react";

import {ThemeContext, ThemeContextType} from "../contexts/theme-context.tsx";
export const useTheme = (): ThemeContextType => {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('use-theme.tsx must be used within a ThemeProvider');
    }
    return context;
};
