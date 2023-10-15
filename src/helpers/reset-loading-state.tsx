import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";

export function resetBatchAndLoadingState(setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void, dispatch: React.Dispatch<QRCodeGeneratorAction>) {
    return () => {
        setBatchData([]);
        setQrBatchCount(0);
        dispatch({type: 'SET_LOADING', value: false});
    };
}
