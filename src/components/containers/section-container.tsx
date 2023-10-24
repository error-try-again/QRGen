import React, { ReactNode } from 'react';
import { styles } from '../../assets/styles';

interface SectionWrapperProperties {
  children: ReactNode;
}

export const SectionWrapper: React.FC<SectionWrapperProperties> = ({
  children
}) => {
  const { themeContainer, tabContainer } = styles;

  return (
    <div style={themeContainer}>
      <div style={tabContainer}>{children}</div>
    </div>
  );
};
