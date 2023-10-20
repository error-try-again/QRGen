import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {Tabs} from "../ts/enums/tabs-enum";
import {resetBatchAndLoadingState} from "./reset-loading-state";

interface HandleTabChangeParameters {
    setError: (value: (((previousState: string) => string) | string)) => void;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setTab: React.Dispatch<React.SetStateAction<Tabs>>;
}

export function HandleTabChange({setError, setBatchData, setQrBatchCount, dispatch, setTab}: HandleTabChangeParameters) {
    return (freshTab: Tabs) => {
        setError("");
        resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
        dispatch({type: 'SET_QRCODE_URL', value: ""});
        dispatch({type: 'RESET_STATE'});
        setTab(freshTab);
    };
}
