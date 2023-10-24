import { initialState } from '../../constants/constants';
import React, { ReactNode } from 'react';
import { QRCodeGeneratorAction } from '../types/reducer-types';
import { Tabs } from '../enums/tabs-enum';
import { QRCodeRequest } from './qr-code-request-interfaces';

export interface CoreContextType {
  activeTab: Tabs;
  batchData: QRCodeRequest[];
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  error: string;
  qrBatchCount: number;
  selectedCrypto: string;
  selectedVersion: string;
  setActiveTab: React.Dispatch<React.SetStateAction<Tabs>>;
  setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
  setError: React.Dispatch<React.SetStateAction<string>>;
  setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
  setSelectedCrypto: React.Dispatch<React.SetStateAction<string>>;
  setSelectedVersion: React.Dispatch<React.SetStateAction<string>>;
  state: typeof initialState;
}

export interface CoreProviderProperties {
  children: ReactNode;
}

export interface ThemeContextType {
  theme: string;
  toggleTheme: () => void;
}

export interface ThemeProviderProperties {
  children: ReactNode;
}
