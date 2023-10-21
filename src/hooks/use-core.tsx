import { useContext } from 'react';
import { CoreContext } from '../contexts/core-context';
import { CoreContextType } from '../ts/interfaces/context-interfaces';

export const useCore = (): CoreContextType => {
  const context = useContext(CoreContext);
  if (!context) {
    throw new Error('use-core must be used within a CoreProvider');
  }
  return context;
};
