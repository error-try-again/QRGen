import {QRCodeGeneratorState} from "./qr-code-generator-state";
import {QRCodeGeneratorAction} from "../types/reducer-types";
import {Tabs} from "../enums/tabs-enum";
import {QRCodeRequest} from "./qr-code-request-interfaces";
import React from "react";

export interface GenerateButtonsSectionProperties {
    state: QRCodeGeneratorState;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    activeTab: Tabs;
    qrBatchCount: number;
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
    batchData: QRCodeRequest[];
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
    setError: (value: (((previousState: string) => string) | string)) => void;
}
