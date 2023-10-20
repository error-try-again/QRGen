import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {resetBatchAndLoadingState} from "./reset-loading-state";

interface HandleFetchErrorParameters {
    setError: (value: (((previousState: string) => string) | string)) => void;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
}

export const HandleFetchError = ({setError, dispatch, setBatchData, setQrBatchCount}: HandleFetchErrorParameters) => () => {
    const errorMessage = 'Failed to generate the QR code. Please try again later.';
    setError(errorMessage);
    dispatch({type: 'SET_QRCODE_URL', value: ""});
    resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
};
