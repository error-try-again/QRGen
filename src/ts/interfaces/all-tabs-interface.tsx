import {QRCodeGeneratorState} from "./qr-code-generator-state.tsx";
import React from "react";
import {QRCodeGeneratorAction} from "../types/reducer-types.tsx";

export interface AllTabs {
    state: QRCodeGeneratorState;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setError: (value: (((previousState: string) => string) | string)) => void;
    selectedCrypto: string;
    setSelectedCrypto: React.Dispatch<React.SetStateAction<string>>;
}
