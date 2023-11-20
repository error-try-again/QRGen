import React from 'react';
import { styles } from '../../assets/styles';

export const GithubLink: React.FC = () => {
  const { link } = styles;
  return (
    <a
      style={link}
      href="https://github.com/error-try-again/QRGen"
      target="_blank"
      rel="noopener noreferrer"
    >
      This project is available on Github under the MIT license 📦
    </a>
  );
};
