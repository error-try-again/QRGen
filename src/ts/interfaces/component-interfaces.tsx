import { QRCodeGeneratorState } from './qr-code-generator-state';
import { Tabs } from '../enums/tabs-enum';
import React, { ChangeEvent } from 'react';
import { QRCodeRequest } from './qr-code-request-interfaces';
import { QRCodeGeneratorAction } from '../types/reducer-types';

export interface TabParameters {
  tab: Tabs;
}

export interface TabButtonParameters {
  activeTab: Tabs;
  handleTabChange: (freshTab: Tabs) => void;
  label: string;
  setTab: React.Dispatch<React.SetStateAction<Tabs>>;
  tab: Tabs;
}

export interface InputFieldParameters {
  isRequired?: boolean;
  keyName: keyof QRCodeRequest;
  value: string | boolean | null | undefined;
  type?: string;
  setError: React.Dispatch<React.SetStateAction<string | ''>>;
  handleChange: (
    event: ChangeEvent<HTMLInputElement>,
    fieldName: keyof QRCodeRequest
  ) => void;
}

export interface ValidateInputParameters {
  activeTab: Tabs;
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  setBatchData: (
    value:
      | ((previousState: QRCodeRequest[]) => QRCodeRequest[])
      | QRCodeRequest[]
  ) => void;
  setError: (value: ((previousState: string) => string) | string) => void;
  setQrBatchCount: (
    value: ((previousState: number) => number) | number
  ) => void;
  state: QRCodeGeneratorState;
}

export interface HandleTabChangeParameters {
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  setBatchData: (
    value:
      | ((previousState: QRCodeRequest[]) => QRCodeRequest[])
      | QRCodeRequest[]
  ) => void;
  setError: (value: ((previousState: string) => string) | string) => void;
  setQrBatchCount: (
    value: ((previousState: number) => number) | number
  ) => void;
  setTab: React.Dispatch<React.SetStateAction<Tabs>>;
}

export interface HandleResponseParameters {
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  setBatchData: (
    value:
      | ((previousState: QRCodeRequest[]) => QRCodeRequest[])
      | QRCodeRequest[]
  ) => void;
  setError: (value: ((previousState: string) => string) | string) => void;
  setQrBatchCount: (
    value: ((previousState: number) => number) | number
  ) => void;
}

export interface HandleVersionSelectParameters {
  setSelectedVersion: (
    value: ((previousState: string) => string) | string
  ) => void;
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
}

export interface GenerateButtonsSectionParameters {
  activeTab: Tabs;
  batchData: QRCodeRequest[];
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  qrBatchCount: number;
  setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
  setError: (value: ((previousState: string) => string) | string) => void;
  setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
  state: QRCodeGeneratorState;
}

export interface UpdateBatchJobParameters {
  activeTab: Tabs;
  setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
  setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
  state: QRCodeGeneratorState;
}

export interface QRGenerationParameters {
  activeTab: Tabs;
  batchData: QRCodeRequest[];
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  qrBatchCount: number;
  setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
  setError: (value: ((previousState: string) => string) | string) => void;
  setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
  state: QRCodeGeneratorState;
}
