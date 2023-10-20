import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";

export function HandleErrorResponse(setError: (value: (((previousState: string) => string) | string)) => void, setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void, dispatch: React.Dispatch<QRCodeGeneratorAction>) {
    return async (response: Response) => {
        const result: string = await response.text();
        setError(result);
        resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
    };
}
