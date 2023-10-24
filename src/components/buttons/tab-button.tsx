import { styles } from '../../assets/styles';
import * as React from 'react';
import { memo } from 'react';
import { TabButtonParameters } from '../../ts/interfaces/component-interfaces';

export const TabButtonComponent: React.FC<TabButtonParameters> = memo(
  ({ activeTab, handleTabChange, label, tab }) => {
    const { tabButton } = styles;
    return (
      <button
        onClick={() => handleTabChange(tab)}
        style={{
          ...tabButton,
          borderBottom:
            activeTab === tab ? '2px solid rgb(129, 214, 255)' : 'none'
        }}
      >
        {label}
      </button>
    );
  }
);

TabButtonComponent.displayName = 'TabButton';

export const TabButton = memo(TabButtonComponent);
