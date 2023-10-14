import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-types.tsx";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state.tsx";

export function HandleSingleResponse(dispatch: React.Dispatch<QRCodeGeneratorAction>, setError: (value: (((previousState: string) => string) | string)) => void, setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void) {
    return async (response: Response) => {
        const result = await response.json();
        dispatch({type: 'SET_QRCODE_URL', value: result.qrCodeURL});
        setError("");
        resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
    };
}
