import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state.tsx";

export function HandleErrorResponse(setError: (value: (((previousState: string) => string) | string)) => void, setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void, dispatch: React.Dispatch<QRCodeGeneratorAction>) {
    return async (response: Response) => {
        const result = await response.json();
        setError(result.message || 'Unknown error.');
        resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
    };
}
