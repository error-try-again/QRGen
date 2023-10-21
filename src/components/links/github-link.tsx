import React from 'react';
import { styles } from '../../assets/styles';

export const GithubLink: React.FC = () => {
  const { link } = styles;
  return (
    <a
      style={link}
      href="https://github.com/error-try-again/QRGen-FullStack"
      target="_blank"
      rel="noopener noreferrer"
    >
      View the project on Github 💾
    </a>
  );
};
