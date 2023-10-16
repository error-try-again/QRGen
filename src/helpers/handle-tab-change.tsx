import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {Tabs} from "../ts/enums/tabs-enum.tsx";
import {resetBatchAndLoadingState} from "./reset-loading-state.tsx";

export function HandleTabChange(setError:
                                    (value: (((previousState: string) => string) | string)) => void,
                                setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void,
                                setQrBatchCount: (value: (((previousState: number) => number) | number)) => void,
                                dispatch: React.Dispatch<QRCodeGeneratorAction>,
                                setTab: React.Dispatch<React.SetStateAction<Tabs>>) {
    return (freshTab: Tabs) => {
        setError("");
        resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
        dispatch({type: 'SET_QRCODE_URL', value: ""});
        dispatch({type: 'RESET_STATE'});
        setTab(freshTab);
    };
}
