import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import {Tabs} from "../ts/enums/tabs-enum.tsx";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state.tsx";

export function QRGeneration(validateInput: () => boolean, dispatch: React.Dispatch<QRCodeGeneratorAction>, qrBatchCount: number, batchData: QRCodeRequest[], state: QRCodeGeneratorState, activeTab: Tabs, handleErrorResponse: (response: Response) => Promise<void>, setError: (value: (((previousState: string) => string) | string)) => void, setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void, handleBatchResponse: (response: Response) => Promise<void>, handleSingleResponse: (response: Response) => Promise<void>, handleFetchError: (error: Error) => void) {
    return async () => {
        if (!validateInput()) {
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
            } else {
                setError("Unknown error.");
                resetBatchAndLoadingState(setBatchData, setQrBatchCount, dispatch);
            }
        }
    };
}
