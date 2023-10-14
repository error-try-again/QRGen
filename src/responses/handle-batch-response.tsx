import {QRCodeRequest} from "../ts/interfaces/qr-code-request-types.tsx";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state.tsx";

export function HandleBatchResponse(setError: (value: (((previousState: string) => string) | string)) => void, setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void, dispatch: React.Dispatch<QRCodeGeneratorAction>) {
    return async (response: Response) => {
        const blob = await response.blob();
        const href = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = href;
        link.download = 'qrCodes.zip';
        document.body.append(link);
        link.click();
        link.remove();
        setError("");
        resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
    };
}
