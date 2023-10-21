import React from 'react';
import { styles } from '../../assets/styles';

export const Divider: React.FC = () => {
  const { divider } = styles;
  return <div style={divider}></div>;
};
