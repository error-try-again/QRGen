import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import {resetBatchAndLoadingState} from "./reset-loading-state.tsx";

export function HandleFetchError(setError: (value: (((previousState: string) => string) | string)) => void, dispatch: React.Dispatch<QRCodeGeneratorAction>, setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void) {
    return (error: Error) => {
        const errorMessage = 'Failed to generate the QR code. Please try again later.';
        console.error("Error:", error.message);
        setError(errorMessage);
        dispatch({type: 'SET_QRCODE_URL', value: ""});
        resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
    };
}
