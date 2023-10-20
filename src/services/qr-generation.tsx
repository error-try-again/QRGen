import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state";
import {Tabs} from "../ts/enums/tabs-enum";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";
import {HandleSingleResponse} from "../responses/handle-single-response";
import {ValidateInput} from "../validators/validate-input";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {HandleFetchError} from "../helpers/handle-fetch-error";
import {HandleErrorResponse} from "../responses/handle-error-response";
import {HandleBatchResponse} from "../responses/handle-batch-response";

interface QRGenerationProperties {
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    qrBatchCount: number,
    batchData: QRCodeRequest[],
    state: QRCodeGeneratorState,
    activeTab: Tabs,
    setError: (value: (((previousState: string) => string) | string)) => void,
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>,
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>
}

export function QRGeneration({
                                 dispatch,
                                 qrBatchCount,
                                 batchData,
                                 state,
                                 activeTab,
                                 setError,
                                 setBatchData,
                                 setQrBatchCount
                             }: QRGenerationProperties) {

    const validateInput = ValidateInput({activeTab : activeTab, state : state, setError : setError, setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
    const handleSingleResponse = HandleSingleResponse({dispatch : dispatch, setError : setError, setBatchData : setBatchData, setQrBatchCount : setQrBatchCount});
    const handleFetchError = HandleFetchError({setError : setError, dispatch : dispatch, setBatchData : setBatchData, setQrBatchCount : setQrBatchCount});
    const handleErrorResponse = HandleErrorResponse(setError, setBatchData, setQrBatchCount, dispatch);
    const handleBatchResponse = HandleBatchResponse({setError : setError, setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});

    return async () => {
        if (!validateInput()) {
            resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
            return;
        }

        dispatch({type: 'SET_LOADING', value: true});

        const isBatch = qrBatchCount > 1;
        const endpoint = isBatch ? '/qr/batch' : '/qr/generate';

        //Form server payload
        const requestData = isBatch ? {qrCodes: batchData} : {
            size: state.size,
            precision: state.precision,
            type: Tabs[activeTab],
            customData: {
                ...state,
            }
        };

        try {

            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(requestData)
            });

            if (!response.ok) {
                await handleErrorResponse(response);
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
                return;
            }

            if (response.status === 429) {
                setError('You have exceeded the rate limit. Please try again later.');
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
                return;
            }

            isBatch ? await handleBatchResponse(response) : await handleSingleResponse(response);

        } catch (error: unknown) {
            if (error instanceof Error) {
                handleFetchError();
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
            } else {
                setError("Unknown error.");
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
            }
        }
    };
}
