import React from 'react';
import { styles } from '../../assets/styles';

export const WriteUpLink: React.FC = () => {
  const { link } = styles;
  return (
    <a
      style={link}
      href="https://insomniacvoid.dev/posts/qr-gen"
      target="_blank"
      rel="noopener noreferrer"
    >
      {' '}
      The write up for this project can be found here 📝
    </a>
  );
};
