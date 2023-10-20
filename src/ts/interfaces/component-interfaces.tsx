import {QRCodeGeneratorState} from "./qr-code-generator-state.tsx";
import {Tabs} from "../enums/tabs-enum.tsx";
import React from "react";
import {QRCodeRequest} from "./qr-code-request-interfaces.tsx";
import {QRCodeGeneratorAction} from "../types/reducer-types.tsx";

export interface AllTabs {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    selectedCrypto: string;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setSelectedCrypto: React.Dispatch<React.SetStateAction<string>>;
    state: QRCodeGeneratorState;
}

export interface GenerateButtonsSectionProperties {
    activeTab: Tabs;
    batchData: QRCodeRequest[];
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    qrBatchCount: number;
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
    state: QRCodeGeneratorState;
}

export interface UpdateBatchJobProperties {
    activeTab: Tabs;
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
    state: QRCodeGeneratorState;
}

export interface QRGenerationProperties {
    activeTab: Tabs,
    batchData: QRCodeRequest[],
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    qrBatchCount: number,
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>,
    setError: (value: (((previousState: string) => string) | string)) => void,
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>,
    state: QRCodeGeneratorState
}

export interface TabButtonParameters {
    activeTab: Tabs,
    handleTabChange: (freshTab: Tabs) => void,
    label: string,
    setTab: React.Dispatch<React.SetStateAction<Tabs>>,
    tab: Tabs
}

export interface InputFields {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setError: (value: (((previousState: string) => string) | string)) => void;
    state: QRCodeGeneratorState;
}

export interface Input {
    activeTab: Tabs;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
    state: QRCodeGeneratorState;
}

export interface HandleTabChangeParameters {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
    setTab: React.Dispatch<React.SetStateAction<Tabs>>;
}

export interface HandleResponseParameters {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
}

export interface HandleInputChangeParameters {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    state: QRCodeGeneratorState;
}

export interface VCard {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    renderInputFieldsInColumns: (fields: (keyof QRCodeRequest)[], columns: number) => React.JSX.Element;
    state: QRCodeGeneratorState;
}

export interface MeCard {
    renderInputFieldsInColumns: (fields: (keyof QRCodeRequest)[], columns: number) => React.JSX.Element;
}
