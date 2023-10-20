import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";

export interface HandleSingleResponseParameters {
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
}

export const HandleSingleResponse = (
    {dispatch, setError, setBatchData, setQrBatchCount}: HandleSingleResponseParameters) => async (response: Response) => {
    const result = await response.json();
    dispatch({type: 'SET_QRCODE_URL', value: result.qrCodeURL});
    setError("");
    resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
};
