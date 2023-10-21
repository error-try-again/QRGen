// Define the context type
import { initialState } from '../constants/constants';
import { Tabs } from '../ts/enums/tabs-enum';
import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import React, { createContext, useReducer, useState } from 'react';
import { qrCodeReducer } from '../reducers/qr-code-reducer';
import {
  CoreContextType,
  CoreProviderProperties
} from '../ts/interfaces/context-interfaces';

export const CoreProvider: React.FC<CoreProviderProperties> = ({
  children
}) => {
  const [activeTab, setActiveTab] = useState<Tabs>(Tabs.Text);

  const [selectedCrypto, setSelectedCrypto] = useState<string>('bitcoin');
  const [selectedVersion, setSelectedVersion] = useState<string>('3.0');

  const [error, setError] = useState<string>('');
  const [qrBatchCount, setQrBatchCount] = useState<number>(0);
  const [batchData, setBatchData] = useState<QRCodeRequest[]>([]);

  const [state, dispatch] = useReducer(qrCodeReducer, initialState);

  // Provide all state and setters to context consumers
  const value: CoreContextType = {
    activeTab,
    batchData,
    dispatch,
    error,
    qrBatchCount,
    selectedCrypto,
    selectedVersion,
    setActiveTab,
    setBatchData,
    setError,
    setQrBatchCount,
    setSelectedCrypto,
    setSelectedVersion,
    state
  };

  return <CoreContext.Provider value={value}>{children}</CoreContext.Provider>;
};

export const CoreContext = createContext<CoreContextType | undefined>(
  undefined
);
