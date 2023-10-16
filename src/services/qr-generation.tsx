import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import {Tabs} from "../ts/enums/tabs-enum.tsx";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state.tsx";
import {HandleSingleResponse} from "../responses/handle-single-response.tsx";
import {ValidateInput} from "../validators/validate-input.tsx";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {HandleFetchError} from "../helpers/handle-fetch-error.tsx";
import {HandleErrorResponse} from "../responses/handle-error-response.tsx";
import {HandleBatchResponse} from "../responses/handle-batch-response.tsx";


export function QRGeneration(
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    qrBatchCount: number,
    batchData: QRCodeRequest[],
    state: QRCodeGeneratorState,
    activeTab: Tabs,
    setError: (value: (((previousState: string) => string) | string)) => void,
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void,
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void) {
    const validateInput = ValidateInput(activeTab, state, setError, setBatchData, setQrBatchCount, dispatch);

    const handleSingleResponse = HandleSingleResponse(dispatch, setError, setBatchData, setQrBatchCount);
    const handleFetchError = HandleFetchError(setError, dispatch, setBatchData, setQrBatchCount);
    const handleErrorResponse = HandleErrorResponse(setError, setBatchData, setQrBatchCount, dispatch);
    const handleBatchResponse = HandleBatchResponse(setError, setBatchData, setQrBatchCount, dispatch);

    return async () => {
        if (!validateInput()) {
            resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
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
                resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
                return;
            }

            if (response.status === 429) {
                setError('You have exceeded the rate limit. Please try again later.');
                resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
                return;
            }

            isBatch ? await handleBatchResponse(response) : await handleSingleResponse(response);

        } catch (error: unknown) {
            if (error instanceof Error) {
                handleFetchError(error);
                resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
            } else {
                setError("Unknown error.");
                resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
            }
        }
    };
}
