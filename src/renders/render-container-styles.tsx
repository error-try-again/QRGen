import {useMemo} from "react";
import {styles} from "../assets/styles.tsx";

export function RenderContainerStyles(theme: string) {
    return useMemo(() => ({
        ...styles.themeContainer,
        backgroundColor: theme === 'light' ? 'white' : 'black',
        color: theme === 'light' ? 'black' : 'white',
    }), [theme]);
}
