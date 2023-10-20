import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";

export interface HandleBatchResponseParameters {
    setError: (value: (((previousState: string) => string) | string)) => void;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
}

export function HandleBatchResponse({setError, setBatchData, setQrBatchCount, dispatch}: HandleBatchResponseParameters) {
    return async (response: Response) => {

        // Convert the ReadableStream to a Blob.
        const blob = await response.blob();
        const href = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = href;
        link.download = response.headers.get("content-disposition")?.split('filename=')[1] || "qrcodes.zip"; // Use the filename from the response or default to 'download.zip'
        document.body.append(link);
        link.click();
        link.remove();

        setError("");
        resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
    };

}
