import React from "react";
import {styles} from "../../assets/styles.tsx";

export const Donate: React.FC = () => {
    return <div style={styles.donateContainer}>
        <p style={styles.donateText}>If you like this tool, please consider donating to help support all future
            development. 📈</p>
        <button style={styles.generateButton}
                onClick={() => window.open('https://www.paypal.com/donate/?business=FJ6ZMVQEMSU7S&no_recurring=0&item_name=Help+support+future+development%21&currency_code=AUD', '_blank')}>Donate
        </button>
    </div>;
};
