import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";

export interface ResetBatchAndLoadingStateParameters {
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
}

export function resetBatchAndLoadingState(
    {setBatchData, setQrBatchCount, dispatch}: ResetBatchAndLoadingStateParameters) {
    setBatchData([]);
    setQrBatchCount(0);
    dispatch({type: 'SET_LOADING', value: false});
}
