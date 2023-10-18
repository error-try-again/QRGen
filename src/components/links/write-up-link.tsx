import React from "react";
import {styles} from "../../assets/styles.tsx";

export const WriteUpLink: React.FC = () => {
    const {link} = styles;
    return <a style={link} href="https://www.error-try-again.com/qr-code-generator"
              target="_blank" rel="noopener noreferrer"> The write up for this project can be found here 📝</a>;
};
