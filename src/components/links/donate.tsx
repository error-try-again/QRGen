import React from 'react';
import { styles } from '../../assets/styles';

export const Donate: React.FC = () => {
  const { donateText, generateButton, donateContainer } = styles;
  return (
    <div style={donateContainer}>
      <p style={donateText}>
        If you like this tool, please consider donating to help support all
        future development. 📈
      </p>
      <button
        style={generateButton}
        onClick={() =>
          window.open(
            'https://www.paypal.com/donate/?business=FJ6ZMVQEMSU7S&no_recurring=1&item_name=Help+support+future+development%21&currency_code=AUD',
            '_blank'
          )
        }
      >
        Donate
      </button>
    </div>
  );
};
