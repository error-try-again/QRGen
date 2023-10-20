import {QRCodeGeneratorState} from "./qr-code-generator-state.tsx";
import {Tabs} from "../enums/tabs-enum.tsx";
import React, {ChangeEvent} from "react";
import {QRCodeRequest} from "./qr-code-request-interfaces.tsx";
import {QRCodeGeneratorAction} from "../types/reducer-types.tsx";

export interface AllTabsParameters {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    selectedCrypto: string;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setSelectedCrypto: React.Dispatch<React.SetStateAction<string>>;
    state: QRCodeGeneratorState;
    tab: Tabs;
}

export interface TabButtonParameters {
    activeTab: Tabs,
    handleTabChange: (freshTab: Tabs) => void,
    label: string,
    setTab: React.Dispatch<React.SetStateAction<Tabs>>,
    tab: Tabs
}

export interface RenderInputFieldsParameters {
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    setError: (value: (((previousState: string) => string) | string)) => void;
    state: QRCodeGeneratorState;
    tab: Tabs;
}

export interface InputFieldParameters {
    isRequired?: boolean,
    keyName: keyof QRCodeRequest,
    value: string | boolean | null | undefined,
    type?: string,
    setError: React.Dispatch<React.SetStateAction<string | "">>,
    handleChange: (event: ChangeEvent<HTMLInputElement>, fieldName: keyof QRCodeRequest) => void
}

export interface ValidateInputParameters {
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

export interface VCardParameters {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    renderInputFieldsInColumns: (fields: (keyof QRCodeRequest)[], columns: number) => React.JSX.Element;
    state: QRCodeGeneratorState;
}

export interface MeCardParameters {
    renderInputFieldsInColumns: (fields: (keyof QRCodeRequest)[], columns: number) => React.JSX.Element;
}

export interface GenerateButtonsSectionParameters {
    activeTab: Tabs;
    batchData: QRCodeRequest[];
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    qrBatchCount: number;
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
    setError: (value: (((previousState: string) => string) | string)) => void;
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
    activeTab: Tabs,
    batchData: QRCodeRequest[],
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    qrBatchCount: number,
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>,
    setError: (value: (((previousState: string) => string) | string)) => void,
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>,
    state: QRCodeGeneratorState
}
